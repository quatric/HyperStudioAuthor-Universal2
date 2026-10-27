#import "HSYouTubeCategoryDataProvider.h"

static HSYouTubeCategoryDataProvider *HSYouTubeCategoryDataProviderShared = nil;

static NSInteger HSYouTubeCategoryCompareLabels(id aCategory, id anotherCategory, void *aContext)
{
    return [[aCategory objectForKey:@"label"] localizedCaseInsensitiveCompare:[anotherCategory objectForKey:@"label"]];
}

@implementation HSYouTubeCategoryDataProvider

+ (id)allocWithZone:(NSZone *)aZone
{
    if (!HSYouTubeCategoryDataProviderShared)
        HSYouTubeCategoryDataProviderShared = [super allocWithZone:aZone];
    return HSYouTubeCategoryDataProviderShared;
}

+ (id)sharedYouTubeCategoryDataProvider
{
    if (!HSYouTubeCategoryDataProviderShared)
        [self new];
    return HSYouTubeCategoryDataProviderShared;
}

- (void)invalidateConnectionAndData
{
    [_theConnection release];
    _theConnection = nil;
    [_receivedData release];
    _receivedData = nil;
}

// Parses the category feed into term/label dictionaries (skipping deprecated
// categories, "All" first) and posts the did-load or failed notification.
- (void)connectionDidFinishLoading:(id)aLoading
{
    NSError *error = nil;
    NSXMLDocument *document = [[[NSXMLDocument alloc] initWithData:_receivedData options:NSXMLDocumentTidyXML error:&error] autorelease];
    NSString *notificationName;
    if (!error) {
        NSMutableArray *categories = [NSMutableArray array];
        [categories addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"term", @"All", @"label", nil]];
        NSEnumerator *enumerator = [[[document rootElement] children] objectEnumerator];
        NSXMLElement *element;
        while ((element = [enumerator nextObject])) {
            id term = [[element attributeForName:@"term"] objectValue];
            if ([[element elementsForName:@"yt:deprecated"] count] == 0) {
                NSMutableString *label = [NSMutableString stringWithString:[[element attributeForName:@"label"] objectValue]];
                [label replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [label length])];
                [categories addObject:[NSDictionary dictionaryWithObjectsAndKeys:term, @"term", label, @"label", nil]];
            }
        }
        _categoryArray = [[categories sortedArrayUsingFunction:HSYouTubeCategoryCompareLabels context:NULL] retain];
        notificationName = @"HSYouTubeCategoryDidLoadNotification";
    } else {
        notificationName = @"HSYouTubeCategoryLoadFailedNotification";
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
    _loadInProgress = NO;
    [self invalidateConnectionAndData];
}

- (void)connection:(id)aConnection didFailWithError:(id)aError
{
    [self invalidateConnectionAndData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSYouTubeCategoryLoadFailedNotification" object:self];
    _loadInProgress = NO;
}

- (void)connection:(id)aConnection didReceiveData:(id)aData
{
    [_receivedData appendData:aData];
}

- (void)connection:(id)aConnection didReceiveResponse:(id)aResponse
{
    [_receivedData setLength:0];
}

- (id)categoryValueForIndex:(NSUInteger)aIndex valueCondition:(NSInteger)aCondition
{
    if (aCondition == 1)
        return [[_categoryArray objectAtIndex:aIndex] objectForKey:@"label"];
    if (aCondition == 0)
        return [[_categoryArray objectAtIndex:aIndex] objectForKey:@"term"];
    return nil;
}

- (NSUInteger)numberOfCategories
{
    return [_categoryArray count];
}

- (void)loadCategories
{
    if (_loadInProgress)
        return;
    NSString *name;
    if (!_categoryArray) {
        NSURL *url = [NSURL URLWithString:@"http://gdata.youtube.com/schemas/2007/categories.cat"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        _theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (_theConnection) {
            _receivedData = [NSMutableData new];
            _loadInProgress = YES;
            return;
        }
        name = @"HSYouTubeCategoryLoadFailedNotification";
    } else {
        name = @"HSYouTubeCategoryDidLoadNotification";
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:self];
}

- (void)dealloc
{
    [_receivedData release];
    [_categoryArray release];
    [_theConnection cancel];
    [_theConnection release];
    _theConnection = nil;
    [super dealloc];
}

- (id)autorelease
{
    return self;
}

- (void)release
{
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

@end
