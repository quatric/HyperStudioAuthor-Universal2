// Plain C functions of the original binary. The callbacks and comparators
// live with their callers; what remains here are the exported helpers.
#import "HyperEditorBasePrefix.h"

// Maps a slider's linear position onto a quadratic curve over its range.
float HSNonLinearValueForSlider(NSSlider *aSlider)
{
    float minValue = [aSlider minValue];
    float maxValue = [aSlider maxValue];
    float position = ([aSlider floatValue] - minValue) / (maxValue - minValue) * 37.0f + 8.0f;
    return (position * position * 0.01f + -0.64f) / 19.61f * (maxValue - minValue) + minValue;
}

// The inverse of HSNonLinearValueForSlider.
float HSLinearValueForSliderFromNonLinear(NSSlider *aSlider, float aValue)
{
    float minValue = [aSlider minValue];
    float maxValue = [aSlider maxValue];
    float position = sqrtf(((aValue - minValue) / (maxValue - minValue) * 19.61f + 0.64f) / 0.01f);
    return (position + -8.0f) / 37.0f * (maxValue - minValue) + minValue;
}
