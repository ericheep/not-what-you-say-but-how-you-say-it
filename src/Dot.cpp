//  Dot.cpp
//  voice-clip-vis

#include "Dot.hpp"

Dot::Dot(float x, float y, float amplitude) {
    m_x = x;
    m_y = y;
    m_amplitude = amplitude;
    
    m_gravity = 0.0;
    m_dotRadius = 1;
    m_lifetime = 80;
    m_lifetimeStart = m_lifetime;
}

void Dot::draw() {
    ofSetColor(255, 255, 255, float(m_lifetime)/m_lifetimeStart * 255);
    ofFill();
    ofDrawRectangle(getX(), getY(), m_dotRadius, m_dotRadius);
}

void Dot::update() {
    spread();
    m_lifetime--;
}

void Dot::fall() {
    m_gravity += ofRandom(-0.015, 0.015);
    m_y = m_y - m_gravity;
}

void Dot::spread() {
    m_y += m_amplitude * 1.5;
}

float Dot::getX() {
    return m_x;
}

float Dot::getY() {
    return m_y;
}

bool Dot::isDead() {
    if (m_lifetime >= 0) {
        return false;
    } else {
        return true;
    }
}
