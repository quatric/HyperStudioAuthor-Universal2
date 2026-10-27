#import "HSMACAdressReader.h"
#import <IOKit/IOKitLib.h>
#import <IOKit/network/IOEthernetInterface.h>
#import <IOKit/network/IONetworkInterface.h>
#import <IOKit/network/IOEthernetController.h>

id HSMACAdressReaderGetPrimary(void)
{
    io_iterator_t iterator = 0;
    CFMutableDictionaryRef matching = IOServiceMatching(kIOEthernetInterfaceClass);
    if (matching != NULL) {
        CFMutableDictionaryRef propertyMatch = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (propertyMatch != NULL) {
            CFDictionarySetValue(propertyMatch, CFSTR(kIOPrimaryInterface), kCFBooleanTrue);
            CFDictionarySetValue(matching, CFSTR(kIOPropertyMatchKey), propertyMatch);
            CFRelease(propertyMatch);
        }
    }
    if (IOServiceGetMatchingServices(kIOMasterPortDefault, matching, &iterator) != KERN_SUCCESS)
        return nil;
    CFTypeRef address = NULL;
    io_object_t interface;
    while ((interface = IOIteratorNext(iterator)) != 0) {
        io_object_t controller = 0;
        if (IORegistryEntryGetParentEntry(interface, kIOServicePlane, &controller) != KERN_SUCCESS) {
            IOObjectRelease(interface);
            break;
        }
        CFTypeRef property = IORegistryEntryCreateCFProperty(controller, CFSTR(kIOMACAddress), kCFAllocatorDefault, 0);
        if (property != NULL) {
            if (address != NULL)
                CFRelease(address);
            address = property;
        }
        IOObjectRelease(controller);
        IOObjectRelease(interface);
    }
    IOObjectRelease(iterator);
    return [(id)address autorelease];
}
