#import "NSCell+HSExtensions.h"

@implementation NSCell (HSExtensions)

// A copy of the cell as an instance of aClass, made by archiving it under
// that class's name.
+ (id)hyperCellOfClass:(Class)aClass withCell:(id)aCell
{
    id target = [(NSCell *)aCell target];
    SEL action = [(NSCell *)aCell action];
    NSMutableData *data = [[NSMutableData new] autorelease];
    NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archiver setClassName:NSStringFromClass(aClass) forClass:[aCell class]];
    [archiver encodeObject:aCell forKey:@"myCell"];
    [archiver finishEncoding];
    NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
    id cell = [unarchiver decodeObjectForKey:@"myCell"];
    [unarchiver finishDecoding];
    [(NSCell *)cell setTarget:target];
    [(NSCell *)cell setAction:action];
    return cell;
}

@end
