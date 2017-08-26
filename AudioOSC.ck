public class AudioOSC {

    OscOut out;
    OscMsg msg;

    out.dest("127.0.0.1", 12345);

    22.05::samp => dur OSC_SPEED;

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

    fun void sendEnvPlusGain(Gain gn, WinFuncEnv env, dur loopDuration, time loopStart, int id) {
        0.0 => float position;
        1 => int stopFlag;;

        while (position <= 1.0) {
            (now - loopStart)/loopDuration => position;
            env.windowValue() + gn.last() => float val;

            out.start("/v");
            out.add(position);
            out.add(val);
            out.add(id);
            out.send();

            OSC_SPEED => now;
        }
    }
}
