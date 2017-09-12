// Slicer.ck

// August 22nd, 2017
// Eric Heep

public class Slicer extends Chubgraph {

    AudioOSCID audioOSC;

    10::ms => dur m_loopEnvelopeDuration;
    dur m_loopDuration;
    dur m_dividedSliceDuration;
    int m_id;

    1.0 => float m_sliceWidth;
    1.0 => float m_envelopePercentage;

    adc => LiSa tape => Gain tapeGn => WinFuncEnv env => dac;
    adc => Gain micGn => env;

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

    /*
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
    */

    // straight forward looper
    fun void loop(int record, int num) {
        <<< "m_id", m_id, "num", num, "record", record >>>;
        if (record) {
            spork ~ audioOSC.instance.sendGain(micGn, m_id, num, m_loopDuration);
            tape.record(1);
            micGn.gain(1.0);
        } else {
            spork ~ audioOSC.instance.sendGain(tapeGn, m_id, num, m_loopDuration);
            tape.playPos(0.0::samp);
            tape.play(1);
        }

        env.attackTime(m_loopEnvelopeDuration);
        env.releaseTime(m_loopEnvelopeDuration);
        env.keyOn();

        m_loopDuration - m_loopEnvelopeDuration => now;
        env.keyOff();

        m_loopEnvelopeDuration => now;

        if (record) {
            tape.record(0);
            micGn.gain(0.0);
        } else {
            tape.play(0);
        }
    }

    // records when 1, stops recording and stores duration when 0
    fun void record(int r) {
        if (r) {
            tape.clear();
            tape.recPos(0::samp);
        } else {
            tape.recPos() => m_loopDuration;
        }
        tape.record(r);
    }

    // set loop duration
    fun dur loopDuration(dur l) {
        l => m_loopDuration;
    }

    // get loop duration
    fun dur loopDuration() {
        return m_loopDuration;
    }

    // sets slice id
    fun void id(int i) {
        i => m_id;
    }

    // set buffer duration
    fun void duration(dur d) {
        tape.duration(d);
    }

    // set slice width
    fun void sliceWidth(float sw) {
        sw => m_sliceWidth;
    }

    // set envelope percentage
    fun void envelopePercentage(float ep) {
        ep => m_envelopePercentage;
    }
}
