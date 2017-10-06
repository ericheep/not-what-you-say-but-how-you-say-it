// main.ck
// not-what-you-say-but-how-you-say-it
// ..is that too literal?

// August 22nd, 2017
// Eric Heep

// init
AudioOSCID audioOSC;

16 => int TOTAL_TAKES;
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

fun void recordAndPlayLoops(int whichTake) {
    for (0 => int i; i < whichTake; i++) {
        // always record the newest take loop
        if (i == whichTake - 1) {
            spork ~ slcr[i].loop(1, whichTake);
        } else {
            spork ~ slcr[i].loop(0, whichTake);
        }
    }
}

fun void setLoopDurations(dur loopDuration) {
    for (0 => int i; i < TOTAL_TAKES; i++) {
        slcr[i].loopDuration(loopDuration);
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
                    setLoopDurations(slcr[0].loopDuration());
                    0 => recordFlag;
                    2 => whichTake;
                }
            }

            // p
            if (msg.ascii == 80) {
                if (msg.isButtonDown()) {
                    slcr[0].loop(0, 1);
                }
            }


            // spacebar
            if (msg.ascii == 32) {
                if (msg.isButtonDown()) {
                    audioOSC.instance.clear();
                    recordAndPlayLoops(whichTake);

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
