#import "HyperPlayerBasePrefix.h"


@interface HSAutoOriginedPanel : NSPanel
{
    BOOL _readingFrameFromPrefereces;
}
- (void)setFrame:(NSRect)aFrame display:(BOOL)aDisplay;
- (BOOL)setFrameUsingName:(id)aName;
- (void)setFrameFromString:(id)aString;
@end

@interface HSAutoOriginedWindow : NSWindow
{
    BOOL _readingFrameFromPrefereces;
}
+ (NSRect)onscreenFrameUsingFrame:(NSRect)aFrame;
- (void)setFrame:(NSRect)aFrame display:(BOOL)aDisplay;
- (BOOL)setFrameUsingName:(id)aName;
- (void)setFrameFromString:(id)aString;
@end

