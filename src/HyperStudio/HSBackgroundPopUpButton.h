#import "HyperStudioPrefix.h"


@interface HSBackgroundPopUpButton : SMKBackgroundPopUpButton
{
    NSImage *_regularImage;
    NSImage *_smallImage;
    NSImage *_miniImage;
}
- (NSUInteger)controlSize;
- (void)setControlSize:(NSUInteger)aSize;
- (void)synchronizeImagesWithControlSize:(NSUInteger)aSize;
- (void)setMiniImage:(id)aImage;
- (id)miniImage;
- (void)setSmallImage:(id)aImage;
- (id)smallImage;
- (void)setRegularImage:(id)aImage;
- (id)regularImage;
@end

