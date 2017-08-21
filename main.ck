
32 => int NUM_TAKES;
0 => int takeNumber;

3.0::second => dur LOOP_DURATION;

SinOsc sin => dac;
LiSa mic[NUM_TAKES];
adc => Gain gn => blackhole;

sin.freq(1000);

for (0 => int i; i < NUM_TAKES; i++) {
    adc => mic[i] => dac;
    mic[i].duration(LOOP_DURATION);
}

fun void record(int idx) {
    mic[idx].duration();

    mic[idx].record(1);
    LOOP_DURATION => now;
    mic[idx].record(0);
}

fun void beeps() {
    sin.gain(0.5);
    0.05::second => now;
    sin.gain(0.0);
    0.05::second => now;
    sin.gain(0.5);
    0.05::second => now;
    sin.gain(0.0);
}

for (0 => int i; i < NUM_TAKES; i++) {
    beeps();
    LOOP_DURATION/(takeNumber + 1) => dur division;

    gn.gain(1.0);
    spork ~ record(takeNumber);
    division => now;
    gn.gain(0.0);

    for (0 => int j; j < takeNumber; j++) {
        mic[j].play(1);
        mic[j].playPos((j + 1) * division);
        division => now;
        mic[j].play(0);
    }

    takeNumber++;
}
