//  Slice.hpp
//  voice-clip-vis

#ifndef Slice_hpp
#define Slice_hpp

#include <stdio.h>
#include <string>
#include "ofMain.h"
#include "Dot.hpp"

#endif /* Slice_hpp */

class Slice {
    
    public:
    
    Slice();

    void setup();
    void update();
    void draw();
    void clear();
    
    vector<Dot> dots;

    void addDot(float x, float y, int idx, int num);
    void transformX(float &x);
    void transformY(float &y, float &r, float &f);
};
