// Sing.ck

// October 16th, 2017
// Eric Heep

public class Sing extends Chubgraph {
    3 => int NUM_TONES;

    0.0001 => float gainIncrement;
    0.1 => float pitchIncrement;
    float currentFreq, desiredFreq;

    inlet => Gain gn => PitchTrack pitch => blackhole;
    SinOsc tones[NUM_TONES];
    int isTuning[NUM_TONES];

    for (0 => int i; i < NUM_TONES; i++) {
        tones[i] => outlet;
        tones[i].gain(0.0);
        false => isTuning[i];
    }

    fun void tuneTone(int tuning, int idx) {
        if (tuning) {
            true => isTuning[idx];
            spork ~ tuningTone(idx);
        } else {
            false => isTuning[idx];
        }
    }

    fun void tuningTone(int idx) {
        float sum;
        int loop;

        while (isTuning[idx]) {
            loop++;

            if (tones[idx].gain() < 0.33) {
                tones[idx].gain() + gainIncrement => tones[idx].gain;
            }

            pitch.get() +=> sum;
            sum/loop => desiredFreq;

            if (currentFreq < desiredFreq) {
                pitchIncrement +=> currentFreq;
            } else if (currentFreq > desiredFreq) {
                pitchIncrement -=> currentFreq;
            }

            tones[idx].freq(currentFreq);

            <<< desiredFreq, tones[idx].gain(), tones[idx].freq() >>>;
            10::ms => now;
        }
    }
}


fun void test() {
    adc.left => Sing singA;
    adc.left => Sing singB;

    Hid hi;
    HidMsg msg;
    49 => int one;
    48 => int zero;
    if (!hi.openKeyboard(0)) me.exit();

    while (true) {
        while (hi.recv(msg)) {
            if (msg.ascii == one) {
                if (msg.isButtonDown()) {
                    singA.tuneTone(true, 0);
                }
                if (msg.isButtonUp()) {
                    singA.tuneTone(false, 0);
                }
            }

            if (msg.ascii == zero) {
                if (msg.isButtonDown()) {
                    singB.tuneTone(true, 0);
                }
                if (msg.isButtonUp()) {
                    singB.tuneTone(false, 0);
                }
            }
        }
        1::samp => now;
    }
}

test();
