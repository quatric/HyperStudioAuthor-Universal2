#import "HSiPadImporter.h"
@implementation HSiPadImporter
- (id)importIPadStackFromFileWrapper:(id)aWrapper
{
    // Contents/document.xml holds the stack and refers to the media list and
    // one XML file per card
    NSFileWrapper *contents = [[aWrapper fileWrappers] objectForKey:@"Contents"];
    NSFileWrapper *documentWrapper = [[contents fileWrappers] objectForKey:@"document.xml"];
    NSError *documentError = nil;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:[documentWrapper regularFileContents] options:0
                                                            error:&documentError];
    // keeps the media alive while the cards are made
    NSMutableArray *media = [[NSMutableArray alloc] init];

    NSString *resourcesName = [[[[[document rootElement] elementsForName:@"resourceref"] extraFirstObject]
        attributeForName:@"target"] stringValue];
    NSFileWrapper *resourcesWrapper = [[contents fileWrappers] objectForKey:resourcesName];
    NSError *resourcesError = nil;
    NSXMLDocument *resources = [[NSXMLDocument alloc] initWithData:[resourcesWrapper regularFileContents] options:0
                                                             error:&resourcesError];
    if (resourcesError == nil) {
        for (NSXMLElement *item in [[resources rootElement] elementsForName:@"mediaItem"]) {
            HSUID *uid = [HSUID UIDWithString:[[item attributeForName:@"uid"] stringValue]];
            id medium = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid];
            if (medium == nil) {
                NSFileWrapper *file = [self fileWrapperAtPath:[[item attributeForName:@"target"] stringValue]
                                                inFileWrapper:contents];
                HSMediaDataRepresentation *representation = [[HSMediaDataRepresentation alloc]
                    initWithData:[file regularFileContents] mediaType:[[file filename] pathExtension]];
                medium = [[[HSNewMedia alloc] initWithMediaUID:uid representation:representation
                                                          name:[file filename]] autorelease];
                [representation release];
            }
            if (medium != nil)
                [media addObject:medium];
        }
    }
    [resources release];

    HSStack *stack = [HSStack defaultObject];
    if (documentError == nil) {
        HSiPadImportContext *context = [[HSiPadImportContext alloc] initWithStack:stack];
        NSXMLElement *stackElement = [[[document rootElement] elementsForName:[stack XMLElementName]] extraFirstObject];
        [stack importFromXMLElementRepresentation:stackElement inContext:context];
        for (NSXMLElement *cardRef in [stackElement elementsForName:@"cardref"]) {
            NSFileWrapper *cardWrapper = [[contents fileWrappers] objectForKey:[[cardRef attributeForName:@"target"] stringValue]];
            NSError *cardError = nil;
            NSXMLDocument *cardDocument = [[NSXMLDocument alloc] initWithData:[cardWrapper regularFileContents]
                                                                      options:0 error:&cardError];
            HSCard *card = [HSCard defaultObject];
            [stack addChild:card];
            [card importFromXMLElementRepresentation:[cardDocument rootElement] inContext:context];
            [cardDocument release];
        }
        [context release];
    }
    [document release];
    [media release];
    return stack;
}
- (id)fileWrapperAtPath:(id)aPath inFileWrapper:(id)aWrapper
{
    if (![aWrapper isDirectory])
        return nil;
    NSArray *components = [aPath pathComponents];
    NSFileWrapper *wrapper = [[aWrapper fileWrappers] objectForKey:[components extraFirstObject]];
    if ([components count] >= 2) {
        NSString *rest = [NSString pathWithComponents:[components subarrayWithRange:NSMakeRange(1, [components count] - 1)]];
        wrapper = [self fileWrapperAtPath:rest inFileWrapper:wrapper];
    }
    return wrapper;
}
@end
