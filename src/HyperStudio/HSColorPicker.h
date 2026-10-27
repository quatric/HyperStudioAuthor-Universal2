#import "HyperStudioPrefix.h"


@interface HSColorPicker : NSColorPicker <NSColorPickingCustom, NSColorPickingDefault>
{
    id _pickerView;
    NSImage *_colorPickerImage;
    BOOL _isDisabled;
}
- (void)setIsDisabled:(BOOL)aDisabled;
- (BOOL)isDisabled;
- (void)didLoadNib;
- (void)setColor:(id)aColor;
- (id)provideNewButtonImage;
- (id)buttonToolTip;
- (id)provideNewView:(BOOL)aView;
- (id)nibName;
- (id)imageName;
- (NSInteger)currentMode;
- (BOOL)supportsMode:(NSInteger)aMode;
- (void)dealloc;
- (id)initWithPickerMask:(NSUInteger)aMask colorPanel:(id)aPanel;
@end

