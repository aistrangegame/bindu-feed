#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// THE INSTRUMENT'S FIELD — a faithful Metal port of spine-field.js (The Instrument v3.html).
// One continuous axis Z; all 15 register-shells are composited additively EVERY frame, each at
// its own scale (q = uv · 2^(i − Z)), so the register he is entering is already forming inside
// the one he stands in and the one he left recedes as atmosphere. This is the "background" that
// was entirely missing — the layered multi-shell glow, one motif per register, recoloured by hue.

// the fifteen colours of the axis (base[]; universe slots kept a neutral room-grey for now)
constant float3 HUES[15] = {
    float3(0.929, 0.890, 0.808),  // -5 light  #EDE3CE
    float3(0.486, 0.525, 0.596),  // -4 sky    #7C8698
    float3(0.541, 0.576, 0.651),  // -3 region #8A93A6
    float3(0.541, 0.576, 0.651),  // -2 world
    float3(0.541, 0.576, 0.651),  // -1 fall
    float3(0.788, 0.761, 0.714),  //  0 feed   #C9C2B6
    float3(0.059, 0.055, 0.078),  //  1 gate   #0F0E14
    float3(0.929, 0.902, 0.839),  //  2 m1     #EDE6D6
    float3(0.725, 0.647, 0.910),  //  3 m2     #B9A5E8
    float3(0.490, 0.455, 0.788),  //  4 m3     #7D74C9
    float3(0.878, 0.443, 0.247),  //  5 m4     #E0713F
    float3(0.310, 0.765, 0.722),  //  6 m5     #4FC3B8
    float3(0.773, 0.416, 0.620),  //  7 m6     #C56A9E
    float3(0.831, 0.663, 0.294),  //  8 m7     #D4A94B
    float3(0.898, 0.325, 0.235),  //  9 particle #E5533C
};

// FALLBACK ONLY. The thirteen rooms' light-wells are now fed live as `uRm` (39 floats:
// x, y, density per room) from `UniWeather.sky(...)`, so the density channel is DERIVED from
// how much of him each room actually holds — `uni-deep.js:60-66` — instead of the flat 0.6
// every entry below carries. These values stand in only if the array arrives empty.
constant float3 ROOMS_FALLBACK[13] = {
    float3(-0.94, -0.96, 0.6), float3(0.94, -0.93, 0.6), float3(-0.18, -0.84, 0.6),
    float3(0.66, -0.59, 0.6),  float3(-0.84, -0.41, 0.6), float3(0.22, -0.22, 0.6),
    float3(-0.40, 0.06, 0.6),  float3(0.86, 0.14, 0.6),   float3(-0.90, 0.31, 0.6),
    float3(0.14, 0.45, 0.6),   float3(0.70, 0.67, 0.6),   float3(-0.66, 0.72, 0.6),
    float3(0.28, 0.97, 0.6),
};

static float ihash(float2 p) { return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453); }
static float inz(float2 p) {
    float2 i = floor(p), f = fract(p); f = f * f * (3.0 - 2.0 * f);
    return mix(mix(ihash(i), ihash(i + float2(1, 0)), f.x),
               mix(ihash(i + float2(0, 1)), ihash(i + float2(1, 1)), f.x), f.y);
}
static float ifbm(float2 p) { float v = 0.0, a = 0.5; for (int i = 0; i < 4; i++) { v += a * inz(p); p *= 2.03; a *= 0.5; } return v; }
static float irim(float r, float w) { return smoothstep(w, 0.0, abs(r - 1.0)); }
static float gmod(float x, float y) { return x - y * floor(x / y); }  // GLSL mod (fmod differs on negatives)

