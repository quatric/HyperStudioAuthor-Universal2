#import "HSAnimationSetupCropSelectedGraphicAssistantPane.h"

@interface NSObject (HSAnimationSetupCropSelectedGraphicAssistantPaneDelegateMethods)
- (void)cropTemporaryObject:(id)anObject options:(id)anOptions forAssistantPane:(id)aPane shouldProceedWithMode:(NSInteger)aMode;
- (void)unprepareCroppingForAssistantPane:(id)aPane temporaryObject:(id)anObject;
- (id)prepareToCroppingForAssistantPane:(id)aPane image:(id)anImage options:(id)anOptions;
@end

@implementation HSAnimationSetupCropSelectedGraphicAssistantPane

- (void)selectCardPartUsingLasso:(id)aLasso
{
    [self proceedWithMode:2];
}

- (void)selectCircleCardPart:(id)aPart
{
    [self proceedWithMode:1];
}

- (void)selectSquireCardPart:(id)aPart
{
    [self proceedWithMode:0];
}

- (void)proceedWithMode:(NSInteger)aMode
{
    [_delegate cropTemporaryObject:_temporaryObject options:_imageOptions forAssistantPane:self shouldProceedWithMode:aMode];
}

- (void)releaseTemporaryObject
{
    [_temporaryObject release];
    _temporaryObject = nil;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    [_image release];
    [_imageOptions release];
    [_temporaryObject release];
    [_paneSwitcher release];
    [super dealloc];
}

- (id)initWithImage:(id)aImage options:(id)aOptions
{
    self = [super initWithNibName:@"CropSelectedImagePane"];
    if (self) {
        _image = [aImage retain];
        _imageOptions = [aOptions retain];
    }
    return self;
}

- (void)dismiss:(BOOL)aDismiss slide:(BOOL)aSlide
{
    [_delegate unprepareCroppingForAssistantPane:self temporaryObject:_temporaryObject];
    [super dismiss:aDismiss slide:aSlide];
}

- (void)paneWillGoBack:(id)aBack
{
    [self dismiss:YES];
}

- (void)paneContinue:(id)aContinue
{
    [_delegate cropTemporaryObject:_temporaryObject options:_imageOptions forAssistantPane:self shouldProceedWithMode:3];
}

- (id)navigationPaneSwitcher
{
    if (!_paneSwitcher) {
        _paneSwitcher = [HSActionsPaneGoBackContinueSwitcher new];
        [_paneSwitcher setDelegate:self];
    }
    return _paneSwitcher;
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [_paneSwitcher setCanContinue:YES];
    if (!_temporaryObject)
        _temporaryObject = [[_delegate prepareToCroppingForAssistantPane:self image:_image options:_imageOptions] retain];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    id renderer = [HSAssistantLargeButtonBackgroundRenderer sharedBackgroundRenderer];
    [[_selectSquireCardPartButton cell] setBackgroundRenderer:renderer];
    [[_selectCircleCardPartButton cell] setBackgroundRenderer:renderer];
    [[_selectCardPartUsingLassoButton cell] setBackgroundRenderer:renderer];
}

@end
