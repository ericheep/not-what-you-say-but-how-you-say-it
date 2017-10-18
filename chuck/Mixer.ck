// MIxer.ck

// October 17, 2017
// Eric Heep

public class Mixer extends Chubgraph {
    inlet => LiSa mic => outlet;

    16      => int divisions;
    0.0     => float difficulty;
    0::samp => dur loopTime;
    false   => int isRecording;

    // shuffles
    float positions[divisions];
    float lengths[divisions];
    int order[divisions];

    for (int i; i < divisions; i++) {
        i => order[i];
    }

    mic.duration(5::second);

    fun void setDivisions(int d) {
        d => divisions;
    }

    fun void setDifficulty(float d) {
        d => difficulty;
    }

    fun void record(int r) {
        if (r) {
            true => isRecording;
            spork ~ recording();
        } else {
            false => isRecording;
        }
    }

    fun void recording() {
        mic.clear();
        mic.recPos(0::samp);
        mic.record(1);
        while (isRecording) {
            samp => now;
        }
        mic.recPos() => loopTime;
        mic.record(0);
        generatePositions();
    }

    fun void randomSwap() {
        order.size() => int SIZE;
        Math.random2(0, SIZE - 1) => int j;
        Math.random2(0, SIZE - 1) => int i;
        order[j] => int tmp;
        order[i] => order[j];
        tmp => order[i];
    }

    fun void shuffleArray(int arr[]) {
        arr.size() => int SIZE;
        int tmp, j;

        for (SIZE - 1 => int i; i > 0; i--) {
            Math.random2(0, i) => j;
            arr[j] => tmp;
            arr[i] => arr[j];
            tmp => arr[i];
        }
    }

    fun void generatePositions() {
        for (int i; i < divisions - 1; i++) {
            1.0/divisions + 1.0/divisions * i => positions[i + 1];
            (Math.random2f(0.0, difficulty) * 1.0/divisions) * 0.5 => float augment;
            if (maybe) {
                augment +=> positions[i + 1];
            } else {
                augment -=> positions[i + 1];
            }
            positions[i + 1] - positions[i] => lengths[i];
        }

        1.0 - positions[divisions - 1] => lengths[divisions - 1];
    }

    fun void play() {
        mic.play(1);
        for (int i; i < divisions; i++) {
            order[i] => int idx;
            mic.playPos(positions[idx] * loopTime);

            (lengths[idx] * loopTime) => dur partialTime;
            mic.rampUp(partialTime * 0.05);
            partialTime * 0.95 => now;
            mic.rampDown(partialTime * 0.05);
            partialTime * 0.05 => now;
        }
        mic.play(0);
    }
}

fun void test() {
    adc => Mixer m => dac;

    Hid hi;
    HidMsg msg;
    49 => int one;
    50 => int two;
    81 => int q;

    48 => int zero;
    57 => int nine;
    79 => int o;

    if (!hi.openKeyboard(0)) me.exit();
    m.setDifficulty(1.0);

    while (true) {
        hi => now;

        while (hi.recv(msg)) {
            if (msg.ascii == one) {
                if (msg.isButtonDown()) {
                    m.record(true);
                }
                if (msg.isButtonUp()) {
                    m.record(false);
                }
            }

            if (msg.ascii == two && msg.isButtonDown()) {
                m.randomSwap();
            }

            if (msg.ascii == q && msg.isButtonDown()) {
                m.play();
            }

            if (msg.ascii == zero) {
                if (msg.isButtonDown()) {
                    m.record(true);
                }
                if (msg.isButtonUp()) {
                    m.record(false);
                }
            }

            if (msg.ascii == nine && msg.isButtonDown()) {
                m.randomSwap();
            }
            if (msg.ascii == o && msg.isButtonDown()) {
                m.play();
            }
        }
    }
}

test();
