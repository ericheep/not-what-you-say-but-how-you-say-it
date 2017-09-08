// Slicer.ck

// August 22nd, 2017
// Eric Heep

public class Slicer extends Chubgraph {

    AudioOSCID audioOSC;

    // durs
    dur m_loopDuration;
    dur m_dividedSliceDuration;
    int m_id;

    1.0 => float m_sliceWidth;
    1.0 => float m_envelopePercentage;

    adc => LiSa tape => Gain tapeGn => WinFuncEnv env => dac;
    adc => Gain micGn => env;

    fun void id(int i) {
        i => m_id;
    }

    fun float getCenterPosition(int whichSlice, int numSlices) {
        return (whichSlice + 0.5)/numSlices;
    }

    fun dur getCenterDuration(float centerPoint, dur loopDuration) {
        return centerPoint * loopDuration;
    }

    fun dur getHalfSliceDuration(float sliceWidth, int numSlices, dur loopDuration) {
        return (loopDuration/numSlices * sliceWidth) * 0.5;
    }

    fun dur getEnvelopeDuration(dur halfSliceDuration, float envelopePercentage) {
        return halfSliceDuration * envelopePercentage;
    }

    fun void playLoop(int mainTake) {
        spork ~ audioOSC.instance.sendGain(tapeGn, m_loopDuration, m_id);

        tape.playPos(0::samp);
        tape.play(1);
        m_loopDuration => now;
        tape.play(0);
    }

    // to be sporked at the start of a loop
    fun void slice(int whichSlice, int numSlices, int tapePlayback) {
        getCenterPosition(whichSlice, numSlices) => float centerPosition;
        getCenterDuration(centerPosition, m_loopDuration) => dur centerDuration;
        getHalfSliceDuration(m_sliceWidth, numSlices, m_loopDuration) => dur halfSliceDuration;
        getEnvelopeDuration(halfSliceDuration, m_envelopePercentage) => dur envelopeDuration;

        // set envelope times
        env.attackTime(envelopeDuration);
        env.releaseTime(envelopeDuration);

        // let oFx know which slice this is
        audioOSC.instance.number(m_id, centerPosition);

        if (tapePlayback) {
            playSlice(tapeGn, centerDuration, halfSliceDuration, envelopeDuration);
        } else {
            playSlice(micGn, centerDuration, halfSliceDuration, envelopeDuration);
        }
    }

    // playing portion of the slice separated just to limit confusion
    fun void playSlice(Gain gn, dur centerDuration, dur halfSliceDuration, dur envelopeDuration) {
        now => time loopStart;
        centerDuration - halfSliceDuration => dur silenceDuration;

        if (silenceDuration > 0::samp) {
            silenceDuration => now;
        }

        gn.gain(1.0);
        env.keyOn();

        // sending audio data to oFx vis
        spork ~ audioOSC.instance.sendEnvPlusGain(gn, env, m_loopDuration, loopStart, m_id);

        if (silenceDuration > 0::samp) {
            halfSliceDuration => now;
        } else {
            halfSliceDuration + silenceDuration => now;
        }

        now - loopStart => dur midPoint;
        if (midPoint + halfSliceDuration > m_loopDuration) {
            m_loopDuration - midPoint - envelopeDuration => now;
        } else {
            halfSliceDuration - envelopeDuration => now;
        }

        env.keyOff();
        envelopeDuration => now;
        gn.gain(0.0);
    }

    fun void loop(int record) {
        <<< m_loopDuration >>>;
        /*
        now => time loopStart;

        spork ~ audioOSC.instance.sendGain(tapeGn, m_loopDuration, m_id);

        10::ms => dur envelopeDuration;
        env.attackTime(envelopeDuration);
        env.releaseTime(envelopeDuration);

        if (record) {
            tape.record(1);
            micGn.gain(1.0);
        } else {
            tape.playPos(0.0::samp);
            tape.play(1);
        }

        env.keyOn();

        m_loopDuration - envelopeDuration => now;
        env.keyOff();

        envelopeDuration => now;
        if (record) {
            tape.record(0);
            micGn.gain(0.0);
        } else {
            tape.play(0);
        }
        */
    }

    fun void record(int r) {
        if (r) {
            tape.clear();
            tape.recPos(0::samp);
        } else {
            tape.recPos() => m_loopDuration;
        }
        tape.record(r);
    }

    fun void duration(dur d) {
        tape.duration(d);
    }

    fun void loopDuration(dur ld) {
        ld => m_loopDuration;
    }

    fun void sliceWidth(float sw) {
        sw => m_sliceWidth;
    }

    fun void envelopePercentage(float ep) {
        ep => m_envelopePercentage;
    }
}
