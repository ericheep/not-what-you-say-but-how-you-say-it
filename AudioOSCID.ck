// AudioOSCID.ck
// August 24th, 2017

// creates a single OSC instance, which all the
// instantiations of Slicer will refer to

public class AudioOSCID {
    static AudioOSC @ instance;
}

new AudioOSC @=> AudioOSCID.instance;
