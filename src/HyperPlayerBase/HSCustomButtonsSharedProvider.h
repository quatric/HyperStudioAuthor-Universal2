#import "HyperPlayerBasePrefix.h"


@interface HSCustomButtonsSharedProvider : NSObject <HSCustomButtonsSharedProvider, NSObject>
{
    NSMutableArray *_customButtons;
    NSDictionary *_customButtonsSettingsDictionary;
    NSArray *_customButtonsOrderedList;
    NSDictionary *_backgroundSettings;
}
+ (id)customButtonsFolderName;
+ (id)resourcesPath;
+ (id)sharedCustomButtonsProvider;
- (id)texturedBackgroundImageForType:(NSInteger)aType prefix:(id)aPrefix atPath:(id)aPath;
- (id)texturedBackgroundImageSuffixForType:(NSInteger)aType nineParts:(BOOL)aParts;
- (NSSize)sizeForCustomButtonWithTexturedBackground:(id)aBackground;
- (id)backgroundSettingsForButtonWithMediaUID:(id)aUID;
- (id)backgroundSettings;
- (id)buttonSizeAttributeKey;
- (id)titleAttributeKey;
- (id)imagePositionAttributeKey;
- (id)borderedAttributeKey;
- (CGFloat)additionalHorizontalTitleSpaceForButtonWithMediaUID:(id)aUID;
- (BOOL)shouldTileMiddleBackgroundPartsForButtonWithMediaUID:(id)aUID;
- (BOOL)canResizeVerticallyBackgroundForButtonWithMediaUID:(id)aUID;
- (id)backgroundImagePartForButtonWithMediaUID:(id)aUID partType:(NSInteger)aType;
- (id)hyperCustomButtonDescriptionForName:(id)aName;
- (id)hyperCustomButtonImageForName:(id)aName;
- (id)hyperCustomButtonForName:(id)aName;
- (id)hyperCustomButtons;
- (id)customButtonsOrderedList;
- (id)customButtonsSettingsDictionary;
- (id)folderPath;
- (void)dealloc;
@end

@interface HSCustomButton : NSObject <HSCustomButton, NSObject, HSMediaAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSMediaObject>
{
    HSNewMedia *_media;
    NSString *_name;
}
- (id)imageUID;
- (id)imageRepresentation;
- (id)imageRepresentationType;
- (NSInteger)compareDecrease:(id)aDecrease;
- (NSInteger)compareIncrease:(id)aIncrease;
- (id)hyperCustomButtonPathName;
- (id)hyperCustomButtonName;
- (id)hyperCustomButtonTitle;
- (id)hyperCustomButtonImage;
- (void)dealloc;
- (id)media;
- (id)initWithMedia:(id)aMedia name:(id)aName;
- (id)initWithMedia:(id)aMedia error:(id *)aError;
- (id)initWithMedia:(id)aMedia;
@end

