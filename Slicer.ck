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

    adc => LiSa mic => WinFuncEnv env => dac;
    adc => Gain gn => env;

    fun void id(int i) {
        i => m_id;
    }

    // to be sporked at the start of a loop
    fun void slice(int whichSlice, int numSlices, int tapePlayback) {
        // find the middle point of the slice
        ((whichSlice + 0.5)/numSlices) => float centerPosition;
        centerPosition * m_loopDuration => dur centerDuration;

        // finds the non adjusted slice duration
        m_loopDuration/numSlices => dur dividedSliceDuration;

        // trim or extend the duration according to the slice width
        dividedSliceDuration * m_sliceWidth => dur adjustedSliceDuration;

        adjustedSliceDuration * 0.5 => dur halfSliceDuration;
        halfSliceDuration * m_envelopePercentage => dur envelopeDuration;

        // set envelope times
        env.attackTime(envelopeDuration);
        env.releaseTime(envelopeDuration);

        audioOSC.instance.number(m_id, centerPosition);
        playSlice(centerDuration, halfSliceDuration, envelopeDuration, tapePlayback);
    }

    // playing portion of the slice separated just to limit confusion
    fun void playSlice(dur centerDuration, dur halfSliceDuration, dur envelopeDuration, int tapePlayback) {
        now => time loopStart;

        // in case width is more than 1.0
        centerDuration - halfSliceDuration => dur wait;

        if (wait > 0::samp) {
            wait => now;
        }

        // recording or live

        if (tapePlayback) {
            mic.play(1);
            mic.playPos(centerDuration - halfSliceDuration);
        } else {
            gn.gain(1.0);
        }

        spork ~ audioOSC.instance.send(mic, gn, env, m_loopDuration, loopStart, halfSliceDuration * 2.0, tapePlayback, m_id);

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
}
