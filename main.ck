// main.ck
// not-what-you-say-but-how-you-say-it

// August 22nd, 2017
// Eric Heep

// init

2 => int NUM_TAKES;
NUM_TAKES=> int NUM_SLICES;

1.0::second => dur LOOP_DURATION;

Slice slc[NUM_SLICES];

// sound chain

for (0 => int i; i < NUM_SLICES; i++) {
    adc => slc[i] => dac;

    // set memory
    slc[i].duration(LOOP_DURATION);

    // set loop duration, should be less than memory
    slc[i].loopDuration(LOOP_DURATION);

    slc[i].envelopePercentage(0.25);
    slc[i].sliceWidth(1.0);
}

// guts

fun void record(int idx) {
    slc[idx].record(1);
    LOOP_DURATION => now;
    slc[idx].record(0);
}

fun void main() {
    0 => int takeNumber;

    for (0 => int i; i < NUM_TAKES; i++) {
        spork ~ record(takeNumber);

        for (0 => int j; j < takeNumber; j++) {
            if (i == 0) {
                spork ~ slc[j].slice(i, takeNumber + 1, 0);
            } else {
                spork ~ slc[j].slice(i, takeNumber + 1, 1);
            }
        }

        LOOP_DURATION => now;

        takeNumber++;
    }
}

// run

<<< "okay", "" >>>;

main();
