#import "HyperStudioPrefix.h"
#import "HSAssistantPaneApplier.h"
#import "HSImageAssistantPane.h"


@interface HSButtonImageAssistantPane : HSImageAssistantPane
{
}
- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (id)HSButtonImageAssistantPane_applier;
- (Class)applierClass;
@end

@interface HSButtonImageAssistantPaneApplier : HSAssistantPaneApplier
{
    HSNewMedia *_initialMedia;
    NSSize _initialSize;
    HSNewMedia *_media;
    NSSize _size;
    id _sizeController;
    BOOL _ignoresSizeChanges;
}
- (void)objectSizeDidChange:(id)aChange;
- (void)setIgnoresSizeChanges:(BOOL)aChanges;
- (BOOL)ignoresSizeChanges;
- (void)setObjectSize:(NSSize)aSize;
- (NSSize)objectSize;
- (BOOL)areSettingsEqual;
- (BOOL)canApplyCurrentSettings;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setUpInitialSettings;
- (void)setMedia:(id)aMedia;
- (id)undoActionName;
- (id)mediaAttributes;
- (void)dealloc;
- (id)initWithObject:(id)aObject;
@end

