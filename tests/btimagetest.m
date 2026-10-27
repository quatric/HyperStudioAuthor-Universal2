// SMKBitmapTools images: BTCGImage purge and reload, BTCGBitmapLayer edits
// and pixel colours, BTMutableCGImageUndoer undo/redo (also grouped, through
// the purgeable-object wrappers), NSColor -> CGColor.
#import "SMKBitmapToolsPrefix.h"
#import "BTCGImageSaver.h"
#import "BTCGBitmapLayer.h"
#import "BTMutableCGImageUndoer.h"
#import "BTObjectWrapperForUndoManagerList.h"
#import "NSColor+BTCGExtensions.h"
#import "NSImageRep_BTImage_BTCocoaImageRep.h"

static int failures;
#define CHECK(...) do { if (!(__VA_ARGS__)) { printf("FAIL %s:%d %s\n", __FILE__, __LINE__, #__VA_ARGS__); failures++; } } while (0)

static BOOL ColorIs(CGColorRef color, CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
    if (!color || CGColorGetNumberOfComponents(color) != 4)
        return NO;
    const CGFloat *c = CGColorGetComponents(color);
    return fabs(c[0] - r) < 0.01 && fabs(c[1] - g) < 0.01 && fabs(c[2] - b) < 0.01 && fabs(c[3] - a) < 0.01;
}

@interface UndoDelegate : NSObject
{
@public
    NSUndoManager *undoManager;
    int changes;
}
@end

@implementation UndoDelegate
- (id)prepareUndoForImageUndoer:(id)undoer withInvocationTarget:(id)target
{
    return [undoManager BT_prepareWithInvocationTarget:target];
}
- (void)imageUndoer:(id)undoer willChangeImageInRect:(CGRect)rect
{
}
- (void)imageUndoer:(id)undoer didChangeImageInRect:(CGRect)rect
{
    changes++;
}
@end

static void Fill(BTCGBitmapLayer *layer, CGRect rect, CGFloat r, CGFloat g, CGFloat b)
{
    [layer beginCGEditing];
    CGContextSetRGBFillColor([layer imageCGContext], r, g, b, 1);
    CGContextFillRect([layer imageCGContext], rect);
    [layer endCGEditing];
}

