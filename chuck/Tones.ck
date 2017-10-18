// Tones.ck

// October 16th, 2017
// Eric Heep

public class Tones extends Chubgraph {

    // AudioOSCID audioOSC;

    3 => int NUM_TONES;

    0.000025    => float gainIncrement;
    0.0015      => float moveRatio;
    0.33        => float gainCap;
    false       => int isTuning;

    inlet => Gain gn;
    PitchTrack pitch => blackhole;

    SinOsc tones[NUM_TONES];
    float currentFreqs[NUM_TONES];
    float desiredFreqs[NUM_TONES];

    for (0 => int i; i < NUM_TONES; i++) {
        tones[i] => outlet;
        tones[i].gain(0.0);
        100 => currentFreqs[i];
        100 => desiredFreqs[i];
        spork ~ updateTone(i);
    }

    fun void updateTone(int idx) {
        while(true) {
            if (tones[idx].gain() < gainCap) {
                tones[idx].gain() + gainIncrement => tones[idx].gain;
            }

            desiredFreqs[idx] - currentFreqs[idx] => float distance;

            if (Math.fabs(distance) > 0.01) {
                distance * moveRatio +=> currentFreqs[idx];
            }

            tones[idx].freq(currentFreqs[idx]);
            // audioOSC.instance.sendTone(currentFreqs[idx], tones[idx].gain(), idx, which);

            10::ms => now;
        }
    }

    fun void display() {
        while (true) {
            <<< "Desired:", desiredFreqs[0], desiredFreqs[1], desiredFreqs[2],
               "Current:", currentFreqs[0], currentFreqs[1], currentFreqs[2] >>>;
            100::ms => now;
        }
    }

    spork ~ display();

    fun void tuneTone(int t) {
        if (t) {
            true => isTuning;
            spork ~ tuningTone();
        } else {
            false => isTuning;
        }
    }

    fun void tuningTone() {
        float frequencies[0];

        gn => pitch;
        while (isTuning) {
            pitch.get() => float freq;
            if (freq > 0) {
                frequencies << freq;
            }
            2048::samp => now;
        }

        frequencies.size()/NUM_TONES=> int partialSize;

        for (0 => int i; i < NUM_TONES; i++) {
            float sum;
            for (0 => int j; j < partialSize; j++) {
                frequencies[i * partialSize + j] +=> sum;
            }

            sum/partialSize => desiredFreqs[i];
        }
        gn =< pitch;
    }
}


fun void test() {
    adc => Tones t => dac;

    Hid hi;
    HidMsg msg;
    49 => int one;
    if (!hi.openKeyboard(0)) me.exit();

    while (true) {
        hi => now;

        while (hi.recv(msg)) {
            if (msg.ascii == one) {
                if (msg.isButtonDown()) {
                    t.tuneTone(true);
                }
                if (msg.isButtonUp()) {
                    t.tuneTone(false);
                }
            }
        }
    }
}

// test();
