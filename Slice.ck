// Slice.ck

public class Slice extends Chubgraph {

    OscOut out;
    OscMsg msg;

    out.dest("127.0.0.1", 12345);

    // durs
    dur m_loopDuration;
    dur m_dividedSliceDuration;

    1.0 => float m_sliceWidth;
    1.0 => float m_envelopePercentage;

    adc => LiSa mic => ADSR env => dac;
    adc => Gain gn => env;

    env.sustainLevel(1.0);

    .5::ms => dur OSC_SPEED;

    // to be sporked at the start of a loop
    fun void slice(int whichSlice, int numSlices, int tapePlayback) {
        // find the middle point of the slice
        ((whichSlice + 0.5)/numSlices) * m_loopDuration => dur centerPosition;

        m_loopDuration/numSlices => dur dividedSliceDuration;

        // trim or extend
        dividedSliceDuration * m_sliceWidth => dur adjustedSliceDuration;

        adjustedSliceDuration * 0.5 => dur halfSliceDuration;
        halfSliceDuration * m_envelopePercentage => dur envelopeDuration;
        <<< envelopeDuration >>>;

        // set envelope times
        env.attackTime(envelopeDuration);
        env.releaseTime(envelopeDuration);

        playSlice(centerPosition, halfSliceDuration, envelopeDuration, tapePlayback);
    }

    fun void playSlice(dur centerPosition, dur halfSliceDuration, dur envelopeDuration, int tapePlayback) {
        now => time loopStart;

        // wait until our first envelope
        if (centerPosition >= halfSliceDuration) {
            centerPosition - halfSliceDuration => now;
        }

        if (tapePlayback) {
            mic.play(1);
        } else {
            gn.gain(1.0);
        }

        spork ~ sendEnvelopeOSC(loopStart, halfSliceDuration * 2.0);

        env.keyOn();
        halfSliceDuration => now;
        halfSliceDuration - envelopeDuration => now;
        env.keyOff();
        envelopeDuration => now;

        if (tapePlayback) {
            mic.play(0);
        } else {
            gn.gain(0.0);
        }

        mic.play(0);
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
            out.start("/v");
            out.add((now - loopStart)/m_loopDurationmic.playPos());
            out.add(env.value());
            out.send();

            OSC_SPEED => now;
        }
    }

}