// ── the Universe side ──
static float mSky(float2 q, float t, float2 sweep, float dwell,
                  device const float *rm, int rmCount) {
    float v = 0.0;
    bool live = (rmCount >= 39);
    for (int i = 0; i < 13; i++) {
        float2 c = live ? float2(rm[i * 3], rm[i * 3 + 1]) : ROOMS_FALLBACK[i].xy;
        float den = live ? rm[i * 3 + 2] : ROOMS_FALLBACK[i].z;
        float d = length(q - c);
        float lit = 0.44 + 0.56 / (1.0 + length(c) * 1.7);
        v += (0.0007 + den * 0.0021) * lit / (d * d + 0.0026);
        v += den * 0.016 * smoothstep(0.26, 0.0, d);
    }
    float ang = sweep.x; float2 nn = float2(-sin(ang), cos(ang));
    v += sweep.y * smoothstep(0.030, 0.0, abs(dot(q, nn))) * 0.34;
    float a2 = atan2(q.y, q.x);
    v += dwell * pow(max(0.0, cos(13.0 * a2)), 7.0) * smoothstep(1.30, 0.04, length(q)) * 0.11;
    v += ifbm(q * 2.2 + float2(t * 0.006, 0.0)) * 0.034;
    return v * 0.85;
}
static float mRegion(float2 q, float t, float3 wx, float dwell) {
    float r = length(q); float tb = wx.x, dr = wx.y, gr = wx.z;
    float neb = ifbm(q * (1.1 + tb * 2.6) + float2(t * dr, -t * dr * 0.6));
    float v = neb * (0.13 + tb * 0.17) * smoothstep(1.2, 0.08, r);
    v += gr * inz(q * 42.0 + floor(t * 2.5)) * 0.028 * smoothstep(1.1, 0.1, r);
    v += (0.0010 + dwell * 0.0008) / (r * r + 0.0016);
    return v;
}
static float mWorld(float2 q, float t, float3 wx) {
    float r = length(q);
    float disc = smoothstep(0.62, 0.58, r);
    float2 L = normalize(float2(-0.58, -0.34));
    float lam = clamp(dot(normalize(q + 1e-5), L) * 0.5 + 0.55, 0.0, 1.0);
    float surf = ifbm(q * (3.4 + wx.x * 3.0) + float2(t * 0.012, t * 0.004));
    return disc * (lam * 0.30 + surf * 0.11) + irim(r / 0.62, 0.012) * 0.18;
}
static float mFall(float2 q, float t, float br) {
    float r = length(q); float v = 0.0016 / (r * r + 0.0010);
    for (int i = 0; i < 6; i++) { float fi = float(i); float rr = 0.16 + fi * 0.15;
        v += irim(r / (rr * (1.0 + br * 0.012)), 0.008) * (0.13 - fi * 0.016); }
    return v * 0.48;
}
static float mFeed(float2 q, float t, float br) {
    float r = length(q);
    return (0.0016 + br * 0.0006) / (r * r + 0.0012) + ifbm(q * 1.2 + float2(0.0, t * 0.004)) * 0.022 * smoothstep(1.4, 0.2, r);
}
static float mGate(float2 q, float t) {
    float v = 0.0; float2 g0 = floor(q * 7.0);
    for (int i = 0; i < 3; i++) {
        float2 c = (g0 + float2(ihash(g0 + float(i)), ihash(g0 + float(i) + 9.0))) / 7.0;
        float d = length(q - c); v += 0.00035 / (d * d + 0.00012);
    }
    return v * 0.6;
}
// ── the Point side · seven design languages ──
static float mPoint(float2 q, float t, float br) {
    float r = length(q); float v = 0.0012 / (r * r + 0.0006);
    v += irim(r / (0.44 + br * 0.02), 0.055) * 0.10 + irim(r / (0.78 + br * 0.03), 0.05) * 0.06;
    return v;
}
static float mTurn(float2 q, float t) {
    float r = length(q), a = atan2(q.y, q.x);
    float s = sin(3.0 * (a + log(max(r, 0.02)) * 1.9 - t * 0.09));
    return smoothstep(0.72, 1.0, s) * smoothstep(1.05, 0.28, r) * 0.5 + 0.0009 / (r * r + 0.001);
}
static float veilDensity(float2 q, float t) {
    float a = ifbm(float2(q.x * 1.7 + t * 0.030, q.y * 1.0 - t * 0.016));
    float b = ifbm(float2(q.x * 2.9 - t * 0.021, q.y * 1.6 + t * 0.034));
    float c = ifbm(float2(q.x * 5.2 + t * 0.048, q.y * 2.7 - t * 0.029));
    float d = ifbm(float2(q.x * 9.1 - t * 0.012, q.y * 4.8 + t * 0.019));
    return smoothstep(0.40, 0.88, a) * 0.34 + smoothstep(0.48, 0.92, b) * 0.26
         + smoothstep(0.55, 0.95, c) * 0.17 + smoothstep(0.62, 0.98, d) * 0.10;
}
static float mVeil(float2 q, float t, float3 hand) {
    float p = 0.0;
    if (hand.z > 0.001) p = hand.z * smoothstep(hand.z * 0.34 + 0.06, 0.0, length(q - hand.xy));
    float dens = veilDensity(q, t) * (1.0 - min(1.0, p));
    return dens * smoothstep(1.15, 0.16, length(q));
}
static float mCham(float2 q, float t, float br) {
    float r = length(q);
    float2 c = q * 3.4; float2 f = abs(fract(c) - 0.5); float w = smoothstep(0.46, 0.5, max(f.x, f.y));
    return w * 0.26 * ((0.5 + br * 0.5) * smoothstep(1.1, 0.15, r)) + irim(r / 0.62, 0.035) * 0.10;
}
static float mMirr(float2 q, float t) {
    float r = length(q), a = atan2(q.y, q.x);
    float k = 6.2831853 / 8.0; a = abs(gmod(a + t * 0.02, k) - k * 0.5);
    float2 m = float2(cos(a), sin(a)) * r;
    float e = smoothstep(0.02, 0.0, abs(m.y - 0.12)) + smoothstep(0.02, 0.0, abs(m.y + 0.12));
    return e * smoothstep(1.05, 0.2, r) * 0.30 + irim(r / 0.86, 0.04) * 0.08;
}
static float mRet(float2 q, float t, float br) {
    float r = length(q), a = atan2(q.y, q.x);
    float ray = pow(max(0.0, cos(12.0 * a + t * 0.05)), 22.0);
    return ray * smoothstep(1.2, 0.1, r) * 0.42 + irim(r / (0.55 + br * 0.04), 0.05) * 0.12;
}
static float mDance(float2 q, float t, float sync) {
    float v = 0.0; float sp = 1.0 - sync * 0.72;
    for (int i = 0; i < 9; i++) { float fi = float(i);
        float rd = 0.24 + fi * 0.072; float a = t * (1.55 - fi * 0.085) * sp + fi * 2.3999;
        float2 c = float2(cos(a), sin(a)) * rd; float d = length(q - c);
        v += (0.0021 + sync * 0.0009) / (d * d + 0.0016); }
    return v * 0.55 * smoothstep(1.25, 0.1, length(q));
}
static float mLight(float2 q, float t, float br) {
    float r = length(q); float hy = -0.30;
    float horizon = exp(-abs(q.y - hy) * 6.5) * 0.42;
    float e = (0.0030 + br * 0.0012) / (r * r + 0.0007);
    float f = 0.0;
    for (int k = 0; k < 4; k++) { float fk = float(k); float ph = fract(t * 0.026 + fk * 0.25);
        f += exp(-abs(q.y - hy - ph * 0.62) * 15.0) * 0.09 * (1.0 - ph); }
    return horizon + e + f;
}
static float motif(int i, float2 q, float t, float br, float sync, float3 wx, float3 hand, float2 sweep, float dwell,
                   device const float *rm, int rmCount) {
    if (i == 0)  return mLight(q, t, br);
    if (i == 1)  return mSky(q, t, sweep, dwell, rm, rmCount);
    if (i == 2)  return mRegion(q, t, wx, dwell);
    if (i == 3)  return mWorld(q, t, wx);
    if (i == 4)  return mFall(q, t, br);
    if (i == 5)  return mFeed(q, t, br);
    if (i == 6)  return mGate(q, t);
    if (i == 7)  return mPoint(q, t, br);
    if (i == 8)  return mTurn(q, t);
    if (i == 9)  return mVeil(q, t, hand);
    if (i == 10) return mCham(q, t, br);
    if (i == 11) return mMirr(q, t);
    if (i == 12) return mRet(q, t, br);
    if (i == 13) return mDance(q, t, sync);
    return (0.0026 + br * 0.0009) / (length(q) * length(q) + 0.0004);   // mSeed
}

