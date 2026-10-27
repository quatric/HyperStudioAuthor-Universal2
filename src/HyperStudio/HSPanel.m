#import "HSPanel.h"
#import <objc/message.h>

@implementation HSPanel

- (void)saveFrameUsingName:(id)aName
{
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(panel:saveFrameUsingName:)])
        ((void (*)(id, SEL, id, id))objc_msgSend)(delegate, @selector(panel:saveFrameUsingName:), self, aName);
    else
        [super saveFrameUsingName:aName];
}

- (BOOL)setFrameUsingName:(id)aName
{
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(panel:setFrameUsingName:)]
        && ((BOOL (*)(id, SEL, id, id))objc_msgSend)(delegate, @selector(panel:setFrameUsingName:), self, aName))
        return YES;
    return [super setFrameUsingName:aName];
}

@end
