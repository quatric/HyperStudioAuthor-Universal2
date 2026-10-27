#import "HyperEditorBasePrefix.h"


@interface HSImagesProvider : NSObject
{
}
+ (id)sharedImagesProvider;
- (id)imageForName:(id)aName ofType:(id)aType inDirectory:(id)aDirectory inBundle:(id)aBundle;
- (id)imageForName:(id)aName ofType:(id)aType inDirectory:(id)aDirectory;
- (id)imageForName:(id)aName ofType:(id)aType;
- (id)imageForName:(id)aName;
@end

