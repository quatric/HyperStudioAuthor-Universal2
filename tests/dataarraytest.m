// BTDataArray: growing past the first cluster, copies, ranges, initial data.
#import "SMKBitmapToolsPrefix.h"
#import "BTClustersMutableDataArray.h"

static int failures;
#define CHECK(...) do { if (!(__VA_ARGS__)) { printf("FAIL %s:%d %s\n", __FILE__, __LINE__, #__VA_ARGS__); failures++; } } while (0)

int main(void)
{
    @autoreleasepool {
        // 24-byte items: clusters of 170 items, not a multiple of the item size in bytes.
        typedef struct { double x, y, z; } Item;
        BTMutableDataArray *array = [BTMutableDataArray arrayWithCount:0 itemSize:sizeof(Item)];
        CHECK([array isKindOfClass:[BTClustersMutableDataArray class]]);
        for (int i = 0; i < 1000; i++) {
            Item item = {i, -i, i * 0.5};
            [array addItemBytes:&item];
        }
        CHECK([array count] == 1000);
        BOOL ok = YES;
        for (int i = 0; i < 1000; i++) {
            Item *item = [array bytesOfItemAtIndex:i];
            ok &= item->x == i && item->y == -i && item->z == i * 0.5;
        }
        CHECK(ok);
        CHECK(((Item *)[array bytesOfLastItem])->x == 999);

        BTDataArray *copy = [[array copy] autorelease];
        CHECK([copy isKindOfClass:[BTClustersDataArray class]]);
        CHECK([copy count] == 1000 && ((Item *)[copy bytesOfItemAtIndex:500])->y == -500);
        BTMutableDataArray *mutableCopy = [[copy mutableCopy] autorelease];
        Item changed = {1, 2, 3};
        memcpy([mutableCopy mutableBytesOfItemAtIndex:500], &changed, sizeof changed);
        CHECK(((Item *)[mutableCopy bytesOfItemAtIndex:500])->x == 1);
        CHECK(((Item *)[copy bytesOfItemAtIndex:500])->x == 500);

        NSData *data = [array itemsDataInRange:NSMakeRange(168, 4)];
        CHECK([data length] == 4 * sizeof(Item) && ((Item *)[data bytes])[3].x == 171);
        CHECK([[array allItemsData] length] == 1000 * sizeof(Item));

        [array setCount:10];
        CHECK([array count] == 10 && ((Item *)[array bytesOfItemAtIndex:9])->x == 9);
        [array setCount:0];
        for (int i = 0; i < 300; i++) {
            Item item = {i, 0, 0};
            [array addItemBytes:&item];
        }
        CHECK(((Item *)[array bytesOfItemAtIndex:299])->x == 299 && ((Item *)[array bytesOfItemAtIndex:0])->x == 0);

        // From data: the data is the first cluster.
        double values[5] = {1, 2, 3, 4, 5};
        BTDataArray *fixed = [BTDataArray arrayWithData:[NSData dataWithBytes:values length:sizeof values]
                                               itemSize:sizeof(double) count:5];
        CHECK([fixed count] == 5 && *(double *)[fixed bytesOfItemAtIndex:4] == 5);
        CHECK([BTDataArray arrayWithData:[NSData dataWithBytes:values length:8] itemSize:8 count:5] == nil);
        BTMutableDataArray *grown = [[fixed mutableCopy] autorelease];
        double six = 6;
        [grown addItemBytes:&six];
        CHECK([grown count] == 6 && *(double *)[grown bytesOfItemAtIndex:5] == 6 &&
              *(double *)[grown bytesOfItemAtIndex:2] == 3);

        BOOL threw = NO;
        @try {
            [fixed bytesOfItemAtIndex:5];
        } @catch (NSException *e) {
            threw = [[e name] isEqualToString:NSRangeException];
        }
        CHECK(threw);
    }
    printf(failures ? "%d failures\n" : "dataarraytest passed\n", failures);
    return failures != 0;
}
