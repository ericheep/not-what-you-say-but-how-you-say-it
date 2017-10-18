public class AudioOSC {

    OscOut out;
    OscMsg msg;

    out.dest("127.0.0.1", 12345);

    22::samp => dur OSC_SPEED;

    fun void clear() {
        out.start("/c");
        out.send();
    }

    fun void sendTone(float freq, float gain, int idx, int which) {
        out.start("/t");
        out.add(freq);
        out.add(gain);
        out.add(idx);
        out.add(which);
        out.send();
    }

    fun void number(int idx, float pos) {
        out.start("/n");
        out.add(idx);
        out.add(pos);
        out.send();
    }

    fun void sendGain(Gain gn, int idx, int num, dur sendDuration) {
        now => time loopStart;
        0.0 => float horizontalPosition;

        while (horizontalPosition <= 1.0) {
            (now - loopStart)/sendDuration => horizontalPosition;

            out.start("/g");
            out.add(horizontalPosition);
            out.add(gn.last());
            out.add(idx);
            out.add(num);
            out.send();

            OSC_SPEED => now;
        }
    }

    fun void sendEnvPlusGain(Gain gn, WinFuncEnv env, dur loopDuration, time loopStart, int id) {
        0.0 => float position;

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
