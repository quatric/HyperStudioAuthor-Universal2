#import "HSPlayMovieTableView.h"
#import <objc/message.h>

@implementation HSPlayMovieTableView

// Delete and forward delete go to the delegate when it handles them.
- (void)keyDown:(id)aDown
{
    unsigned short keyCode = [(NSEvent *)aDown keyCode];
    if ((keyCode == 0x33 || keyCode == 0x75) && [[self delegate] respondsToSelector:@selector(deleteKeyPressedInTableView:)]) {
        ((void (*)(id, SEL, id))objc_msgSend)([self delegate], @selector(deleteKeyPressedInTableView:), self);
        return;
    }
    [super keyDown:aDown];
}

@end
