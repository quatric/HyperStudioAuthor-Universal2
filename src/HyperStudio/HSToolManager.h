#import "HyperStudioPrefix.h"


@interface HSToolManager : NSObject
{
    int _previousToolTag;
    int _selectedToolTag;
    HSTool *_currentTool;
    HSToolView *_toolView;
    BOOL _isToolSetAsPermanent;
    int _currentToolSet;
    NSSet *_buttonShapeCreationToolIdentifiers;
}
+ (NSInteger)defaultToolTag;
+ (id)sharedToolManager;
+ (id)vectorToBitmapToolMap;
+ (id)bitmapToVectorToolMap;
+ (id)bitmapToolForTag:(NSInteger)aTag;
+ (void)HSToolManager_setBackgroundModeForRegionEditingTool:(id)aTool;
+ (void)HSToolManager_setSelectionEditingCursorsForTool:(id)aTool;
+ (id)toolIdentifiersForToolSet:(NSInteger)aSet;
+ (Class)toolClassForTag:(NSInteger)aTag;
+ (id)bitmapToolIdentifiers;
+ (id)vectorToolIdentifiers;
+ (NSInteger)toolTagForIdentifier:(id)aIdentifier;
+ (BOOL)canSelectToolWithTag:(NSInteger)aTag;
+ (id)toolIdentifierForTag:(NSInteger)aTag;
- (NSInteger)toolForPastingPasteboardContents:(id)aContents;
- (void)preferencesDidChange:(id)aChange;
- (void)toolSettingsDidChange:(id)aChange;
- (id)toolSettings;
- (void)atomOperationPerformedWithResult:(BOOL)aResult;
- (BOOL)canSelectToolWithTag:(NSInteger)aTag;
- (void)selectToolWithTag:(NSInteger)aTag setAsPermanent:(BOOL)aPermanent forceSelection:(BOOL)aSelection explicitly:(BOOL)aExplicitly;
- (void)selectToolWithTag:(NSInteger)aTag setAsPermanent:(BOOL)aPermanent forceSelection:(BOOL)aSelection;
- (id)toolWithTag:(NSInteger)aTag;
- (void)selectToolWithTag:(NSInteger)aTag setAsPermanent:(BOOL)aPermanent;
- (void)selectToolWithTag:(NSInteger)aTag;
- (NSInteger)selectedToolTag;
- (id)currentTool;
- (void)validateCurrentToolSet;
- (void)setCurrentToolSet:(NSInteger)aSet;
- (NSInteger)currentToolSet;
- (void)setToolView:(id)aView;
- (id)toolView;
- (void)dealloc;
- (void)setupInitial;
- (id)buttonShapeCreationToolIdentifiers;
@end

