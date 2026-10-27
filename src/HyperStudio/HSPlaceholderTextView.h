#import "HyperStudioPrefix.h"


@interface HSPlaceholderTextView : NSTextView
{
    NSMutableAttributedString *_compositePlaceholderAttributedString;
    NSString *_placeholderString;
    NSString *_explanationPlaceholderString;
    BOOL _isViewFirstReponder;
}
- (void)rebuildCompositePlaceholderString;
- (void)applyDefaultSettings;
- (void)setCompositePlaceholderAttributedString:(id)aString;
- (id)compositePlaceholderAttributedString;
- (void)setExplanationPlaceholderString:(id)aString;
- (id)explanationPlaceholderString;
- (void)setPlaceholderString:(id)aString;
- (id)placeholderString;
- (void)drawRect:(NSRect)aRect;
- (BOOL)acceptsFirstMouse:(id)aMouse;
- (BOOL)resignFirstResponder;
- (BOOL)acceptsFirstResponder;
- (void)dealloc;
- (id)initWithCoder:(id)aCoder;
- (id)initWithFrame:(NSRect)aFrame;
@end

