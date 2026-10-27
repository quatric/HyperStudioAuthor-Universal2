// Shared declarations for the SMKBitmapTools sources.
#import "HSSystemFrameworks.h"
#import "SMKApplicationKitUmbrella.h"
#import "BTImageFunctions.h"
#import "BTCGPathFunctions.h"
#import "SMKBitmapToolsData.h"

@protocol BTBrushTouchConsumer <NSObject>
- (void)addTouchAtPoint:(CGPoint)aPoint withSizeDeviation:(CGSize)aDeviation rotationAngleDeviation:(CGFloat)aDeviation2 opacityDeviation:(CGFloat)aDeviation3 alternateColor:(BOOL)aColor colorHSVADeviation:(id)aDeviation4 colorNativeDeviation:(id)aDeviation5 shadowColorHSVADeviation:(id)aDeviation6 shadowColorNativeDeviation:(id)aDeviation7;
@end
@protocol BTBrushTouchProvider <NSObject>
- (void)position:(CGPoint *)aPosition sizeDeviation:(CGSize *)aDeviation rotationAngleDeviation:(CGFloat *)aDeviation2 opacityDeviation:(CGFloat *)aDeviation3 alternateColor:(BOOL *)aColor colorHSVADeviation:(id *)aDeviation4 colorNativeDeviation:(id *)aDeviation5 shadowColorHSVADeviation:(id *)aDeviation6 shadowColorNativeDeviation:(id *)aDeviation7 forTouchAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfTouches;
@end
@protocol BTImage <NSObject>
- (CGSize)imageSize;
@end
@protocol BTCGImage <BTImage>
- (struct CGColor *)colorAtPoint:(CGPoint)aPoint;
- (struct CGImage *)coreGraphicsImage;
- (struct CGColorSpace *)coreGraphicsColorSpace;
- (struct CGPDFDocument *)coreGraphicsPDFDocument;
- (void)drawInCGContext:(struct CGContext *)aContext atPoint:(CGPoint)aPoint;
- (void)drawInCGContext:(struct CGContext *)aContext inRect:(CGRect)aRect;
@end
@protocol BTCGImageSaverInterface
- (void)removeFileAtPath:(id)aPath;
- (void)storeImage:(NSUInteger)aImage;
@end
@protocol BTMutableImage <BTImage>
- (id)createImageUndoerWithDelegate:(id)aDelegate;
@end
@protocol BTCGMutableImage <BTMutableImage>
- (struct CGColorSpace *)coreGraphicsColorSpace;
- (void)endCGEditing;
- (struct CGContext *)imageCGContext;
- (void)beginCGEditing;
@end
@protocol BTClustersDataArrayInitializerProtocol
- (id)initWithClusters:(id)aClusters firstClusterSize:(NSUInteger)aSize generalClusterSize:(NSUInteger)aSize2 itemSize:(NSUInteger)aSize3 count:(NSUInteger)aCount;
@end
@protocol BTCocoaImage <BTImage>
- (void)drawInCurrentNSGraphicsContextAtPoint:(CGPoint)aPoint;
- (void)drawInCurrentNSGraphicsContextInRect:(CGRect)aRect;
@end
@protocol BTCocoaMutableImage <BTMutableImage>
- (void)endCocoaEditing;
- (void)beginCocoaEditing;
@end
@protocol BTImageUndoing <NSObject>
- (void)endUndoGrouping;
- (void)beginUndoGrouping;
- (void)registerUndoInRect:(CGRect)aRect;
- (id)delegate;
- (id)image;
@end
@protocol BTImageUndoingDelegate
- (void)imageUndoer:(id)aUndoer didChangeImageInRect:(CGRect)aRect;
- (void)imageUndoer:(id)aUndoer willChangeImageInRect:(CGRect)aRect;
- (id)prepareUndoForImageUndoer:(id)aUndoer withInvocationTarget:(id)aTarget;
- (void)registerUndoForImageUndoer:(id)aUndoer withTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject;
@end
@protocol BTImageViewTransformer
- (CGRect)convertImageRectToViewRect:(CGRect)aRect;
- (CGPoint)convertImagePointToViewPoint:(CGPoint)aPoint;
- (CGAffineTransform)imageToViewTransform;
- (CGRect)convertViewRectToImageRect:(CGRect)aRect;
- (CGPoint)convertViewPointToImagePoint:(CGPoint)aPoint;
- (CGAffineTransform)viewToImageTransform;
@end
@protocol BTMouseTracker <NSObject>
@optional
- (void)trackMouseDown:(id)aDown inView:(id)aView;
- (void)trackMouseDragged:(id)aDragged inView:(id)aView;
- (void)trackFlagsChanged:(id)aChanged inView:(id)aView;
- (void)trackMouseUp:(id)aUp inView:(id)aView;
- (void)haltWithMouseUp:(id)aUp inView:(id)aView;
- (BOOL)trackingView:(id)aView shouldAutoscrollWithMouseEvent:(id)aEvent;
- (void)trackingView:(id)aView didAutoscroll:(BOOL)aAutoscroll withMouseEvent:(id)aEvent;
@end
@protocol BTMutableClustersDataArrayProtocol
- (void *)mutableBytesOfItemAtIndex:(NSUInteger)aIndex;
- (void)setCount:(NSUInteger)aCount;
@end
@protocol BTPointSnapSource <NSObject>
- (id)options;
- (struct CGELine)trajectoryLine;
- (CGFloat)maxYBound;
- (CGFloat)minYBound;
- (CGFloat)maxXBound;
- (CGFloat)minXBound;
- (CGPoint)point;
@end
@protocol BTPointToPointReflecting
- (CGPoint)reflectedPointForPoint:(CGPoint)aPoint;
@end
@protocol BTPurgableObject <NSObject>
- (void)purge;
- (void)prepareToPurge;
@end
@protocol BTRawImage <BTImage>
- (const CGFloat *)imageDecode;
- (struct OpaqueCMProfileRef *)imageColorProfile;
- (NSInteger)imageFormat;
- (NSUInteger)imageBytesPerRow;
- (const void *)imageBytes;
@end
@protocol BTRawMutableImage <BTMutableImage>
- (void)endRawEditing;
- (const CGFloat *)imageDecode;
- (struct OpaqueCMProfileRef *)imageColorProfile;
- (NSInteger)imageFormat;
- (NSUInteger)imageBytesPerRow;
- (void *)mutableImageBytes;
- (void)beginRawEditing;
@end
@protocol BTSizeSnapSource <NSObject>
- (id)options;
- (CGAffineTransform)showTransform;
- (CGFloat)proportionFactor;
- (CGSize)maxSize;
- (CGSize)minSize;
- (CGSize)size;
@end
@protocol BTSizeToPointReflecting
- (CGPoint)reflectedPointForSize:(CGSize)aSize;
@end
@protocol BTToolDelegate <NSObject>
- (id)layoutGuidingContextForTool:(id)aTool;
- (id)mouseTrackingDelegateForTool:(id)aTool;
- (id)imageViewTransformerForTool:(id)aTool;
- (id)tool:(id)aTool willSetUndoActionName:(id)aName;
- (void)tool:(id)aTool willRegisterUndoInManager:(id)aManager category:(id)aCategory;
- (id)undoManagerForTool:(id)aTool category:(id)aCategory;
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aStage2;
- (void)tool:(id)aTool didFinalizeOutputForKey:(id)aKey;
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey;
- (void)tool:(id)aTool willUpdateOutputForKey:(id)aKey;
- (void)tool:(id)aTool didReplaceImageWithEffectiveChangeInRect:(CGRect)aRect;
- (void)tool:(id)aTool willReplaceImageWithEffectiveChangeInRect:(CGRect)aRect;
- (void)tool:(id)aTool didChangeImageInRect:(CGRect)aRect;
- (void)tool:(id)aTool willChangeImageInRect:(CGRect)aRect;
- (void)toolDidEndChangingImageContinuously:(id)aContinuously;
- (void)toolWillBeginChangingImageContinuously:(id)aContinuously;
- (void)tool:(id)aTool didUpdateCursorWithEvent:(id)aEvent;
@optional
- (BOOL)canProvideSelectedShape;
- (void)provideSelectionPath:(struct CGPath *)aPath withOrientedRectTransform:(CGAffineTransform)aTransform;
@end

