#import "HyperPlayerBasePrefix.h"


@interface HSGraphVertex : NSObject <NSCopying>
{
    id _representedObject;
    NSMutableDictionary *_userInfo;
    NSMutableArray *_adjacencyList;
}
- (NSInteger)topologicalSortCompare:(id)aCompare;
- (void)setUserInfo:(id)aInfo forKey:(id)aKey;
- (id)userInfo;
- (void)setRepresentedObject:(id)aObject;
- (id)representedObject;
- (BOOL)connectedToVertex:(id)aVertex;
- (void)disconnectFromVertex:(id)aVertex;
- (void)connectToVertex:(id)aVertex;
- (id)copyWithZone:(NSZone *)aZone;
- (id)adjacencyList;
- (id)mutableAdjacencyList;
- (void)setUserInfo:(id)aInfo;
- (void)dealloc;
- (id)initWithRepresentedObject:(id)aObject;
@end

