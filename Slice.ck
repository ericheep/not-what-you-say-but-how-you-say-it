// Slice.ck

// August 22nd, 2017
// Eric Heep

public class Slice extends Chubgraph {

    OscOut out;
    OscMsg msg;

    out.dest("127.0.0.1", 12345);

    // durs
    dur m_loopDuration;
    dur m_dividedSliceDuration;

    1.0 => float m_sliceWidth;
    1.0 => float m_envelopePercentage;

    adc => LiSa mic => WinFuncEnv env => dac;
    adc => Gain gn => env;

    // eventually will change to a WinFuncEnv, with no sustain
    // env.sustainLevel(1.0);

    20::samp => dur OSC_SPEED;

    // to be sporked at the start of a loop
    fun void slice(int whichSlice, int numSlices, int tapePlayback) {
        // find the middle point of the slice
        ((whichSlice + 0.5)/numSlices) * m_loopDuration => dur centerPosition;

        m_loopDuration/numSlices => dur dividedSliceDuration;

        // trim or extend
        dividedSliceDuration * m_sliceWidth => dur adjustedSliceDuration;

        adjustedSliceDuration * 0.5 => dur halfSliceDuration;
        halfSliceDuration * m_envelopePercentage => dur envelopeDuration;

        // set envelope times
        env.attackTime(envelopeDuration);
        env.releaseTime(envelopeDuration);

        playSlice(centerPosition, halfSliceDuration, envelopeDuration, tapePlayback);
    }

    // playing portion of the slice separated just to limit confusion
    fun void playSlice(dur centerPosition, dur halfSliceDuration, dur envelopeDuration, int tapePlayback) {
        now => time loopStart;

        // in case width is more than 1.0

        if (centerPosition >= halfSliceDuration) {
            centerPosition - halfSliceDuration => now;
        }

        // recording or live

        if (tapePlayback) {
            mic.play(1);
        } else {
            gn.gain(1.0);
        }

        spork ~ sendEnvelopeOSC(loopStart, halfSliceDuration * 2.0);

        // envelope attack

        env.keyOn();
        halfSliceDuration => now;

        now - loopStart => dur midPoint;

        // in case width is more than 1.0

        if (midPoint + halfSliceDuration > m_loopDuration) {
            m_loopDuration - midPoint - envelopeDuration => now;
        } else {
            halfSliceDuration - envelopeDuration => now;
        }

        // envelope release

        env.keyOff();
        envelopeDuration => now;

        // recording or live

        if (tapePlayback) {
            mic.play(0);
        } else {
            gn.gain(0.0);
        }
    }

    fun void record(int r) {
        mic.clear();
        mic.record(r);
    }

    fun void duration(dur d) {
        mic.duration(d);
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

    fun void sendEnvelopeOSC(time loopStart, dur sendDuration) {
        (sendDuration/OSC_SPEED) $ int + 1 => int numSends;
        for (0 => int i; i < numSends; i++) {
            (now - loopStart)/m_loopDuration => float position;

            if (position <= 1.0) {
                out.start("/v");
                out.add(position);
                out.add(env.windowValue());
                out.send();
            }

            OSC_SPEED => now;
        }
    }
}
