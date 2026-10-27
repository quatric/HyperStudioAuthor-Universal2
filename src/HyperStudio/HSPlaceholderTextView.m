#import "HSPlaceholderTextView.h"

@implementation HSPlaceholderTextView

// Replaces the markers of DefaultPlaceholderStyle.rtf with the two strings;
// the explanation (or, without one, everything after the placeholder) is
// replaced first so the first range stays valid.
- (void)rebuildCompositePlaceholderString
{
    [_compositePlaceholderAttributedString release];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:[@"DefaultPlaceholderStyle.rtf" stringByDeletingPathExtension] ofType:[@"DefaultPlaceholderStyle.rtf" pathExtension]];
    _compositePlaceholderAttributedString = [[NSMutableAttributedString alloc] initWithPath:path documentAttributes:nil];
    if (_compositePlaceholderAttributedString) {
        NSString *string = [_compositePlaceholderAttributedString string];
        NSRange placeholderRange = [string rangeOfString:@"<<placeholder>>"];
        NSRange explanationRange;
        if ([_explanationPlaceholderString length])
            explanationRange = [string rangeOfString:@"<<explanation_placeholder>>"];
        else
            explanationRange = NSMakeRange(NSMaxRange(placeholderRange), [_compositePlaceholderAttributedString length] - NSMaxRange(placeholderRange));
        [_compositePlaceholderAttributedString replaceCharactersInRange:explanationRange withString:_explanationPlaceholderString];
        [_compositePlaceholderAttributedString replaceCharactersInRange:placeholderRange withString:_placeholderString];
    } else {
        // (The original stores an immutable string in the mutable string's ivar.)
        _compositePlaceholderAttributedString = (NSMutableAttributedString *)[[NSAttributedString alloc] initWithString:@""];
    }
    [self setNeedsDisplayInRect:[self bounds]];
}

- (void)applyDefaultSettings
{
    _placeholderString = @"";
    _explanationPlaceholderString = @"";
    [self rebuildCompositePlaceholderString];
}

- (void)setCompositePlaceholderAttributedString:(id)aString
{
    if (_compositePlaceholderAttributedString != aString && aString) {
        [_compositePlaceholderAttributedString release];
        _compositePlaceholderAttributedString = [aString retain];
        [self setNeedsDisplayInRect:[self bounds]];
    }
}

- (id)compositePlaceholderAttributedString
{
    return _compositePlaceholderAttributedString;
}

- (void)setExplanationPlaceholderString:(id)aString
{
    if (![_explanationPlaceholderString isEqualToString:aString] && aString) {
        [_explanationPlaceholderString release];
        _explanationPlaceholderString = [aString retain];
        [self rebuildCompositePlaceholderString];
    }
}

- (id)explanationPlaceholderString
{
    return _explanationPlaceholderString;
}

- (void)setPlaceholderString:(id)aString
{
    if (![_placeholderString isEqualToString:aString] && aString) {
        [_placeholderString release];
        _placeholderString = [aString retain];
        [self rebuildCompositePlaceholderString];
    }
}

- (id)placeholderString
{
    return _placeholderString;
}

// An empty text view that is not being edited shows the placeholder, centred
// on a white background.
- (void)drawRect:(NSRect)aRect
{
    if ([[self textStorage] length] == 0 && !(_isViewFirstReponder && [self isEditable])) {
        [[NSColor whiteColor] set];
        [NSBezierPath fillRect:aRect];
        if (_compositePlaceholderAttributedString) {
            NSSize boundsSize = [self bounds].size;
            NSRect textRect = [_compositePlaceholderAttributedString boundingRectWithSize:boundsSize options:NSStringDrawingUsesLineFragmentOrigin];
            textRect.origin.y = (boundsSize.height - textRect.size.height) * 0.5f;
            textRect.origin.x = (boundsSize.width - textRect.size.width) * 0.5f;
            [_compositePlaceholderAttributedString drawWithRect:textRect options:NSStringDrawingUsesLineFragmentOrigin];
        }
    } else {
        [super drawRect:aRect];
    }
}

- (BOOL)acceptsFirstMouse:(id)aMouse
{
    return YES;
}

- (BOOL)resignFirstResponder
{
    BOOL resigned = [super resignFirstResponder];
    _isViewFirstReponder = !resigned;
    [self setNeedsDisplayInRect:[self bounds]];
    return resigned;
}

- (BOOL)acceptsFirstResponder
{
    BOOL accepts = [super acceptsFirstResponder];
    _isViewFirstReponder = accepts;
    [self setNeedsDisplayInRect:[self bounds]];
    return accepts;
}

- (void)dealloc
{
    [_compositePlaceholderAttributedString release];
    [_placeholderString release];
    [_explanationPlaceholderString release];
    [super dealloc];
}

- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self)
        [self applyDefaultSettings];
    return self;
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
        [self applyDefaultSettings];
    return self;
}

@end
