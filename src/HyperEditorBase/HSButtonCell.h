#import "HyperEditorBasePrefix.h"


@interface HSButtonCell : NSButtonCell
{
    NSImage *_buttonImage;
    NSImage *_pushedButtonImage;
    NSImage *_disabledButtonImage;
    NSImage *_disabledPushedButtonImage;
}
- (void)loadDefaultImages;
- (void)applyDefaultSettings;
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)drawImage:(id)aImage withFrame:(NSRect)aFrame inView:(id)aView;
- (void)setDisabledPushedButtonImage:(id)aImage;
- (id)disabledPushedButtonImage;
- (void)setDisabledButtonImage:(id)aImage;
- (id)disabledButtonImage;
- (void)setPushedButtonImage:(id)aImage;
- (id)pushedButtonImage;
- (void)setButtonImage:(id)aImage;
- (id)buttonImage;
- (id)copyWithZone:(NSZone *)aZone;
- (void)encodeWithCoder:(id)aCoder;
- (id)initWithCoder:(id)aCoder;
- (void)dealloc;
@end

