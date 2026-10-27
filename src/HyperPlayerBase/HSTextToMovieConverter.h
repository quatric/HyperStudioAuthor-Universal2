#import "HyperPlayerBasePrefix.h"


@interface HSTextToMovieConverter : NSObject <NSSpeechSynthesizerDelegate, NSObject>
{
    NSArray *_initialWords;
    NSMutableArray *_notConvertedWords;
    NSSpeechSynthesizer *_speechSynthesizer;
    NSString *_currentlyConvertingComponentFilePath;
    id<HSTextToMovieConverterDelegate> _delegate;
    BOOL _isConverting;
}
- (void)speechSynthesizer:(id)aSynthesizer didFinishSpeaking:(BOOL)aSpeaking;
- (void)convertNextComponent;
- (id)nextComponentWords;
- (void)stopConverting;
- (void)startConverting;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (void)setSpeechSynthesizer:(id)aSynthesizer;
- (id)speechSynthesizer;
- (id)notConvertedWords;
- (void)setNotConvertedWords:(id)aWords;
- (id)initialWords;
- (void)setInitialWords:(id)aWords;
- (id)currentlyConvertingComponentFilePath;
- (void)setCurrentlyConvertingComponentFilePath:(id)aPath;
- (id)uniqueTemporaryMoviePath;
- (id)initWithSpeachSynthesizer:(id)aSynthesizer textToConvert:(id)aConvert;
- (void)dealloc;
@end

