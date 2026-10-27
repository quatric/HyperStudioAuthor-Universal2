#import "HSATemplateBrowseItem.h"
#import <Quartz/Quartz.h>

@implementation HSATemplateBrowseItem

- (id)initWithPreviewImage:(id)aImage templateName:(id)aName title:(id)aTitle
{
    self = [super init];
    if (self != nil) {
        _image = [aImage retain];
        _templateName = [aName retain];
        _title = [aTitle retain];
    }
    return self;
}

- (void)dealloc
{
    [_image release];
    [_templateName release];
    [super dealloc];
}

- (id)templateName
{
    return _templateName;
}

- (id)imageUID
{
    return _templateName;
}

- (id)imageRepresentationType
{
    return IKImageBrowserNSImageRepresentationType;
}

- (id)imageRepresentation
{
    return _image;
}

- (id)imageTitle
{
    return _title;
}

@end
