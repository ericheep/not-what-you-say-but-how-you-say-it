
2 => int NUM_TAKES;
0 => int takeNumber;

0.2::second => dur LOOP_DURATION;

Slice mic[NUM_TAKES];
adc => Gain gn => blackhole;

for (0 => int i; i < NUM_TAKES; i++) {
    adc => mic[i] => dac;
    mic[i].duration(LOOP_DURATION);
    mic[i].loopDuration(LOOP_DURATION);
    mic[i].envelopePercentage(0.1);
}

fun void record(int idx) {
    mic[idx].record(1);
    LOOP_DURATION => now;
    mic[idx].record(0);
}

for (0 => int i; i < NUM_TAKES; i++) {
    spork ~ record(takeNumber);

    for (0 => int j; j < takeNumber; j++) {
        mic[j].sliceWidth(2.0);
        mic[j].envelopePercentage(0.25);

        if (i == 0) {
            spork ~ mic[j].slice(i, takeNumber + 1, 0);
        } else {
            spork ~ mic[j].slice(i, takeNumber + 1, 1);
        }
    }

    LOOP_DURATION => now;

    takeNumber++;
}

1::second => now;
