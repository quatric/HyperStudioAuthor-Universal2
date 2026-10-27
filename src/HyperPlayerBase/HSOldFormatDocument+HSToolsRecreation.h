#import "HyperPlayerBasePrefix.h"
#import "HSOldFormatDocumentValidation.h"


@interface HSOldFormatDocument (HSToolsRecreation)
+ (id)recreationItemNameFromString:(id)aString;
+ (id)stringByTrimmingWhitespacesSuffixFromString:(id)aString;
- (void)debugStackCreation;
- (void)makeShapeButtonWithType:(id)aType origin:(NSPoint)aOrigin;
- (void)makeSystemButtonWithType:(id)aType origin:(NSPoint)aOrigin;
- (id)hyperLogoWords;
- (id)transitionsNew;
- (id)transitionsOld;
- (id)transitionsOldLowCase;
- (void)setOldCursorForObject:(id)aObject withOldCursorId:(NSInteger)aId;
- (NSUInteger)fontTraitMaskForFaceStyle:(NSUInteger)aStyle;
- (NSUInteger)fontTraitMaskForFaceStyle:(NSUInteger)aStyle applyToObject:(id)aObject;
- (id)actionObjectPathForApplePath:(id)aPath;
- (id)actionObjectPathForPath:(id)aPath;
- (id)pathForApplePath:(id)aPath;
- (id)stringForImportedData:(id)aData;
- (void)addHyperAction:(id)aAction to:(id)aTo;
- (void)addHyperActionOneItem:(id)aItem to:(id)aTo;
- (void)removeHyperAction:(id)aAction from:(id)aFrom;
- (short)shortSwapped:(short)aSwapped;
- (NSInteger)longSwapped:(NSInteger)aSwapped;
- (id)userInfoWithActionTypeForObject:(id)aObject key:(id)aKey;
- (void)setUserInfoWithActionTypeForObject:(id)aObject info:(id)aInfo key:(id)aKey;
- (id)userInfoWithActionKeyForKey:(id)aKey;
@end