[[ stitchable ]] half4 instrumentField(float2 pos, half4 color,
                                       float2 uRes, float uT, float uZ, float uBr, float uSync,
                                       float uSpin, float uReveal, float uDwell,
                                       float2 uSweep, float3 uWx, float3 uHand,
                                       device const float *uRm, int uRmCount) {
    float2 uv = (pos - 0.5 * uRes) / (0.5 * min(uRes.x, uRes.y));
    uv.y = -uv.y;                                        // SwiftUI y-down → the shader's y-up
    float ca = cos(uSpin), sa = sin(uSpin);
    uv = float2(uv.x * ca - uv.y * sa, uv.x * sa + uv.y * ca);
    float r = length(uv);
    float3 col = float3(0.0);
    float zi = uZ + 5.0;
    for (int i = 0; i < 15; i++) {
        float rel = zi - float(i);
        if (rel < -2.7 || rel > 2.0) continue;
        float w = smoothstep(-2.7, -1.35, rel) * (1.0 - smoothstep(0.80, 1.95, rel));
        if (w <= 0.002) continue;
        float ahead = smoothstep(-1.35, 0.0, rel);
        w *= 0.30 + 0.70 * ahead;
        w *= 1.0 - 0.48 * smoothstep(0.0, 1.1, rel);     // the passed shells recede into atmosphere
        float2 q = uv * exp2(float(i) - zi);
        float m = motif(i, q, uT, uBr, uSync, uWx, uHand, uSweep, uDwell, uRm, uRmCount);
        float rr = length(q);
        m += irim(rr, 0.012 + 0.02 * (1.0 - ahead)) * (0.30 + uBr * 0.10);
        col += HUES[i] * m * w;
    }
    col *= 0.86 + uBr * 0.20;
    col *= 1.0 - 0.42 * smoothstep(0.55, 1.5, r);
    col += HUES[14] * uReveal * (0.05 + 0.05 * uBr);
    col += (ihash(pos + fract(uT) * float2(53.0, 97.0)) - 0.5) * 0.022;
    col = col / (1.0 + col * 0.55);                      // tone-map
    float3 outc = pow(max(col, float3(0.0)), float3(0.88));   // gamma
    return half4(half3(outc), 1.0h);
}
