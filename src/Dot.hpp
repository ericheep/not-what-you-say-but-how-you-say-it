//  Dot.hpp
//  voice-clip-vis

#ifndef Dot_hpp
#define Dot_hpp

#include <stdio.h>
#include "ofMain.h"

#endif /* Dot_hpp */

class Dot {
    
public:
    
    Dot(float x, float y, float amptlitude);
    
    void draw();
    void update();
    void fall();
    void spread();
    void setAmplitude(float);
    
    float getX();
    float getY();
    
    bool isDead();
    
private:
    
    float m_amplitude;
    float m_x;
    float m_y;
    float m_dotRadius;
    float m_gravity;
    float m_wind;
    
    int m_lifetime;
    int m_lifetimeStart;
};
