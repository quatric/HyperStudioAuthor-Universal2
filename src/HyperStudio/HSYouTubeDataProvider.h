#import "HyperStudioPrefix.h"


@interface HSYouTubeDataProvider : NSObject <HSYouTubeDataProviderInterface, NSObject>
{
    NSMutableData *_receivedData;
    NSMutableArray *_dataArray;
    NSMutableString *_requestFormatString;
    NSURLConnection *_youTubeConnection;
    unsigned int _numberOfDataItems;
    unsigned int _startIndex;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedYouTubeDataProvider;
- (void)connectionDidFinishLoading:(id)aLoading;
- (void)connection:(id)aConnection didFailWithError:(id)aError;
- (void)connection:(id)aConnection didReceiveData:(id)aData;
- (void)connection:(id)aConnection didReceiveResponse:(id)aResponse;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (id)standardTimeString:(NSInteger)aString;
- (id)standardFeedString:(NSInteger)aString;
- (void)provideYouTubeDataForIndex:(NSUInteger)aIndex;
- (id)allInformationForIndex:(NSUInteger)aIndex;
- (id)dataValueForIndex:(NSUInteger)aIndex valueCondition:(id)aCondition;
- (NSUInteger)numberOfDataItems;
- (void)provideYouTubeDataForCategory:(id)aCategory keyWord:(id)aWord standardFeed:(NSInteger)aFeed standardTime:(NSInteger)aTime;
@end

