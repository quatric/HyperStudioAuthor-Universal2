#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSArduinoSetupActionAssistantPane : HSNBAAssistantPane <NSTableViewDataSource, NSObject>
{
    NSTableView *_pinConfigurationTableView;
    NSPopUpButton *_pinModePopUp;
    NSMenu *_analogPinModesMenu;
    NSMenu *_digitalPWMPinModesMenu;
    NSMenu *_digitalPinModesMenu;
    NSMenu *_noPinModeMenu;
    NSView *_pinValueView;
    NSView *_noPinValueView;
    NSView *_digitalPinValueView;
    NSMatrix *_digitalPinValueMatrix;
    NSView *_PWMPinValueView;
    NSSlider *_PWMPinValueSlider;
    NSTextField *_PWMPinValueTextField;
    NSStepper *_PWMPinValueSpepper;
    HSAppearanceButtonCell *_testButtonCell;
    struct __CFDictionary *_modeToTitleMap;
    NSMutableIndexSet *_indicesToReload;
    unsigned int _isPinConfigurationBeingUndoneOrRedone:1;
    unsigned int _isFinished:1;
    unsigned int _isReloadScheduled:1;
}
- (void)paneDidCancel:(id)aCancel;
- (void)paneDidOK:(id)aOK;
- (void)testAction:(id)aAction;
- (void)selectPinValue:(id)aValue;
- (void)changePinValue:(id)aValue;
- (void)changePinMode:(id)aMode;
- (void)tableViewSelectionDidChange:(id)aChange;
- (void)tableView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn row:(NSInteger)aRow;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (struct __CFDictionary *)HSArduinoSetupActionAssistantPane_modeToTitleMap;
- (id)initialKeyView;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionType;
- (Class)applierClass;
- (void)HSArdinoSetupActionAssistantPane_pinConfigurationWasUndoneOrRedone:(id)aRedone;
- (void)HSArdinoSetupActionAssistantPane_pinConfigurationWillBeUndoneOrRedone:(id)aRedone;
- (void)HSArdinoSetupActionAssistantPane_pinConfigurationDidChange:(id)aChange;
- (void)HSArdinoSetupActionAssistantPane_pinDidUpdate:(id)aUpdate;
- (void)HSArdinoSetupActionAssistantPane_reloadDataRarely;
- (void)HSArdinoSetupActionAssistantPane_arduinoDeviceConnectionStateDidChange:(id)aChange;
- (void)HSArdinoSetupActionAssistantPane_validateTestButton;
- (void)HSArdinoSetupActionAssistantPane_validateSelectedPin:(unsigned char)aPin isPinDigital:(BOOL)aDigital;
- (id)HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier;
- (void)awakeFromNib;
- (void)dealloc;
- (id)init;
@end

@interface HSArduinoSetupActionPaneApplier : HSActionAssistantSettingsApplier
{
    struct __CFDictionary *_initialDigitalPinConfigurationDictionary;
    struct __CFDictionary *_currentDigitalPinConfigurationDictionary;
    struct __CFDictionary *_initialAnalogPinConfigurationDictionary;
    struct __CFDictionary *_currentAnalogPinConfigurationDictionary;
}
- (void)resetPinConfigurationDictionary;
- (void)restorePinConfigurationDictionary;
- (void)removeConfigurationForAnalogPin:(unsigned char)aPin;
- (void)removeConfigurationForDigitalPin:(unsigned char)aPin;
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forAnalogPin:(unsigned char)aPin;
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forDigitalPin:(unsigned char)aPin;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setUpInitialSettings;
- (id)arduinoSetupActionAttributes;
- (void)dealloc;
@end