@class BTAbstractClustersDataArray;
@class BTBrushTool;
@class BTBrushTouchStorage;
@class BTCGBitmapLayer;
@class BTCGImage;
@class BTCGImageSaver;
@class BTCGLayer;
@class BTCGMutableImage;
@class BTCGRawMutableImage;
@class BTClustersDataArray;
@class BTClustersMutableDataArray;
@class BTCreateFreeHandSelectionTool;
@class BTCreateLassoSelectionTool;
@class BTCreateMagicWandSelectionTool;
@class BTCreateSelectionTool;
@class BTCreateShapeSelectionTool;
@class BTDataArray;
@class BTDraw3DShapeTool;
@class BTDrawLineTool;
@class BTDrawSelectionTool;
@class BTDrawShapeTool;
@class BTFillTool;
@class BTModifySelectionTool;
@class BTMutableCGImageUndoer;
@class BTMutableDataArray;
@class BTNSImage;
@class BTObjectWrapperForUndoManager;
@class BTObjectWrapperForUndoManagerList;
@class BTPencilTool;
@class BTPointSnapSource;
@class BTPointToPointSnapSource;
@class BTPointer;
@class BTPointsContainer;
@class BTPointsCreationTool;
@class BTRegionEditingTool;
@class BTRegionEditingTool_BTClippedCGImage;
@class BTRegionEditingTool_BTImageRegion;
@class BTRegionEditingTool_BTImageRegionArchiver;
@class BTRegionEditingTool_BTImageRegionUnarchiver;
@class BTRegionEditingTool_BTImageRestorator;
@class BTSelectionTool;
@class BTSizeSnapSource;
@class BTSizeToPointSnapSource;
@class BTTool;
@class BTToolView;
@class BTTrackingView;
@class BTTrackingView_BTTrackingZone;
@class BTTrackingView_BTVisibleRectTrackingZone;
@class BTTrackingZone;
@class BTUndoManagerCoreProxy;
@class NSEvent_BTKeyBinding_BTKeyEventsInterpreter;
@class NSImageRep_BTImage_BTCGImageRep;
@class NSImageRep_BTImage_BTCocoaImageRep;


