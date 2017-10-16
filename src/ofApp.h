#pragma once

#include "ofMain.h"
#include "ofxOsc.h"
#include "Slice.hpp"
#include "ofxCenteredTrueTypeFont.h"
#include <string>

#define PORT 12345

class ofApp : public ofBaseApp{
	public:
    
    void setup();
	void update();
	void draw();

    vector<Slice> slices;
    
    int const NUM_SLICES = 16;
    int const FRAMERATE = 60;
    
    vector<std::string> subtitles;
    vector<float> subtitlePositions;
    
    ofxOscReceiver recieve;
    ofxCenteredTrueTypeFont myFont;
};
