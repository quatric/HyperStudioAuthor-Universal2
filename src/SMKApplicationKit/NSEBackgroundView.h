#import "SMKApplicationKitPrefix.h"


@interface NSEBackgroundView : NSView
{
    NSImage *_backgroundImage;
    NSColor *_backgroundColor;
    unsigned int _backgroundImageScaling;
    float _leftUnscaledBackgroundImageMargin;
    float _rightUnscaledBackgroundImageMargin;
    float _topUnscaledBackgroundImageMargin;
    float _bottomUnscaledBackgroundImageMargin;
}
- (void)drawRect:(NSRect)aRect;
- (BOOL)isOpaque;
- (void)setBottomUnscaledBackgroundImageMargin:(CGFloat)aMargin;
- (CGFloat)bottomUnscaledBackgroundImageMargin;
- (void)setTopUnscaledBackgroundImageMargin:(CGFloat)aMargin;
- (CGFloat)topUnscaledBackgroundImageMargin;
- (void)setRightUnscaledBackgroundImageMargin:(CGFloat)aMargin;
- (CGFloat)rightUnscaledBackgroundImageMargin;
- (void)setLeftUnscaledBackgroundImageMargin:(CGFloat)aMargin;
- (CGFloat)leftUnscaledBackgroundImageMargin;
- (void)setBackgroundImageScaling:(NSUInteger)aScaling;
- (NSUInteger)backgroundImageScaling;
- (void)setBackgroundColor:(id)aColor;
- (id)backgroundColor;
- (void)setBackgroundImage:(id)aImage;
- (id)backgroundImage;
- (void)dealloc;
@end

