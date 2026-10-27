#import "HSScriptSize.h"
@implementation HSScriptSize
// A script object with float "width" and "height" components.
+ (BOOL)getSize:(NSSize *)aSize fromScriptObject:(id)aObject
{
    if (![self isSizeObject:aObject])
        return NO;
    float width = [[aObject valueForKey:@"width"] floatValue];
    float height = [[aObject valueForKey:@"height"] floatValue];
    if (aSize != NULL) {
        aSize->width = width;
        aSize->height = height;
    }
    return YES;
}
+ (BOOL)isSizeObject:(id)aObject
{
    return [self scriptObject:aObject hasFloatComponentsNamed:[self sizeComponentsNames]];
}
static NSArray *sSizeComponentsNames;
+ (id)sizeComponentsNames
{
    if (sSizeComponentsNames == nil)
        sSizeComponentsNames = [[NSArray alloc] initWithObjects:@"width", @"height", nil];
    return sSizeComponentsNames;
}
// aSize when the object isn't a size.
+ (NSSize)sizeWithScriptObject:(id)aObject andOldSize:(NSSize)aSize
{
    NSSize size = NSZeroSize;
    if ([self getSize:&size fromScriptObject:aObject])
        aSize = size;
    return aSize;
}
+ (id)scriptSizeWithSize:(NSSize)aSize
{
    HSScriptSize *scriptSize = [[HSScriptSize new] autorelease];
    scriptSize->_width = aSize.width;
    scriptSize->_height = aSize.height;
    return scriptSize;
}
@end
