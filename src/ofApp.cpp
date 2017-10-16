#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    recieve.setup(PORT);
    ofSetFrameRate(FRAMERATE);
    ofBackground(0, 0, 0);
    
    for (int i = 0; i < NUM_SLICES; i++) {
        slices.push_back(Slice());
        subtitles.push_back("");
        subtitlePositions.push_back(0.0);
    }
    
    myFont.load("OperatorMono-Book.otf", 11);
}

//--------------------------------------------------------------
void ofApp::update(){
    while (recieve.hasWaitingMessages()) {
        ofxOscMessage msg;
        recieve.getNextMessage(&msg);
        
        if (msg.getAddress() == "/c") {
            for (int i = 0; i < NUM_SLICES; i++) {
                slices.at(i).clear();
                subtitles.at(i) = "";
            }
        }
        
        if (msg.getAddress() == "/n") {
            int idx = msg.getArgAsInt(0);
            float x = msg.getArgAsFloat(1);
            slices.at(idx).transformX(x);
            subtitlePositions.at(idx) = x;
            subtitles.at(idx) = std::to_string(idx + 1);
        }
        
        /*if (msg.getAddress() == "/v") {
            float x = msg.getArgAsFloat(0);
            float y = msg.getArgAsFloat(1);
            int idx = msg.getArgAsInt(2);
            slices.at(idx).addDot(x, y);
        }*/
        
        if (msg.getAddress() == "/g") {
            float x = msg.getArgAsFloat(0);
            float y = msg.getArgAsFloat(1);
            int idx = msg.getArgAsInt(2);
            int num = msg.getArgAsInt(3);
            slices.at(idx).addDot(x, y, idx, num);
        }
    }
    for (int i = 0; i < NUM_SLICES; i++) {
        slices.at(i).update();
    }
}

//--------------------------------------------------------------
void ofApp::draw(){
    for (int i = 0; i < NUM_SLICES; i++) {
        slices.at(i).draw();
        if (subtitles.at(i) != "") {
            myFont.drawStringCenteredHorizontally(subtitles.at(i), subtitlePositions.at(i), ofGetWindowHeight() * 0.65);
        }
    }
}
