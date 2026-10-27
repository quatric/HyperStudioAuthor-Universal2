#import "SMKBitmapToolsData.h"

static void BTObjectPointerRetain(NSMapTable *aTable, const void *aKey)
{
    [(id)aKey retain];
}

static void BTObjectPointerRelease(NSMapTable *aTable, void *aKey)
{
    [(id)aKey release];
}

static NSString *BTObjectPointerDescribe(NSMapTable *aTable, const void *aKey)
{
    return [(id)aKey description];
}

/* No hash or isEqual: the map table uses the pointers themselves. */
const NSMapTableKeyCallBacks BTObjectPointerMapKeyCallBacks = {
    NULL, NULL, BTObjectPointerRetain, BTObjectPointerRelease, BTObjectPointerDescribe, NSNotAPointerMapKey
};
