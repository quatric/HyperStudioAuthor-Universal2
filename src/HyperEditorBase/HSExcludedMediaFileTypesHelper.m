#import "HSExcludedMediaFileTypesHelper.h"

@implementation HSExcludedMediaFileTypesHelper

+ (id)excludedMediaFileTypes
{
    return [NSSet setWithObjects:@"sql", @"plist", nil];
}

@end
