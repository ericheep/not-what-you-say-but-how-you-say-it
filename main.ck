// main.ck
// not-what-you-say-but-how-you-say-it
// ..is that too literal?

// August 22nd, 2017
// Eric Heep

// init
AudioOSCID audioOSC;

32 => int TOTAL_TAKES;
TOTAL_TAKES=> int NUM_SLICES;

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

/*
fun void sliceLoop(int whichTake) {
    spork ~ record(whichTake);

    for (0 => int i; i < whichTake + 1; i++) {
        if (i == 0) {
            spork ~ slcr[whichTake - i].slice(i, whichTake + 1, 0);
        } else {
            spork ~ slcr[whichTake - i].slice(i, whichTake + 1, 1);
        }
    }
}
*/

fun void sectionOne(int whichTake) {
    // spork ~ record(whichTake);

    for (0 => int i; i < whichTake; i++) {

        // always record the newest take loop
        if (i == whichTake - 1) {
            spork ~ slcr[whichTake - i].loop(1);
        } else {
            spork ~ slcr[whichTake - i].loop(0);
        }
    }
}

fun void main() {
    1 => int whichTake;

    while (true) {
        hi => now;

        while (hi.recv(msg)) {

            // ~
            if (msg.ascii == 96) {
                if (msg.isButtonDown()) {
                    slcr[0].record(1);
                    1 => recordFlag;
                }
                if (msg.isButtonUp()) {
                    slcr[0].record(0);
                    0 => recordFlag;

                    1 => whichTake;
                }
            }

            // spacebar
            if (msg.ascii == 32) {
                if (msg.isButtonDown()) {
                    audioOSC.instance.clear();
                    sectionOne(whichTake);
                    // sliceLoop(whichTake);

                    whichTake++;
                    if (whichTake >= TOTAL_TAKES) {
                        1 => whichTake;
                    }
                }
            }
        }
    }
}

// run

<<< "okay", "" >>>;

main();
