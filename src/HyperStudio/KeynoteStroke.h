#import "HyperStudioPrefix.h"
#import "KeynoteObject.h"


@interface KeynoteStroke : KeynoteObject
{
    BOOL _isCalculated;
    float _width;
    NSColor *_color;
    NSArray *_patterns;
    float _patternPhase;
    NSString *_patternType;
}
- (void)setPatternType:(id)aType;
- (id)patternType;
- (void)setPatternPhase:(CGFloat)aPhase;
- (CGFloat)patternPhase;
- (void)setPatterns:(id)aPatterns;
- (id)patterns;
- (void)setColor:(id)aColor;
- (id)color;
- (void)setWidth:(CGFloat)aWidth;
- (CGFloat)width;
- (void)calculate;
- (void)didInitFromParser;
- (void)dealloc;
@end

