#import "HyperStudioPrefix.h"


@interface HSPseudoImageView : HSTexturedView
{
}
+ (id)bottomTextureImage;
+ (id)middleTextureImage;
+ (id)topTextureImage;
+ (id)pathForResource:(id)aResource ofType:(id)aType;
- (id)initWithFrame:(NSRect)aFrame;
@end

