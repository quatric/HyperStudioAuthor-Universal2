#import "HSOldFormatDocumentValidation+HSOldFormatParserDelegate.h"
#import <objc/message.h>

// Each parsed value goes to the processBy... method named after its parent
// and its own name, if the document implements one.
typedef void (*HSProcess3)(id, SEL, id, id, id);
typedef void (*HSProcess4)(id, SEL, id, id, id, id);
typedef void (*HSProcess5)(id, SEL, id, id, id, id, id);

@implementation HSOldFormatDocumentValidation (HSOldFormatParserDelegate)
- (void)oldFormatParser:(id)aParser didDeriveSimpleValue:(id)aValue forName:(id)aName parentName:(id)aName2 parameters:(id)aParameters
{
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"processBy_%@_%@_WithParser:value:parameters:", aName2, aName]);
    if ([self respondsToSelector:selector]) {
        @autoreleasepool {
            ((HSProcess3)objc_msgSend)(self, selector, aParser, aValue, aParameters);
        }
    }
}
@end

@implementation HSOldFormatDocument (HSOldFormatParserDelegate)
- (void)oldFormatParser:(id)aParser didFinishParsingWithTypesTree:(id)aTree parsingType:(id)aType
{
    if (![self isCanceledByUser])
        [self processPostCorrection];
}
- (void)oldFormatParser:(id)aParser didDeriveSimpleValue:(id)aValue forName:(id)aName parentName:(id)aName2 parameters:(id)aParameters
{
    static NSString *lastParentName;
    if ([self isCanceledByUser])
        return;
    if (![aName2 isEqualToString:lastParentName]) {
        // the first value of a new parent
        [lastParentName release];
        lastParentName = [aName2 retain];
        SEL selector = NSSelectorFromString([NSString stringWithFormat:
            @"processFirstParentAppearance_%@_WithParser:value:forName:parameters:", aName2]);
        if ([self respondsToSelector:selector]) {
            @autoreleasepool {
                ((HSProcess4)objc_msgSend)(self, selector, aParser, aValue, aName, aParameters);
            }
        }
        selector = NSSelectorFromString(@"processFirstParentAppearanceWithParser:value:forName:parentName:parameters:");
        if ([self respondsToSelector:selector]) {
            @autoreleasepool {
                ((HSProcess5)objc_msgSend)(self, selector, aParser, aValue, aName, aName2, aParameters);
            }
        }
    }
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"processByParent_%@_WithParser:value:forName:parameters:", aName2]);
    if ([self respondsToSelector:selector]) {
        @autoreleasepool {
            ((HSProcess4)objc_msgSend)(self, selector, aParser, aValue, aName, aParameters);
        }
    }
    selector = NSSelectorFromString([NSString stringWithFormat:@"processBy_%@_%@_WithParser:value:parameters:", aName2, aName]);
    if ([self respondsToSelector:selector]) {
        @autoreleasepool {
            ((HSProcess3)objc_msgSend)(self, selector, aParser, aValue, aParameters);
        }
    }
}
@end
