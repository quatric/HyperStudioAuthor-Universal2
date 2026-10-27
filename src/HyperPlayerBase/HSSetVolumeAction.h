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
- (id)XMLElementName;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)supportedInIPad;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
@end

