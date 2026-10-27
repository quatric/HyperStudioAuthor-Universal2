// NSEProtocolSet / NSEMutableProtocolSet: adopted protocols, set algebra and
// copy-on-write sharing.
#import "NSEMutableProtocolSet.h"

static int failures;
#define CHECK(...) do { if (!(__VA_ARGS__)) { printf("FAIL %s:%d %s\n", __FILE__, __LINE__, #__VA_ARGS__); failures++; } } while (0)

@protocol TestBase <NSObject>
@end
@protocol TestDerived <TestBase, NSCopying>
@end

int main(void)
{
    @autoreleasepool {
        Protocol *base = @protocol(TestBase), *derived = @protocol(TestDerived);
        Protocol *object = @protocol(NSObject), *copying = @protocol(NSCopying), *coding = @protocol(NSCoding);

        NSEProtocolSet *adopted = [NSEProtocolSet protocolSetWithProtocolsAdoptedByProtocol:derived];
        printf("%s\n", [[adopted description] UTF8String]);
        CHECK([adopted count] == 4);
        CHECK([adopted containsProtocol:object] && [adopted containsProtocol:derived]);
        CHECK(![adopted containsProtocol:coding]);
        CHECK([[NSEProtocolSet protocolSetWithProtocolsAdoptedByProtocols:base, copying, nil] count] == 3);
        CHECK([adopted containsProtocolsExludingProtocols:base, object, nil]);
        CHECK(![adopted containsProtocolsExludingProtocols:base, object, derived, copying, nil]);

        NSEProtocolSet *two = [NSEProtocolSet protocolSetWithProtocols:derived, coding, nil];
        NSEProtocolSet *all = [[two copyAdoptedProtocols] autorelease];
        CHECK([all count] == 5);
        CHECK([two count] == 2);
        CHECK([two isSubsetOfProtocolSet:all] && ![all isSubsetOfProtocolSet:two]);
        CHECK([two intersectsProtocolSet:adopted]);
        Protocol **list = [all allProtocols];
        int n = 0;
        while (list[n])
            n++;
        CHECK(n == 5);

        // Copy on write: the mutable copy shares storage until it changes.
        NSEMutableProtocolSet *mutable = [[two mutableCopy] autorelease];
        CHECK([mutable _NSE_implementation] == [two _NSE_implementation]);
        [mutable addProtocol:base];
        CHECK([mutable count] == 3 && [two count] == 2);
        CHECK([mutable _NSE_implementation] != [two _NSE_implementation]);
        [mutable addAdoptedProtocols];
        CHECK([mutable isEqual:all]);
        CHECK([mutable hash] == [all hash]);
        NSEProtocolSet *frozen = [[mutable copy] autorelease];
        [mutable removeProtocolsAdoptedByProtocol:derived];
        printf("%s\n", [[mutable description] UTF8String]);
        CHECK([mutable count] == 1 && [mutable containsProtocol:coding]);
        CHECK([frozen count] == 5);

        [mutable unionProtocolSet:adopted];
        CHECK([mutable count] == 5);
        [mutable intersectProtocolSet:two];
        CHECK([mutable isEqual:two]);
        [mutable minusProtocolSet:[NSEProtocolSet protocolSetWithProtocol:coding]];
        CHECK([mutable count] == 1 && [mutable anyProtocol] == derived);
        [mutable intersectProtocolSet:[NSEProtocolSet protocolSetWithProtocol:coding]];
        CHECK([mutable count] == 0);
        [mutable addProtocolsAdoptedByProtocol:copying];
        [mutable removeProtocol:copying];
        CHECK([mutable count] == 0 && [mutable isEqual:[NSEProtocolSet protocolSet]]);
        int seen = 0;
        for (Protocol *p in all)
            seen += p != nil;
        CHECK(seen == 5);
    }
    printf(failures ? "%d FAILED\n" : "all passed\n", failures);
    return failures != 0;
}
