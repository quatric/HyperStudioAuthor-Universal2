#import "HyperStudioPrefix.h"
#import "HSSelectionKnob.h"


@interface HSConcreteKnob : HSSelectionKnob
{
    NSImage *_activeStateImage;
    NSImage *_beingTrackedStateImage;
    NSImage *_beingTrackedActiveStateImage;
    struct HyperStudio_anon3 _cflags;
}
+ (id)beingTrackedActiveStateImage;
+ (id)activeStateImage;
+ (id)beingTrackedStateImage;
- (id)image;
- (void)setBeingTrackedActiveStateImage:(id)aImage;
- (id)beingTrackedActiveStateImage;
- (void)setBeingTrackedStateImage:(id)aImage;
- (id)beingTrackedStateImage;
- (void)setActiveStateImage:(id)aImage;
- (id)activeStateImage;
- (void)dealloc;
@end

