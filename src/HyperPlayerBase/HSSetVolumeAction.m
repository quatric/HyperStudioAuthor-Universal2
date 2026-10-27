#import "HSSetVolumeAction.h"
@implementation HSSetVolumeAction
- (void)setVolumeLevel:(CGFloat)aLevel
{
    if (_volumeLevel != (float)aLevel) {
        [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Volume Level" value:@"" table:@"UndoManager"]];
        [[[self undoManager] prepareWithInvocationTarget:self] setVolumeLevel:[self volumeLevel]];
        [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSVolumeLevelAttribute) ofObject:self withUserInfo:nil];
        _volumeLevel = aLevel;
        [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSVolumeLevelAttribute) ofObject:self withUserInfo:nil];
    }
}
- (CGFloat)volumeLevel
{
    return _volumeLevel;
}
- (void)startInContext:(id)aContext
{
    // Sets the default output device's volume on the master channel and every
    // channel of its output stream (the original used the pre-10.5
    // AudioHardware/AudioDevice property calls).
    AudioObjectID device = 0;
    UInt32 size = sizeof(device);
    AudioObjectPropertyAddress address = {
        kAudioHardwarePropertyDefaultOutputDevice, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain };
    AudioObjectGetPropertyData(kAudioObjectSystemObject, &address, 0, NULL, &size, &device);
    AudioStreamBasicDescription format = { 0 };
    size = sizeof(format);
    address = (AudioObjectPropertyAddress){
        kAudioDevicePropertyStreamFormat, kAudioDevicePropertyScopeOutput, kAudioObjectPropertyElementMain };
    AudioObjectGetPropertyData(device, &address, 0, NULL, &size, &format);
    Float32 volume = _volumeLevel;
    UInt32 channel = 0;
    do {
        address = (AudioObjectPropertyAddress){
            kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeOutput, channel };
        AudioObjectSetPropertyData(device, &address, 0, NULL, sizeof(volume), &volume);
        channel++;
    } while (channel <= format.mChannelsPerFrame);
    [self notifyDidFinish];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:@"volumeLevel"];
}
- (id)XMLElementName
{
    return @"actSetVolume";
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (BOOL)supportedInIPad
{
    return YES;
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [super XMLElementRepresentationInContext:aContext];
    [element addAttribute:[NSXMLNode attributeWithName:@"volumeLevel" stringValue:[NSString stringWithFormat:@"%.3f", (double)_volumeLevel]]];
    return element;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return NO;
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    id representation = [super HTML5DictionaryRepresentationInContext:aContext];
    [representation setObject:[NSString stringWithFormat:@"%.3f", (double)_volumeLevel] forKey:@"volumeLevel"];
    return representation;
}

@end