int main(void)
{
    @autoreleasepool {
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();

        // BTCGImage from bitmap data: purge after the data is saved, then reload.
        NSMutableData *data = [NSMutableData dataWithLength:4 * 4 * 4];
        uint8_t *p = [data mutableBytes];
        for (int i = 0; i < 16; i++) {
            p[i * 4] = 255;     // A
            p[i * 4 + 1] = 255; // R
        }
        BTCGImage *image = [[BTCGImage alloc] initWithBitmapData:data width:4 height:4 bitsPerComponent:8 bitsPerPixel:32
                                                     bytesPerRow:16 colorSpace:rgb
                                                      bitmapInfo:kCGImageAlphaPremultipliedFirst decode:NULL
                                               shouldInterpolate:NO intent:kCGRenderingIntentDefault];
        CHECK(CGSizeEqualToSize([image imageSize], CGSizeMake(4, 4)));
        CHECK(ColorIs([image colorAtPoint:CGPointMake(1, 1)], 1, 0, 0, 1));
        CHECK([image colorAtPoint:CGPointMake(4, 0)] == NULL);
        [image prepareToPurge];
        [image purge];
        for (int i = 0; i < 200; i++) {
            NSString *file = [image valueForKey:@"_fileName"];
            if (file)
                break;
            usleep(10000);
        }
        NSString *file = [[[image valueForKey:@"_fileName"] retain] autorelease];
        CHECK(file && [[NSFileManager defaultManager] fileExistsAtPath:file]);
        CHECK([image valueForKey:@"_bitmapData"] == nil);
        CHECK([image image] != NULL && ColorIs([image colorAtPoint:CGPointMake(3, 3)], 1, 0, 0, 1));
        [image release];
        for (int i = 0; i < 200 && [[NSFileManager defaultManager] fileExistsAtPath:file]; i++)
            usleep(10000);
        CHECK(![[NSFileManager defaultManager] fileExistsAtPath:file]);

        // A bitmap layer: edits show in its image; raw ARGB colour lookup.
        CGContextRef context = CGBitmapContextCreate(NULL, 8, 8, 8, 0, rgb, kCGImageAlphaPremultipliedFirst);
        BTCGBitmapLayer *layer = [BTCGBitmapLayer bitmapLayerWithCGContext:context decode:NULL format:-1 colorProfile:NULL];
        CGContextRelease(context);
        Fill(layer, CGRectMake(0, 0, 8, 8), 0, 0, 1);
        CHECK(ColorIs([layer colorAtPoint:CGPointMake(2, 2)], 0, 0, 1, 1));
        CGImageRef before = [layer coreGraphicsImage];
        CHECK(before && before == [layer coreGraphicsImage]);

        // Undo and redo through the undoer, with BTCGImage copies held by wrappers.
        NSUndoManager *undoManager = [[[NSUndoManager alloc] init] autorelease];
        [undoManager setGroupsByEvent:NO];
        UndoDelegate *delegate = [[[UndoDelegate alloc] init] autorelease];
        delegate->undoManager = undoManager;
        BTMutableCGImageUndoer *undoer = [[layer createImageUndoerWithDelegate:delegate] autorelease];
        [undoManager beginUndoGrouping];
        [undoer registerUndoInRect:CGRectMake(0, 4, 8, 4)];
        Fill(layer, CGRectMake(0, 4, 8, 4), 0, 1, 0);
        [undoManager endUndoGrouping];
        CHECK(ColorIs([layer colorAtPoint:CGPointMake(1, 6)], 0, 1, 0, 1));
        CHECK(ColorIs([layer colorAtPoint:CGPointMake(1, 1)], 0, 0, 1, 1));
        [undoManager undo];
        CHECK(ColorIs([layer colorAtPoint:CGPointMake(1, 6)], 0, 0, 1, 1));
        [undoManager redo];
        CHECK(ColorIs([layer colorAtPoint:CGPointMake(1, 6)], 0, 1, 0, 1));
        CHECK(delegate->changes == 2);

        // Grouped: two changes, one undo of their union.
        [undoManager beginUndoGrouping];
        [undoer beginUndoGrouping];
        [undoer registerUndoInRect:CGRectMake(0, 0, 2, 2)];
        Fill(layer, CGRectMake(0, 0, 2, 2), 1, 1, 1);
        [undoer registerUndoInRect:CGRectMake(6, 6, 2, 2)];
        Fill(layer, CGRectMake(6, 6, 2, 2), 1, 1, 1);
        [undoer endUndoGrouping];
        [undoManager endUndoGrouping];
        [undoManager undo];
        CHECK(ColorIs([layer colorAtPoint:CGPointMake(0, 0)], 0, 0, 1, 1));
        CHECK(ColorIs([layer colorAtPoint:CGPointMake(7, 7)], 0, 1, 0, 1));

        // Many registrations: the oldest copies are written out, then purged.
        for (int i = 0; i < 25; i++) {
            [undoManager beginUndoGrouping];
            [undoer registerUndoInRect:CGRectMake(0, 0, 1, 1)];
            Fill(layer, CGRectMake(0, 0, 1, 1), i / 25.0, 0, 0);
            [undoManager endUndoGrouping];
        }
        [undoManager undo];
        CHECK(ColorIs([layer colorAtPoint:CGPointMake(0, 0)], 23 / 25.0, 0, 0, 1));

        // NSColor -> CGColor.
        CHECK(ColorIs([[NSColor colorWithDeviceRed:0.2 green:0.4 blue:0.6 alpha:0.8] BT_coreGraphicsColor], 0.2, 0.4, 0.6, 0.8));
        CGColorRef gray = [[NSColor colorWithCalibratedWhite:0.5 alpha:1] BT_coreGraphicsColor];
        CHECK(gray && CGColorGetNumberOfComponents(gray) == 2 && fabs(CGColorGetComponents(gray)[0] - 0.5) < 0.01);
        CHECK([[NSColor redColor] BT_coreGraphicsColor] != NULL);
        CHECK([[NSColor controlTextColor] BT_coreGraphicsColor] != NULL);
        CHECK([[NSColor blueColor] BT_coreGraphicsExtendedColor] != NULL);
        NSImage *cell = [[[NSImage alloc] initWithSize:NSMakeSize(2, 2)] autorelease];
        [cell lockFocus];
        [[NSColor greenColor] set];
        NSRectFill(NSMakeRect(0, 0, 2, 2));
        [cell unlockFocus];
        NSColor *pattern = [NSColor colorWithPatternImage:cell];
        CGColorRef patternColor = [pattern BT_coreGraphicsColor];
        CHECK(patternColor && CGColorGetPattern(patternColor));
        CHECK([pattern BT_coreGraphicsExtendedColor] != NULL);

        // An NSImage drawing a BTImage through its rep.
        NSImage *wrapped = [[[NSImage alloc] initWithSize:NSMakeSize(8, 8)] autorelease];
        [wrapped addRepresentation:[NSImageRep BT_imageRepWithBTCGImage:layer]];
        CHECK(NSEqualSizes([[[wrapped representations] lastObject] size], NSMakeSize(8, 8)));

        CGColorSpaceRelease(rgb);
    }
    printf(failures ? "%d failures\n" : "btimagetest passed\n", failures);
    return failures != 0;
}
