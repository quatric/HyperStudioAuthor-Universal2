#import "HyperPlayerBasePrefix.h"


@interface HSOldFormatCreditsScrollNBA : NSObject
{
    NSData *_data;
    NSString *_textBoxName;
    int _speed;
    int _steps;
    int _pixels;
    BOOL _isScrollLines;
    BOOL _isScrollIgnoreClicks;
    BOOL _isScrollHorizontally;
    BOOL _parametersParsed;
    BOOL _parametersValid;
}
- (id)autoScrollAction;
- (id)targetTextBoxName;
- (void)setTargetTextBoxName:(id)aName;
- (void)parseParametersIfNeeded;
- (void)parseParametersFromBinaryData;
- (void)parseParametersFromStringData;
- (void)dealloc;
- (id)initWithData:(id)aData;
- (id)init;
@end

