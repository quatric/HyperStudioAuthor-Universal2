#import "HyperStudioPrefix.h"
#import "HSNBAAssistantPane.h"


@interface HSArduinoWatcherActionConfigurationAssistantPane : HSNBAAssistantPane <NSTableViewDataSource, NSObject, NSTextFieldDelegate, NSControlTextEditingDelegate>
{
    NSTableView *_pinConfigurationRangesTableView;
    NSImage *_grayStatusImage;
    NSImage *_greenStatusImage;
    NSImage *_redStatusImage;
    HSPopUpButton *_pinModePopUp;
    NSMenu *_analogPinModesMenu;
    NSMenu *_digitalPWMPinModesMenu;
    NSMenu *_digitalPinModesMenu;
    NSMenu *_noPinModeMenu;
    NSView *_pinValueRangeView;
    NSView *_noPinValueRangeView;
    NSView *_digitalPinValueView;
    NSMatrix *_digitalPinValueMatrix;
    NSView *_analogAndPWMPinValueRangeView;
    NSTextField *_analogAndPWMPinStartValueTextField;
    HSStepper *_analogAndPWMPinStartValueSpepper;
    NSTextField *_analogAndPWMPinEndValueTextField;
    HSStepper *_analogAndPWMPinEndValueSpepper;
    id<HSArduinoWatcherActionConfigurationDataSource> _dataSource;
    struct __CFDictionary *_modeToTitleMap;
    NSMutableIndexSet *_indicesToReload;
    BOOL _isReloadScheduled;
}
- (void)selectPinValue:(id)aValue;
- (void)changePinEndValue:(id)aValue;
- (void)changePinStartValue:(id)aValue;
- (void)selectPinMode:(id)aMode;
- (BOOL)control:(id)aControl isValidObject:(id)aObject;
- (void)tableViewSelectionDidChange:(id)aChange;
- (void)tableView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn row:(NSInteger)aRow;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (id)HSArduinoWatcherActionConfigurationAssistantPane_redStatusImage;
- (id)HSArduinoWatcherActionConfigurationAssistantPane_greenStatusImage;
- (id)HSArduinoWatcherActionConfigurationAssistantPane_grayStatusImage;
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (struct __CFDictionary *)HSArduinoWatcherActionConfigurationAssistantPane_modeToTitleMap;
- (void)HSArdinoWatcherActionConfigurationAssistantPane_pinDidUpdate:(id)aUpdate;
- (void)HSArdinoWatcherActionConfigurationAssistantPane_reloadDataRarely;
- (void)HSArdinoWatcherActionConfigurationAssistantPane_arduinoDeviceConnectionStateDidChange:(id)aChange;
- (void)notePinConfigurationRangesChanged;
- (void)notePinConfigurationRangeChangedForPin:(unsigned char)aPin isPinDigital:(BOOL)aDigital;
- (void)setDataSource:(id)aSource;
- (id)dataSource;
- (id)initialKeyView;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)windowTitle;
- (id)helpActionType;
- (id)actionType;
- (Class)applierClass;
- (void)HSArduinoWatcherActionConfigurationAssistantPane_validateSelectedPin:(unsigned char)aPin isPinDigital:(BOOL)aDigital;
- (void)awakeFromNib;
- (void)dealloc;
- (id)init;
@end

