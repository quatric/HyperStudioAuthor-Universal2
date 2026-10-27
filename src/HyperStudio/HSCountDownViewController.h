#import "HyperStudioPrefix.h"


@interface HSCountDownViewController : NSObject
{
    id _delegate;
    NSTimer *_countDownTimer;
    id _currentTextField;
    id _previousTextField;
    BOOL _needToStop;
    NSView *_countDownView;
    NSTextField *_textField3;
    NSTextField *_textField2;
    NSTextField *_textField1;
}
- (void)updateCountDown:(id)aDown;
- (id)nextTextFieldForTextField:(id)aField;
- (void)removeCountDownTimer;
- (void)installCountDownTimer;
- (BOOL)isRunning;
- (void)stopRun;
- (void)runInView:(id)aView;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)awakeFromNib;
- (void)dealloc;
@end

