#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSSetVolumeAction : HSNBAAction <HSSetVolumeActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSVolumeLevelAttribute>
{
    float _volumeLevel;
}
- (void)setVolumeLevel:(CGFloat)aLevel;
- (CGFloat)volumeLevel;
- (void)startInContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
@end

