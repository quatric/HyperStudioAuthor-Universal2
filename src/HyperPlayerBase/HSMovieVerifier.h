#import "HyperPlayerBasePrefix.h"


@interface HSMovieVerifier : NSObject
{
    QTMovie *_movie;
    unsigned int _options;
    struct _NSModalSession *_statusWindowModalSession;
    NSWindow *_statusWindow;
    NSTextField *_statusMessageTextField;
    NSProgressIndicator *_progressIndicator;
}
- (id)verifyMovie:(id)aMovie withOptions:(NSInteger)aOptions error:(id *)aError;
- (id)verifyMovieWithData:(id)aData withOptions:(NSInteger)aOptions error:(id *)aError;
- (id)verifyMovieAtURL:(id)aURL withOptions:(NSInteger)aOptions error:(id *)aError;
- (BOOL)tryToResolveBrokenDataRefs:(id)aRefs;
- (BOOL)resolveBrokenMediaDataRefWithAttributes:(id)aAttributes;
- (id)brokenMediaDataRefsAttributesInMovie;
- (void)hideStatusWindow;
- (BOOL)showStatusWindow;
- (BOOL)loadNibIfNeeded;
- (void)dealloc;
@end

