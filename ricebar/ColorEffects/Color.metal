//
//  Color.metal
//  ricebar
//
//  Created by Joy Liu on 11/16/24.
//

#include <metal_stdlib>
using namespace metal;

float oscillate(float f) {
    return 0.5 * (sin(f) + 1);
}

[[ stitchable ]]
half4 color(
    float2 position,
    half4 color
) {
    return half4(position.y/245.0, position.y/50.0, position.x/255.0, 1.0);
}


[[ stitchable ]]
half4 sizeAwareColor(float2 position, half4 color, float2 size) {
    return half4(position.x/size.x, position.y/size.y, position.x/size.y, 1.0);
}

[[ stitchable ]]
half4 timeVaryingColor_old(float2 position, half4 color, float2 size, float time) {
    return half4(0.0, oscillate(time + (2 * M_PI_F * position.x / size.x)), 0.0, 1.0);
}

[[ stitchable ]]
half4 timeVaryingColor(float2 position, half4 color, float2 size, float time) {
    half greenOscillation = oscillate(time + (2 * M_PI_F * position.x / size.x));
    
    return half4(
        color.r * greenOscillation * 1.5,
        color.g * greenOscillation * 2,
        color.b * greenOscillation * 3,
        color.a
    );
}

