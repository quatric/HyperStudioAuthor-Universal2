#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSArduinoWatcherActionAssistantPane : HSNBAAssistantPane <NSOutlineViewDataSource, NSObject, NSOutlineViewDelegate, NSControlTextEditingDelegate, HSArduinoWatcherActionConfigurationDataSource>
{
    HSCheckBox *_currentCardObjectsCheckBox;
    NSOutlineView *_pinConfigurationRangeMappingsOutlineView;
    NSMutableParagraphStyle *_objectNameParagraphStyle;
    HSActionsPaneButtonBackgroundRenderer *_pinConfigurationRangesButtonBackgroundRenderer;
    id<HSNodeContainer> _selectedObjectCard;
    NSString *_selectedObjectUID;
    struct __CFDictionary *_selectedDigitalPinConfigurationRanges;
    struct __CFDictionary *_selectedAnalogPinConfigurationRanges;
    HSArduinoWatcherActionConfigurationAssistantPane *_configurationPane;
    unsigned int _arePinConfigurationRangeMappingsBeingUndoneOrRedone:1;
    unsigned int _isFinished:1;
    NSMutableArray *_availableCards;
    struct __CFDictionary *_availableObjectsOnCards;
    id<HSNodeChild> _currentObject;
}
- (void)paneDidCancel:(id)aCancel;
- (void)paneDidOK:(id)aOK;
- (void)toggleCurrentCardObjects:(id)aObjects;
- (void)actionPaneDidClose:(id)aClose withApplier:(id)aApplier canceled:(BOOL)aCanceled;
- (void)removeConfigurationRangeForAnalogPin:(unsigned char)aPin;
- (void)setMode:(NSInteger)aMode startValue:(unsigned short)aValue endValue:(unsigned short)aValue2 forAnalogPin:(unsigned char)aPin;
- (BOOL)getMode:(int *)aMode startValue:(unsigned short *)aValue endValue:(unsigned short *)aValue2 forAnalogPin:(unsigned char)aPin;
- (void)removeConfigurationRangeForDigitalPin:(unsigned char)aPin;
- (void)setMode:(NSInteger)aMode startValue:(unsigned short)aValue endValue:(unsigned short)aValue2 forDigitalPin:(unsigned char)aPin;
- (BOOL)getMode:(int *)aMode startValue:(unsigned short *)aValue endValue:(unsigned short *)aValue2 forDigitalPin:(unsigned char)aPin;
- (id)outlineView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn item:(id)aItem mouseLocation:(NSPoint)aLocation;
- (void)outlineView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn item:(id)aItem;
- (void)outlineView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn byItem:(id)aItem;
- (id)outlineView:(id)aView objectValueForTableColumn:(id)aColumn byItem:(id)aItem;
- (BOOL)outlineView:(id)aView isItemExpandable:(id)aExpandable;
- (id)outlineView:(id)aView child:(NSInteger)aChild ofItem:(id)aItem;
- (NSInteger)outlineView:(id)aView numberOfChildrenOfItem:(id)aItem;
- (id)HSArduinoWatcherActionAssistantPane_titleForItem:(id)aItem;
- (id)HSArduinoWatcherActionAssistantPane_availableCards;
- (BOOL)HSArduinoWatcherActionAssistantPane_hasActionsOnCard:(id)aCard;
- (id)HSArduinoWatcherActionAssistantPane_availableObjectsOnCard:(id)aCard;
- (id)initialKeyView;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionType;
- (Class)applierClass;
- (void)HSArduinoWatcherActionAssistantPane_cleanCaches;
- (void)HSArduinoWatcherActionAssistantPane_objectNameDidChange:(id)aChange;
- (NSUInteger)HSArduinoWatcherActionAssistantPane_indexToInsertObjectWithWeight:(id)aWeight toArray:(id)aArray containsObject:(BOOL *)aObject;
- (void)HSArduinoWatcherActionAssistantPane_objectAttributeDidChange:(id)aChange;
- (void)HSArduinoWatcherActionAssistantPane_pinConfigurationRangeMappingsWasUndoneOrRedone:(id)aRedone;
- (void)HSArduinoWatcherActionAssistantPane_pinConfigurationRangeMappingsWillBeUndoneOrRedone:(id)aRedone;
- (void)HSArduinoWatcherActionAssistantPane_pinConfigurationRangeMappingsDidChange:(id)aChange;
- (void)HSArduinoWatcherActionAssistantPane_objectsWillChange:(id)aChange;
- (void)HSArduinoWatcherActionAssistantPane_cardsDidChange:(id)aChange;
- (void)HSArduinoWatcherActionAssistantPane_removeObserversFromStack:(id)aStack;
- (void)HSArduinoWatcherActionAssistantPane_addObservers;
- (id)HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier;
- (id)stack;
- (id)card;
- (void)viewDidLoad;
- (void)dealloc;
- (id)init;
@end

@interface HSArduinoWatcherActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    struct __CFDictionary *_initialDigitalPinConfigurationRangeMappings;
    struct __CFDictionary *_currentDigitalPinConfigurationRangeMappings;
    struct __CFDictionary *_initialAnalogPinConfigurationRangeMappings;
    struct __CFDictionary *_currentAnalogPinConfigurationRangeMappings;
}
- (void)resetPinConfigurationRangeMappings;
- (void)restorePinConfigurationRangeMappings;
- (void)synchronizePinConfigurationRangesForObjectWithUID:(id)aUID;
- (void)removePinConfigurationRangesForObjectWithUID:(id)aUID;
- (void)setDigitalPinConfigurationRanges:(struct __CFDictionary *)aRanges analogPinConfigurationRanges:(struct __CFDictionary *)aRanges2 forObjectWithUID:(id)aUID;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setUpInitialSettings;
- (id)arduinoWatcherActionAttributes;
- (void)dealloc;
@end

