// Jammer.ck
// October 18th, 2017

// Eric Heep

public class Jammer extends Chubgraph {

    inlet => Gain gn => DelayL del => outlet;

    0::ms   => dur currentDelay;
    500::ms => dur maxDelay;
    5::ms   => dur delayIncrement;

    del.max(maxDelay);
    del.delay(currentDelay);

    fun void decreaseDelay() {
        if (currentDelay > 0::ms) {
            delayIncrement -=> currentDelay;
            del.delay(currentDelay);
        }
    }

    fun void increaseDelay() {
        if (currentDelay < maxDelay) {
            delayIncrement +=> currentDelay;
            del.delay(currentDelay);
        }
    }
}
