#import "HyperStudioPrefix.h"
#import "KeynoteLineEndContainer.h"


@interface KeynoteShape : KeynoteLineEndContainer <KeynoteTextContainer, NSObject, KeynoteBezierPathContainer>
{
    NSMutableAttributedString *_text;
    NSMutableArray *_links;
}
- (NSUInteger)verticalAlignment;
- (id)textBackgroundColor;
- (id)text;
- (id)allLinks;
- (BOOL)exportsText;
- (id)bezierPath;
- (id)keynoteBezier;
- (id)defaultBezierPath;
- (id)tailLineEnd;
- (id)headLineEnd;
- (BOOL)isLine;
- (BOOL)exportsBezierPath;
- (void)didDetail;
- (void)verifyLinks;
- (void)dealloc;
@end

