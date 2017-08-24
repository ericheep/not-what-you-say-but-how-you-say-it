// main.ck
// not-what-you-say-but-how-you-say-it

// August 22nd, 2017
// Eric Heep

// init
SliceOSCID slcOSC;

64 => int NUM_TAKES;
NUM_TAKES=> int NUM_SLICES;

// global, ugh
0 => int recordFlag;

5.0::second => dur MAX_DURATION;
0.0::second => dur loopDuration;

Slice slc[NUM_SLICES];

// keyboard control

Hid hi;
HidMsg msg;
if (!hi.openKeyboard(0)) me.exit();

// sound chain

for (0 => int i; i < NUM_SLICES; i++) {
    adc => slc[i] => dac;

    // set memory
    slc[i].id(i);
    slc[i].duration(MAX_DURATION);

    slc[i].envelopePercentage(0.1);
    slc[i].sliceWidth(1.0);
}

// guts

fun void record(int idx) {
    slc[idx].record(1);
    loopDuration => now;
    slc[idx].record(0);
}

fun void recordFirstTake() {
    now => time recordStart;

    slc[0].record(1);
    while (recordFlag) {
        1::samp => now;
    }

    slc[0].record(0);
    now - recordStart => loopDuration;

    for (0 => int i; i < NUM_SLICES; i++) {
        slc[i].loopDuration(loopDuration);
    }
}

fun void sliceLoop(int takeNumber) {
    spork ~ record(takeNumber);

    for (0 => int j; j < takeNumber + 1; j++) {
        if (j == 0) {
            spork ~ slc[takeNumber - j].slice(j, takeNumber + 1, 0);
        } else {
            spork ~ slc[takeNumber - j].slice(j, takeNumber + 1, 1);
        }
    }

    loopDuration => now;
}

fun void main() {
    1 => int takeNumber;

    while (true) {
        hi => now;

        while (hi.recv(msg)) {

            // ~

            if (msg.ascii == 96) {
                if (msg.isButtonDown()) {
                    1 => recordFlag;
                    spork ~ recordFirstTake();
                }
                if (msg.isButtonUp()) {
                    0 => recordFlag;
                    1 => takeNumber;
                }
            }

            // space bar

            if (msg.ascii == 32) {
                if (msg.isButtonDown()) {
                    slcOSC.instance.clearOSC();
                    sliceLoop(takeNumber);
                    takeNumber++;
                    if (takeNumber >= NUM_TAKES) {
                        1 => takeNumber;
                    }
                }
            }
        }
    }
}

// run

<<< "okay", "" >>>;

main();
