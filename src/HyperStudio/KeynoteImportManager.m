#import "KeynoteImportManager.h"

@implementation KeynoteImportManager

+ (BOOL)isKeynote2FileWrapperRepresentation:(id)aRepresentation
{
    NSArray *names = [[aRepresentation fileWrappers] allKeys];
    return [names containsObject:@"index.apxl"] || [names containsObject:@"index.apxl.gz"];
}

- (BOOL)shouldImportPresentation
{
    NSInteger result = [_importProblems runUserConfirmationAlert];
    if (result == 1002)
        [[HSSubmitRequest sharedInstance] submitInformation:[_importProblems reportTextWithFilename:_pathToDocument]];
    return result != 1001;
}

- (void)addImportingProblemForCode:(NSInteger)aCode point:(id)aPoint info:(id)aInfo
{
    [_importProblems addImportingProblemForCode:aCode point:aPoint info:aInfo];
}

- (void)setPathToDocument:(id)aDocument
{
    if (![_pathToDocument isEqualToString:aDocument]) {
        [_pathToDocument release];
        _pathToDocument = [aDocument retain];
    }
}

- (id)pathToDocument
{
    return _pathToDocument;
}

- (void)specifyDetailForKeynoteObject:(id)aObject
{
    [_parser specifyDetailForKeynoteObject:aObject];
}

- (id)presentation
{
    if (_presentation == nil) {
        _presentation = [[_parser keynotePresentation] retain];
        [_presentation setImportManager:self];
    }
    return _presentation;
}

- (void)setFileWrapper:(id)aWrapper
{
    [_parser setFileWrapperRepresentation:aWrapper];
}

- (void)dealloc
{
    [_parser release];
    [_presentation release];
    [_pathToDocument release];
    [_importProblems release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _parser = [KeynoteParser new];
        _importProblems = [HSImportProblems new];
    }
    return self;
}

@end
