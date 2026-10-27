#import "HyperStudioPrefix.h"


@interface KeynoteImportManager : NSObject
{
    KeynoteParser *_parser;
    KeynotePresentation *_presentation;
    NSString *_pathToDocument;
    HSImportProblems *_importProblems;
}
+ (BOOL)isKeynote2FileWrapperRepresentation:(id)aRepresentation;
- (BOOL)shouldImportPresentation;
- (void)addImportingProblemForCode:(NSInteger)aCode point:(id)aPoint info:(id)aInfo;
- (void)setPathToDocument:(id)aDocument;
- (id)pathToDocument;
- (void)specifyDetailForKeynoteObject:(id)aObject;
- (id)presentation;
- (void)setFileWrapper:(id)aWrapper;
- (void)dealloc;
- (id)init;
@end

