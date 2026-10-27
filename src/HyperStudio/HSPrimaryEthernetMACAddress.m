#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/network/IOEthernetInterface.h>
#import <IOKit/network/IOEthernetController.h>

/* FUN_0028708d: the hardware address of the primary ethernet interface */
NSData *HSPrimaryEthernetMACAddress(void)
{
    CFMutableDictionaryRef matching = IOServiceMatching("IOEthernetInterface");
    if (matching != NULL) {
        CFMutableDictionaryRef property = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (property != NULL) {
            CFDictionarySetValue(property, CFSTR("IOPrimaryInterface"), kCFBooleanTrue);
            CFDictionarySetValue(matching, CFSTR("IOPropertyMatch"), property);
            CFRelease(property);
        }
    }
    io_iterator_t iterator = 0;
    if (IOServiceGetMatchingServices(kIOMasterPortDefault, matching, &iterator) != KERN_SUCCESS) {
        return nil;
    }
    CFTypeRef address = NULL;
    io_object_t interface;
    while ((interface = IOIteratorNext(iterator)) != 0) {
        io_object_t controller = 0;
        kern_return_t status = IORegistryEntryGetParentEntry(interface, "IOService", &controller);
        IOObjectRelease(interface);
        if (status != KERN_SUCCESS) {
            break;
        }
        CFTypeRef found = IORegistryEntryCreateCFProperty(controller, CFSTR("IOMACAddress"), kCFAllocatorDefault, 0);
        if (found != NULL) {
            if (address != NULL) {
                CFRelease(address);
            }
            address = found;
        }
        IOObjectRelease(controller);
    }
    IOObjectRelease(iterator);
    return [(NSData *)CFBridgingRelease(address) autorelease];
}
