// The protocols HyperEditorBase declares (gen_protocols.py), after the prefix's
// structures; the prefix forward-declares them all.


@protocol HSEditorCardViewBackgroundHost <NSObject>
- (void)addCardRect:(NSRect)aRect toContext:(struct CGContext *)aContext;
- (id)backgroundColor;
- (NSSize)cardOffset;
- (NSRect)contentBoundingRect;
- (void)setBackgroundColor:(id)aColor;
- (void)setCardOffset:(NSSize)aOffset;
@end

@protocol HSEmailTextFieldController <NSObject>
- (id)emailAddresses;
- (void)setEmailAddresses:(id)aAddresses;
@end

@protocol HSLibraryMediaData <NSObject>
- (id)rootDataFolder;
@end

@protocol HSLibraryMediaDataItem <NSObject>
- (id)dataDisplayName;
- (id)dataURL;
@end

@protocol HSLibraryMediaDataFolder <HSLibraryMediaDataItem>
- (id)dataFolderAtIndex:(NSUInteger)aIndex;
- (id)dataItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfDataFolders;
- (NSUInteger)numberOfDataItems;
@end

@protocol HSLibraryMediaDataItemAccessibility <NSObject>
- (BOOL)hasAccessibleURL;
@end

@protocol HSLibraryMediaDataProvider <NSObject>
- (BOOL)isPlayable;
- (id)mediaType;
- (id)providerType;
- (id)queryInterface:(id)aInterface;
- (BOOL)sourceApplicationPresents;
- (BOOL)supportedData:(id)aData;
- (BOOL)supportedData:(id)aData error:(id *)aError;
+ (NSInteger)defaultSortOrder;
+ (void)setDefaultSortOrder:(NSInteger)aOrder;
@end

@protocol HSLibraryMediaFiltering <NSObject>
- (id)displayStringForCategory:(id)aCategory;
- (id)searchCategories;
@end

@protocol HSLibraryMediaItem <NSObject>
- (id)actionImage;
- (SEL)actionSelector;
- (id)actionTarget;
- (id)displayName;
- (id)icon;
- (NSUInteger)numberOfSubitems;
- (id)subitemAtIndex:(NSUInteger)aIndex;
@end

@protocol HSLibraryMediaUserInterface <NSObject>
- (id)mediaDisplayName;
- (id)mediaIcon;
- (id)rootItem;
@end

@protocol HSLibraryPlugin <NSObject>
- (id)dataProviders;
- (id)pluginIcon;
- (id)pluginPanels;
- (id)pluginTitle;
- (id)pluginTooltip;
- (id)pluginType;
- (NSInteger)weight;
@end

@protocol HSLibrarySharedMedia <NSObject>
- (void)invalidateProvider:(id)aProvider;
- (id)rootSharedItemForProvider:(id)aProvider;
@end

@protocol HSLibraryUserMediaData <NSObject>
- (id)dataForDescription:(id)aDescription;
- (id)dataForURL:(id)aURL;
- (id)descriptionForData:(id)aData;
- (id)displayNameForData:(id)aData;
- (id)fileURLForData:(id)aData;
- (id)identifierImage;
- (id)identifierImageForData:(id)aData;
- (id)previewImageForData:(id)aData;
@end

@protocol HSModeController <NSObject>
- (id)modeSwitcherWindowController:(id)aController;
- (BOOL)ownsScrollViewForModeSwitcherViewEmbedding;
- (BOOL)prefersToEmbedModeSwitcherViewIntoScrollViewIfPossible;
@end

@protocol HSTrackingButtonCell <NSObject>
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
@end

@protocol HSVectorGraphicsShapeTypeSharedInfo <NSObject>
- (id)hyperShapeImage;
- (id)hyperShapeImagePath;
- (id)hyperShapeName;
- (id)hyperShapeType;
@end

@protocol HSVectorGraphicsShapeTypeSharedProvider <NSObject>
- (id)hyperShapeDefaults;
- (id)hyperShapeTypes;
@end
