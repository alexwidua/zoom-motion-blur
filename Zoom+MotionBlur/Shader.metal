#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// ┌───────────┐
// │ Zoom Blur │
// └───────────┘
[[stitchable]] half4 zoom(float2 position, SwiftUI::Layer layer, float4 bounds, float strength) {
    const int samples = 50;

    float2 center = bounds.zw * 0.5;
    half3 accumulatedColor = half3(0.0);

    for (float i = 0; i <= samples; i++) {
            float normalizedIndex = float(i)/float(samples);
            accumulatedColor += layer.sample(position + (center - position) * normalizedIndex * strength).rgb / float(samples);
        }
    return half4(accumulatedColor, 1.0);
}

// ┌─────────────┐
// │ Motion Blur │
// └─────────────┘
[[stitchable]] half4 motion(float2 position, SwiftUI::Layer layer, float4 bounds, float strength, float angle) {
    const int samples = 50;

    float2 direction = float2(cos(angle), sin(angle)) * strength;

    half3 accumulatedColor = half3(0.0);
    const float delta = 2.0 / float(samples);
    for(float i = -1.0; i <= 1.0; i += delta) {
        float2 samplePosition = position + direction * i * bounds.zw;
        accumulatedColor += layer.sample(samplePosition).rgb * delta * 0.5;
    }
    
    return half4(accumulatedColor, 1.0);
}
