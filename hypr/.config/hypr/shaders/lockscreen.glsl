// Cogitator Lockscreen Shader
// Simulates a cogitator entering secure standby:
//   - Screenshot is blurred upstream (blur_passes = 6) so content is unreadable
//   - Desaturated and recoloured to phosphor green
//   - Databend-style glitch artifacts: horizontal streaks, block corruption,
//     chromatic aberration — approximates the audio-glitch / databending look
//   - Scanlines and vignette finish the CRT effect

precision mediump float;

varying vec2 texcoord;
uniform sampler2D tex;
uniform float time;

// Deterministic hash — same result every render for a given UV position
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void main() {
    vec2 uv = texcoord;

    // ── Databend glitch ───────────────────────────────────────────────────────

    // Divide screen into coarse horizontal bands (~270 bands on 1080p)
    float bandY    = floor(uv.y * 270.0);
    float bandHash = hash(vec2(bandY, 3.7));

    // ~10% of bands get a horizontal streak (the databend smear)
    float streak = 0.0;
    if (bandHash > 0.90) {
        // Streak magnitude varies per band
        streak = (hash(vec2(bandY, 9.1)) - 0.5) * 0.06;
    }

    // ~3% of bands get a heavy corruption block (wrong data read)
    float corrupt = 0.0;
    if (bandHash > 0.97) {
        corrupt = (hash(vec2(bandY, 1.3)) - 0.5) * 0.18;
    }

    vec2 uvGlitch = uv + vec2(streak + corrupt, 0.0);

    // ── Chromatic aberration (RGB channel split) ───────────────────────────────
    // R and B sampled slightly offset — simulates magnetic head misalignment
    float ca = 0.0045;
    float r = texture2D(tex, uvGlitch + vec2( ca, 0.0)).r;
    float g = texture2D(tex, uvGlitch               ).g;
    float b = texture2D(tex, uvGlitch + vec2(-ca, 0.0)).b;

    vec4 color = vec4(r, g, b, 1.0);

    // ── Phosphor green conversion ──────────────────────────────────────────────
    float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb = vec3(0.0, luma * 0.80, 0.0);

    // Darken for standby mode
    color.rgb *= 0.45;

    // Additive phosphor glow
    color.rgb += vec3(0.0, 0.05, 0.0);

    // ── Analog noise grain ────────────────────────────────────────────────────
    float grain = (hash(uv * vec2(1920.0, 1080.0)) - 0.5) * 0.06;
    color.rgb += grain;

    // ── Scanlines — 3px period at 1080p ───────────────────────────────────────
    if (mod(floor(uv.y * 1080.0), 3.0) < 1.0) {
        color.rgb *= 0.45;
    }

    // ── Vignette ──────────────────────────────────────────────────────────────
    vec2 v = uv * 2.0 - 1.0;
    float vignette = 1.0 - dot(v, v) * 0.55;
    color.rgb *= clamp(vignette, 0.0, 1.0);

    gl_FragColor = vec4(clamp(color.rgb, 0.0, 1.0), 1.0);
}
