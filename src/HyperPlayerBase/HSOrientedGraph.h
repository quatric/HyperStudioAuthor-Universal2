#import "HyperPlayerBasePrefix.h"


@interface HSOrientedGraph : NSObject
{
    NSMutableArray *_vertices;
    int _time;
}
- (id)topologicalSort;
- (void)deepFirstSearch;
- (void)deepFirstSearchVisitVertex:(id)aVertex piDictionary:(id)aDictionary;
- (void)disconnectVertex:(id)aVertex fromVertex:(id)aVertex2;
- (void)connectVertex:(id)aVertex toVertex:(id)aVertex2;
- (void)removeVertex:(id)aVertex;
- (void)addVertex:(id)aVertex;
- (id)vertexWithRepresentedObject:(id)aObject;
- (id)vertices;
- (id)mutableVertices;
- (void)dealloc;
@end

