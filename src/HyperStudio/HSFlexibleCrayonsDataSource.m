#import "HSFlexibleCrayonsDataSource.h"

@implementation HSFlexibleCrayonsDataSource

// The right 15% of columns is a gray ramp; the rest is a hue wheel that
// darkens toward the top rows and desaturates toward the bottom rows.
- (id)crayonsView:(id)aView colorForRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    NSInteger rows = [aView numberOfRows];
    float colorColumns = roundf((float)[aView numberOfColumns] * 0.85f);
    float row = (float)aRow + 1.0f;
    float column = (float)aColumn + 1.0f;
    if (colorColumns <= column) {
        float ramp = (column - colorColumns) / ((float)[aView numberOfColumns] - colorColumns);
        float white = (row / (float)[aView numberOfRows]) * (ramp + ramp - 1.0f) * 0.5f + 0.5f;
        return [NSColor colorWithCalibratedWhite:white alpha:1.0];
    }
    float half = (float)rows * 0.5f;
    float brightness = 1.0f, saturation = 1.0f;
    if (half > row)
        brightness = (1.0f - (half - row) / half) * 0.95f + 0.05f;
    if (row > half)
        saturation = (1.0f - (row - half) / half) * 0.45f + 0.55f;
    double hue = (double)aColumn;
    if (aRow & 1)
        hue += 0.5;
    hue /= (double)(colorColumns - 1.0f);
    return [NSColor colorWithCalibratedHue:(float)hue saturation:saturation brightness:brightness alpha:1.0];
}

- (BOOL)managesRowsAndColumnsCountForCrayonsView:(id)aView
{
    return NO;
}

@end
