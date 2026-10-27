#import "HSTextToMovieConverter.h"
#import "HSPathsProvider.h"
#import "HSUID.h"

// Speaks a text into AIFF files, 32 words per file, telling the delegate as
// each file is done.
@implementation HSTextToMovieConverter

- (void)speechSynthesizer:(id)aSynthesizer didFinishSpeaking:(BOOL)aSpeaking
{
    [[self delegate] converterDidFinishConvertingComponentToFile:[self currentlyConvertingComponentFilePath]];
    if (_isConverting)
        [self convertNextComponent];
}

- (void)convertNextComponent
{
    if ([[self notConvertedWords] count] == 0) {
        [[self delegate] converterDidfinishConvertingAllComponents];
        return;
    }
    [self setCurrentlyConvertingComponentFilePath:[self uniqueTemporaryMoviePath]];
    NSString *string = [[self nextComponentWords] componentsJoinedByString:@" "];
    [[self speechSynthesizer] startSpeakingString:string toURL:[NSURL fileURLWithPath:[self currentlyConvertingComponentFilePath]]];
}

- (id)nextComponentWords
{
    NSRange range = NSMakeRange(0, MIN([[self notConvertedWords] count], (NSUInteger)32));
    NSArray *words = [[self notConvertedWords] subarrayWithRange:range];
    [[self notConvertedWords] removeObjectsInRange:range];
    return words;
}

- (void)stopConverting
{
    _isConverting = NO;
    [[self speechSynthesizer] stopSpeaking];
}

- (void)startConverting
{
    _isConverting = YES;
    [self setNotConvertedWords:[self initialWords]];
    [self convertNextComponent];
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

// Not retained; the converter is the synthesizer's delegate.
- (void)setSpeechSynthesizer:(id)aSynthesizer
{
    if (_speechSynthesizer == aSynthesizer)
        return;
    [_speechSynthesizer setDelegate:nil];
    _speechSynthesizer = aSynthesizer;
    [aSynthesizer setDelegate:(id)self];
}

- (id)speechSynthesizer
{
    return _speechSynthesizer;
}

- (id)notConvertedWords
{
    return _notConvertedWords;
}

- (void)setNotConvertedWords:(id)aWords
{
    if (_notConvertedWords == aWords)
        return;
    [_notConvertedWords release];
    _notConvertedWords = [[NSMutableArray alloc] initWithArray:aWords];
}

- (id)initialWords
{
    return _initialWords;
}

- (void)setInitialWords:(id)aWords
{
    if (_initialWords == aWords)
        return;
    [_initialWords release];
    _initialWords = [[NSArray alloc] initWithArray:aWords];
}

- (id)currentlyConvertingComponentFilePath
{
    return _currentlyConvertingComponentFilePath;
}

- (void)setCurrentlyConvertingComponentFilePath:(id)aPath
{
    if (_currentlyConvertingComponentFilePath == aPath)
        return;
    [_currentlyConvertingComponentFilePath release];
    _currentlyConvertingComponentFilePath = [aPath retain];
}

- (id)uniqueTemporaryMoviePath
{
    NSString *name = [[HSUID UID] stringValue];
    return [[[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"aiff"];
}

- (id)initWithSpeachSynthesizer:(id)aSynthesizer textToConvert:(id)aConvert
{
    self = [super init];
    if (self != nil) {
        [self setSpeechSynthesizer:aSynthesizer];
        [self setInitialWords:[aConvert componentsSeparatedByString:@" "]];
    }
    return self;
}

- (void)dealloc
{
    [_initialWords release];
    [_notConvertedWords release];
    [_currentlyConvertingComponentFilePath release];
    [self setSpeechSynthesizer:nil];
    [super dealloc];
}

@end
