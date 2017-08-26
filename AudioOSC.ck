public class AudioOSC {

    OscOut out;
    OscMsg msg;

    out.dest("127.0.0.1", 12345);

    44.1::samp => dur OSC_SPEED;

    fun void clear() {
        out.start("/c");
        out.send();
    }

    fun void number(int idx, float pos) {
        out.start("/n");
        out.add(idx);
        out.add(pos);
        out.send();
    }

    fun void send(LiSa mic, Gain gn, WinFuncEnv env, dur loopDuration, time loopStart, dur sendDuration, int tapePlayback, int id) {
        (sendDuration/OSC_SPEED) $ int + 1 => int numSends;
        for (0 => int i; i < numSends; i++) {
            (now - loopStart)/loopDuration => float position;

            if (position <= 1.01) {
                out.start("/v");
                out.add(position);
                if (tapePlayback) {
                    out.add(env.windowValue() + mic.last());
                } else {
                    out.add(env.windowValue() + gn.last());
                }
                out.add(id);
                out.send();
            }
            OSC_SPEED => now;
        }
    }
}
