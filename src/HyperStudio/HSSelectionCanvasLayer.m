#import "HSSelectionCanvasLayer.h"

@implementation HSSelectionCanvasLayer

+ (id)supportedIdentifiers
{
    return [NSArray arrayWithObjects:@"HSSelectedObjectsCanvasLayerIdentifier", @"HSSelectionKnobsCanvasLayerIdentifier", nil];
}

- (void)objectsInSelectionDidChange:(id)aChange
{
    [self objectsInSelectionDidChange];
}

- (void)objectsInSelectionDidChange
{
}

- (void)selectionDidChange
{
}

- (void)updateWithSelection:(id)aSelection
{
    if (_selection == aSelection)
        return;
    if (_selection != nil)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSNodeSelectionDidChangeNotification" object:_selection];
    [_selection release];
    _selection = [aSelection retain];
    if (_selection != nil)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectsInSelectionDidChange:) name:@"HSNodeSelectionDidChangeNotification" object:_selection];
    [self selectionDidChange];
}

- (id)selection
{
    return _selection;
}

- (void)contextDidChange
{
    [self updateWithSelection:[[[self context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] editorSelection]];
    [super contextDidChange];
}

- (id)enabledSelectedObjectsLayer
{
    return [self enabledSublayerForIdentifier:@"HSSelectedObjectsCanvasLayerIdentifier"];
}

- (id)sublayerFactory
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[HSSelectedObjectsCanvasLayer class], @"HSSelectedObjectsCanvasLayerIdentifier", [HSSelectionKnobsCanvasLayer class], @"HSSelectionKnobsCanvasLayerIdentifier", nil];
}

- (void)dealloc
{
    if (_selection != nil)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSNodeSelectionDidChangeNotification" object:_selection];
    [_selection release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithSupportedIdentifiers:[[self class] supportedIdentifiers] enabledIdentifiers:nil sublayerFactory:nil];
    if (self != nil)
        [self setDefaultSublayerIdentifiers:[NSSet setWithArray:[[self class] supportedIdentifiers]]];
    return self;
}

// Fix: the unsupported initializer releases the instance instead of leaking it.
- (id)initWithSupportedIdentifiers:(id)aIdentifiers enabledIdentifiers:(id)aIdentifiers2 sublayerFactory:(id)aFactory
{
    [self release];
    return nil;
}

@end
