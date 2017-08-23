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
    int m_id;

    1.0 => float m_sliceWidth;
    1.0 => float m_envelopePercentage;

    adc => LiSa mic => WinFuncEnv env => dac;
    adc => Gain gn => env;

    20::samp => dur OSC_SPEED;

    fun void id(int i) {
        i => m_id;
    }

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
        centerPosition - halfSliceDuration => dur wait;

        if (wait > 0::samp) {
            wait => now;
        }

        // recording or live

        if (tapePlayback) {
            mic.play(1);
            mic.playPos(centerPosition - halfSliceDuration);
        } else {
            gn.gain(1.0);
        }

        spork ~ sendEnvelopeOSC(loopStart, halfSliceDuration * 2.0, tapePlayback);

        // envelope attack

        env.keyOn();

        // might be a cleaner way to do this later on

        if (wait > 0::samp) {
            halfSliceDuration => now;
        } else {
            halfSliceDuration + wait => now;
        }

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
        if (r == 1) {
            mic.clear();
            mic.recPos(0::samp);
        }
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

    fun void sendEnvelopeOSC(time loopStart, dur sendDuration, int tapePlayback) {
        (sendDuration/OSC_SPEED) $ int + 1 => int numSends;
        for (0 => int i; i < numSends; i++) {
            (now - loopStart)/m_loopDuration => float position;

            if (position <= 1.0) {
                out.start("/v");
                out.add(position);
                if (tapePlayback) {
                    out.add(env.windowValue() + mic.last());
                } else {
                    out.add(env.windowValue() + gn.last());
                }
                out.add(m_id);
                out.send();
            }

            OSC_SPEED => now;
        }
    }
}
