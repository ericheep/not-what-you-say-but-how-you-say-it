//  Slice.cpp
//  voice-clip-vis

#include "Slice.hpp"

Slice::Slice() {

}

void Slice::setup() {
    
}

void Slice::update() {
    for (int i = int(dots.size()) - 1; i >= 0; i--) {
        dots.at(i).update();
        if (dots.at(i).isDead()) {
            dots.erase(dots.begin() + i);
        }
    }
}

void Slice::draw() {
    for (int i = 0; i < dots.size(); i++) {
        dots.at(i).draw();
    }
}

void Slice::clear() {
    dots.clear();
}

void Slice::transformX(float &x) {
    x = ofGetWindowWidth() * x;
}

void Slice::transformY(float &y, float &r, float &f) {
    y = y * f * ofGetWindowHeight()+ ofGetWindowHeight() * r;
}

void Slice::addDot(float x, float y, int idx, int num) {
    float position = (idx + 1.0)/(num + 1.0);
    float fraction = 1.0/(num + 1.0);
    float amplitude = y;
    
    transformX(x);
    transformY(y, position, fraction);
    
    dots.push_back(Dot(x, y, amplitude));
}
