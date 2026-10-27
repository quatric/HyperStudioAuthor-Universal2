// The protocols SMKPublish declares (gen_protocols.py), after the prefix's
// structures; the prefix forward-declares them all.


@protocol PRDOClientProtocol <NSObject>
- (void)reload:(id)aReload;
@end

@protocol PRDOServerProtocol <NSObject>
- (void)addLocalClient:(id)aClient;
- (id)childForIndex:(NSInteger)aIndex ofItem:(id)aItem password:(id)aPassword;
- (BOOL)isItemExpandable:(id)aExpandable password:(id)aPassword;
- (BOOL)isItemProtected:(id)aProtected;
- (NSInteger)numberOfChildrenOfItem:(id)aItem password:(id)aPassword;
- (id)objectValueForType:(id)aType byItem:(id)aItem password:(id)aPassword;
- (BOOL)setObjectValue:(id)aValue forType:(id)aType byItem:(id)aItem password:(id)aPassword;
- (BOOL)validatePassword:(id)aPassword forItem:(id)aItem;
@end
