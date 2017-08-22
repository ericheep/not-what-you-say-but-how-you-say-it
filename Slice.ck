// Slice.ck

public class Slice extends Chubgraph {

    OscOut out;
    OscMsg msg;

    out.dest("127.0.0.1", 12345);

    // durs
    dur m_loopDuration;
    dur m_dividedSliceDuration;

    // slices
    int m_numSlices;

    adc => LiSa mic => ADSR env => dac;
    adc => Gain gn => env;

    // default liveMic set to 0
    fun void slice(int whichSlice, float sliceWidth, float envelopePercentage) {
        slice(whichSlice, sliceWidth, envelopePercentage, 0);
    }

    // to be sporked at the start of a loop
    fun void slice(int whichSlice, float sliceWidth, float envelopePercentage, int liveMic) {
        // find the middle point of the slice
        ((whichSlice + 0.5)/m_numSlices) * m_loopDuration => dur centerPosition;

        // trim or extend
        m_dividedSliceDuration * sliceWidth => dur adjustedSliceDuration;

        adjustedSliceDuration * 0.5 => dur halfSliceDuration;
        halfSliceDuration * envelopePercentage => dur envelopeDuration;

        // set envelope times
        env.attackTime(envelopeDuration);
        env.releaseTime(envelopeDuration);

        playSlice(centerPosition, halfSliceDuration, envelopeDuration, liveMic);
    }

    fun void playSlice(dur centerPosition, dur halfSliceDuration, dur envelopeDuration, int liveMic) {

        // wait until our first envelope
        if (centerPosition >= halfSliceDuration) {
            centerPosition - halfSliceDuration => now;
        }

        if (liveMic) {
            gn.gain(1.0);
        } else {
            mic.play(1);
        }

        // spork ~ sendEnvelopeOSC();

        env.keyOn();
        halfSliceDuration => now;
        halfSliceDuration - envelopeDuration => now;
        env.keyOff();
        envelopeDuration => now;

        if (liveMic) {
            gn.gain(0.0);
        } else {
            mic.play(0);
        }

        mic.play(0);
    }

    fun void record(int r) {
        mic.clear();
        mic.record(r);
    }

    fun void duration(dur d) {
        mic.duration(d);
        d => m_loopDuration;

        if (m_numSlices != 0) {
            m_loopDuration/m_numSlices => m_dividedSliceDuration;
        }
    }

    fun void numSlices(int s) {
        s => m_numSlices;

        if (m_loopDuration != 0::samp) {
            m_loopDuration/m_numSlices => m_dividedSliceDuration;
        }
    }

    fun void sendOSC() {
        /*out.start("/v");
        out.add(env.last());
        out.add(mic.playPos());
        out.send();*/
    }

}
