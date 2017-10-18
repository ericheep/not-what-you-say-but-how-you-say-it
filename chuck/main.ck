// main.ck
// not-what-you-say-but-how-you-say-it
// ..is that too literal?

// August 22nd, 2017
// Eric Heep

// sound chain
AudioOSCID audioOSC;
adc.left => Tones tonesLeft => dac.left;
adc.right => Tones tonesRight => dac.right;

adc.left => Jammer jammerLeft => dac.chan(2);
adc.right => Jammer jammerRight => dac.chan(3);

// keyboard control
Hid hi;
HidMsg msg;

// key ascii codes
49 => int one;
48 => int zero;
81 => int q;
65 => int a;
39 => int apostrophe;
67 => int slash;
32 => int spacebar;

if (!hi.openKeyboard(0)) me.exit();

tonesLeft.NUM_TONES => int NUM_TONES;

// sound chain
/*
for (0 => int i; i < NUM_SLICES; i++) {
    adc => slcr[i] => dac;

    // set memory
    slcr[i].id(i);
    slcr[i].duration(MAX_DURATION);

    slcr[i].envelopePercentage(0.1);
    slcr[i].sliceWidth(1.0);
}
*/

// guts

/*
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
*/

fun void main() {
    while (true) {
        hi => now;

        while (hi.recv(msg)) {
            <<< msg.ascii >>>;
            if (msg.ascii == one) {
                if (msg.isButtonDown()) {
                    tonesLeft.tuneTone(true);
                }
                if (msg.isButtonUp()) {
                    tonesLeft.tuneTone(false);
                }
            }
            if (msg.ascii == zero) {
                if (msg.isButtonDown()) {
                    tonesRight.tuneTone(true);
                }
                if (msg.isButtonUp()) {
                    tonesRight.tuneTone(false);
                }
            }
            if (msg.ascii == q && msg.isButtonDown()) {
                jammerRight.increaseDelay();
            }
            if (msg.ascii == a && msg.isButtonDown()) {
                jammerRight.decreaseDelay();
            }
            if (msg.ascii == apostrophe && msg.isButtonDown()) {
                jammerLeft.increaseDelay();
            }
            if (msg.ascii == slash && msg.isButtonDown()) {
                jammerLeft.decreaseDelay();
            }
        }
    }
}

// run

<<< "okay", "" >>>;

main();
