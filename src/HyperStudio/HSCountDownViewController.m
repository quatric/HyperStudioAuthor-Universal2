#import "HSCountDownViewController.h"

@implementation HSCountDownViewController

- (void)updateCountDown:(id)aDown
{
    if (_needToStop) {
        if ([_delegate respondsToSelector:@selector(countDownWillEnd:)])
            [_delegate countDownWillEnd:self];
        [self stopRun];
        if ([_delegate respondsToSelector:@selector(countDownDidEnd:)])
            [_delegate countDownDidEnd:self];
        return;
    }
    [_previousTextField setTextColor:[NSColor colorWithCalibratedRed:227.0 / 255.0 green:90.0 / 255.0 blue:90.0 / 255.0 alpha:1.0]];
    [_currentTextField setTextColor:[NSColor whiteColor]];
    _previousTextField = _currentTextField;
    _currentTextField = [self nextTextFieldForTextField:_currentTextField];
    if (_previousTextField != nil && _currentTextField == nil)
        _needToStop = YES;
}

- (id)nextTextFieldForTextField:(id)aField
{
    if (aField == nil)
        return _textField3;
    if (aField == _textField3)
        return _textField2;
    if (aField == _textField2)
        return _textField1;
    return nil;
}

- (void)removeCountDownTimer
{
    if (_countDownTimer != nil) {
        [_countDownTimer invalidate];
        [_countDownTimer release];
        _countDownTimer = nil;
    }
}

- (void)installCountDownTimer
{
    [self removeCountDownTimer];
    _countDownTimer = [[NSTimer timerWithTimeInterval:1.0 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(updateCountDown:) userInfo:nil repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:_countDownTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:_countDownTimer forMode:NSEventTrackingRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:_countDownTimer forMode:NSModalPanelRunLoopMode];
}

- (BOOL)isRunning
{
    return _countDownTimer != nil;
}

- (void)stopRun
{
    [self removeCountDownTimer];
    if ([_countDownView superview] != nil)
        [_countDownView removeFromSuperview];
}

- (void)runInView:(id)aView
{
    if (_countDownView == nil) {
        NSString *nibName = @"CountDownView";
        if ([[self delegate] respondsToSelector:@selector(nibNameForCountDownViewController:)])
            nibName = [[self delegate] nibNameForCountDownViewController:self];
        [NSBundle loadNibNamed:nibName owner:self];
    }
    [_textField3 setTextColor:[NSColor colorWithCalibratedRed:227.0 / 255.0 green:90.0 / 255.0 blue:90.0 / 255.0 alpha:1.0]];
    [_textField2 setTextColor:[NSColor colorWithCalibratedRed:227.0 / 255.0 green:90.0 / 255.0 blue:90.0 / 255.0 alpha:1.0]];
    [_textField1 setTextColor:[NSColor colorWithCalibratedRed:227.0 / 255.0 green:90.0 / 255.0 blue:90.0 / 255.0 alpha:1.0]];
    _currentTextField = _textField3;
    _previousTextField = nil;
    _needToStop = NO;
    [_countDownView setFrameOrigin:NSZeroPoint];
    [_countDownView setFrameSize:[aView frame].size];
    [aView addSubview:_countDownView];
    [self installCountDownTimer];
}

- (void)setDelegate:(id)aDelegate
{
    if (_delegate != aDelegate)
        _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)awakeFromNib
{
}

- (void)dealloc
{
    [self removeCountDownTimer];
    if ([_countDownView superview] != nil)
        [_countDownView removeFromSuperview];
    [_countDownView release];
    [super dealloc];
}

@end
