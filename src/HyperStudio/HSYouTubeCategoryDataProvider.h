#import "HyperStudioPrefix.h"


@interface HSYouTubeCategoryDataProvider : NSObject
{
    NSMutableData *_receivedData;
    NSArray *_categoryArray;
    BOOL _loadInProgress;
    NSURLConnection *_theConnection;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedYouTubeCategoryDataProvider;
- (void)invalidateConnectionAndData;
- (void)connectionDidFinishLoading:(id)aLoading;
- (void)connection:(id)aConnection didFailWithError:(id)aError;
- (void)connection:(id)aConnection didReceiveData:(id)aData;
- (void)connection:(id)aConnection didReceiveResponse:(id)aResponse;
- (id)categoryValueForIndex:(NSUInteger)aIndex valueCondition:(NSInteger)aCondition;
- (NSUInteger)numberOfCategories;
- (void)loadCategories;
- (void)dealloc;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

