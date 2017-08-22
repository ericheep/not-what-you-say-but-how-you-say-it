
1 => int NUM_TAKES;
0 => int takeNumber;

2.0::second => dur LOOP_DURATION;

Slice mic[NUM_TAKES];
adc => Gain gn => blackhole;

for (0 => int i; i < NUM_TAKES; i++) {
    adc => mic[i] => dac;
    mic[i].duration(LOOP_DURATION);
}

fun void record(int idx) {
    mic[idx].record(1);
    LOOP_DURATION => now;
    mic[idx].record(0);
}

for (0 => int i; i < NUM_TAKES; i++) {
    spork ~ record(takeNumber);

    for (0 => int j; j < takeNumber; j++) {
        if (i == 0) {
            spork ~ mic[j].slice(i, 1.0, 1.0, 1);
        } else {
            spork ~ mic[j].slice(i, 1.0, 1.0);
        }
    }
    LOOP_DURATION => now;

    takeNumber++;
}
