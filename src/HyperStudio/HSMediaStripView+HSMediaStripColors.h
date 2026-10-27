#import "HyperStudioPrefix.h"
#import "HSMediaStripView.h"


@interface HSMediaStripView (HSMediaStripColors)
+ (id)activeOutlineBackgroundColor;
+ (id)activeOutlineColor;
+ (id)dropIndicatorColor;
+ (id)textColorSelected:(BOOL)aSelected firstResponder:(BOOL)aResponder;
+ (id)imageBorderColorSelected:(BOOL)aSelected firstResponder:(BOOL)aResponder;
+ (id)borderColor;
+ (id)bezelColor;
+ (id)stripBackgroundColor;
@end

