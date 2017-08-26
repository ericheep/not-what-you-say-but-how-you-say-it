// main.ck
// not-what-you-say-but-how-you-say-it

// August 22nd, 2017
// Eric Heep

// init
AudioOSCID audioOSC;

32 => int NUM_TAKES;
NUM_TAKES=> int NUM_SLICES;

// global, ugh
0 => int recordFlag;

5.0::second => dur MAX_DURATION;
0.0::second => dur loopDuration;

Slicer slcr[NUM_SLICES];

// keyboard control

Hid hi;
HidMsg msg;
if (!hi.openKeyboard(0)) me.exit();

// sound chain

for (0 => int i; i < NUM_SLICES; i++) {
    adc => slcr[i] => dac;

    // set memory
    slcr[i].id(i);
    slcr[i].duration(MAX_DURATION);

    slcr[i].envelopePercentage(0.1);
    slcr[i].sliceWidth(1.0);
}

// guts

fun void record(int idx) {
    slcr[idx].record(1);
    loopDuration => now;
    slcr[idx].record(0);
}

fun void recordFirstTake() {
    now => time recordStart;

    slcr[0].record(1);
    while (recordFlag) {
        1::samp => now;
    }

    slcr[0].record(0);
    now - recordStart => loopDuration;

    for (0 => int i; i < NUM_SLICES; i++) {
        slcr[i].loopDuration(loopDuration);
    }
}

fun void sliceLoop(int takeNumber) {
    spork ~ record(takeNumber);

    for (0 => int j; j < takeNumber + 1; j++) {
        if (j == 0) {
            spork ~ slcr[takeNumber - j].slice(j, takeNumber + 1, 0);
        } else {
            spork ~ slcr[takeNumber - j].slice(j, takeNumber + 1, 1);
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
                    audioOSC.instance.clear();
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
