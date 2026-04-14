// Matrix rain — pure generative, ignores the screenshot tex entirely
// hyprlock passes tex + time; we only use time.

precision mediump float;

varying vec2 texcoord;
uniform sampler2D tex;   // required by hyprlock — not sampled
uniform float time;

float h11(float p) {
    return fract(sin(p * 127.1) * 43758.5453);
}

float h21(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void main() {
    vec2 uv = texcoord;

    // ── Character grid ────────────────────────────────────────────────────────
    // 72 columns; rows derived from 16:9 + character aspect ratio
    const float COLS  = 72.0;
    const float CASPECT = 2.1;                         // char height/width
    float rows = floor(COLS * CASPECT * (9.0 / 16.0)); // ≈ 85 rows

    float col = floor(uv.x * COLS);
    float row = floor(uv.y * rows);

    // ── Per-column properties (static randomness) ─────────────────────────────
    float speed = 0.8 + h11(col)          * 1.8;   // rows per second
    float phase = h11(col + 100.0)        * 80.0;  // stagger
    float tlen  = 8.0 + h11(col + 200.0) * 14.0;  // trail length

    // ── Animated head position ────────────────────────────────────────────────
    float head = mod((time + phase) * speed, rows + tlen) - tlen;
    float d    = row - head;   // 0 = head, positive = in trail

    float bright = 0.0;
    if (d >= 0.0 && d < tlen)
        bright = pow(1.0 - d / tlen, 1.8);

    float isHead = (d >= 0.0 && d < 1.0) ? 1.0 : 0.0;

    // ── Simulated character mask (4×7 sub-pixels per cell) ───────────────────
    vec2 cellUV = vec2(fract(uv.x * COLS), fract(uv.y * rows));
    float px    = floor(cellUV.x * 4.0);
    float py    = floor(cellUV.y * 7.0);
    float charT = floor(time * speed * 0.4 + col * 3.7);
    float mask  = step(0.3, h21(vec2(px + charT, py + col)));

    // ── Colour ────────────────────────────────────────────────────────────────
    vec3 matGreen = vec3(0.0, 0.94, 0.06);

    vec3 c = matGreen * bright * (isHead > 0.5 ? 1.0 : mask);

    // Head flashes near-white
    c = mix(c, vec3(0.82, 1.0, 0.82) * bright, isHead);

    // Faint random sparkle on idle cells
    float sparkle = step(0.997, h21(vec2(col, row + floor(time * 4.0))));
    c += vec3(0.0, sparkle * 0.18, 0.0);

    gl_FragColor = vec4(clamp(c, 0.0, 1.0), 1.0);
}
