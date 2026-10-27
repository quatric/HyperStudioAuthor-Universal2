#import "HyperStudioPrefix.h"


@interface HSATemplateBrowseItem : NSObject
{
    NSImage *_image;
    NSString *_templateName;
    NSString *_title;
}
- (id)initWithPreviewImage:(id)aImage templateName:(id)aName title:(id)aTitle;
- (id)templateName;
- (id)imageUID;
- (id)imageRepresentationType;
- (id)imageRepresentation;
- (id)imageTitle;
- (void)dealloc;
@end
