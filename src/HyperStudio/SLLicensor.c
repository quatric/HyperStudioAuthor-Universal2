#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "SLLicensor.h"

#define BE32(p) ((unsigned int)((const unsigned char *)(p))[0] << 24 | (unsigned int)((const unsigned char *)(p))[1] << 16 | \
                 (unsigned int)((const unsigned char *)(p))[2] << 8 | (unsigned int)((const unsigned char *)(p))[3])

static void SLPutBE32(unsigned char *aTarget, unsigned int aValue)
{
    aTarget[0] = (unsigned char)(aValue >> 24);
    aTarget[1] = (unsigned char)(aValue >> 16);
    aTarget[2] = (unsigned char)(aValue >> 8);
    aTarget[3] = (unsigned char)aValue;
}

static double SLGetBEDouble(const unsigned char *aBytes)
{
    uint64_t bits = (uint64_t)BE32(aBytes) << 32 | BE32(aBytes + 4);
    double value;
    memcpy(&value, &bits, sizeof(value));
    return value;
}

static void SLPutBEDouble(unsigned char *aTarget, double aValue)
{
    uint64_t bits;
    memcpy(&bits, &aValue, sizeof(bits));
    SLPutBE32(aTarget, (unsigned int)(bits >> 32));
    SLPutBE32(aTarget + 4, (unsigned int)bits);
}

#pragma mark - Allocator

static void *SLDefaultAllocateCallBack(size_t aSize)
{
    return CFAllocatorAllocate(NULL, (CFIndex)aSize, 0);
}

static void SLDefaultDeallocateCallBack(void *aPointer)
{
    CFAllocatorDeallocate(NULL, aPointer);
}

static const SLAllocatorContext sDefaultAllocatorContext = { NULL, SLDefaultAllocateCallBack, SLDefaultDeallocateCallBack };

void *SLAllocatorAllocate(const SLAllocatorContext *aContext, size_t aSize)
{
    if (aContext == NULL) {
        aContext = &sDefaultAllocatorContext;
    }
    return aContext->allocate(aSize);
}

void SLAllocatorDeallocate(const SLAllocatorContext *aContext, void *aPointer)
{
    if (aContext == NULL) {
        aContext = &sDefaultAllocatorContext;
    }
    aContext->deallocate(aPointer);
}

#pragma mark - Environment

// The licensor, the licensee info and the license in use, each with the callback that releases it.
typedef struct SLEnvironmentSlot {
    void *object;
    void *context;
    size_t size;
    SLReleaseCallBack callBack;
} SLEnvironmentSlot;

static SLEnvironmentSlot sLicensorSlot, sLicenseeInfoSlot, sLicenseSlot;

static void SLEnvironmentSetSlot(SLEnvironmentSlot *aSlot, void *aObject, size_t aSize, void *aContext,
                                 SLReleaseCallBack aCallBack)
{
    if (aSlot->object != aObject) {
        if (aSlot->callBack != NULL) {
            aSlot->callBack(aSlot->context, aSlot->object, aSlot->size);
        }
        aSlot->object = aObject;
        aSlot->context = aContext;
        aSlot->size = aSize;
        aSlot->callBack = aCallBack;
    }
}

void SLEnvironmentCleanUp(void)
{
    SLEnvironmentSlot *slots[3] = { &sLicensorSlot, &sLicenseeInfoSlot, &sLicenseSlot };
    for (int i = 0; i < 3; i++) {
        if (slots[i]->callBack != NULL) {
            slots[i]->callBack(slots[i]->context, slots[i]->object, slots[i]->size);
        }
        memset(slots[i], 0, sizeof(*slots[i]));
    }
}

void *SLEnvironmentGetLicensor(void)
{
    return sLicensorSlot.object;
}

void *SLEnvironmentGetLicenseeInfo(void)
{
    return sLicenseeInfoSlot.object;
}

void *SLEnvironmentGetLicense(void)
{
    return sLicenseSlot.object;
}

void SLEnvironmentSetLicensorNoCopy(void *aLicensor, size_t aSize, void *aContext, SLReleaseCallBack aCallBack)
{
    SLEnvironmentSetSlot(&sLicensorSlot, aLicensor, aSize, aContext, aCallBack);
}

void SLEnvironmentSetLicenseeInfoNoCopy(void *aInfo, size_t aSize, void *aContext, SLReleaseCallBack aCallBack)
{
    SLEnvironmentSetSlot(&sLicenseeInfoSlot, aInfo, aSize, aContext, aCallBack);
}

void SLEnvironmentSetLicenseNoCopy(void *aLicense, size_t aSize, void *aContext, SLReleaseCallBack aCallBack)
{
    SLEnvironmentSetSlot(&sLicenseSlot, aLicense, aSize, aContext, aCallBack);
}

#pragma mark - License

unsigned int SLLicenseDescriptorBytesEncryptedFlag = 1;

static char sEncryptKey[0x40];

const char *SLLicenseEncryptKeyForDate(double aDate)
{
    snprintf(sEncryptKey, sizeof(sEncryptKey), "%f", aDate);
    return sEncryptKey;
}

// Copies aLength bytes starting at aSource (a pointer into the descriptor's blob) and decrypts them when the
// blob is encrypted.
unsigned int SLLicenseGetBytes(const SLLicenseDescriptor *aDescriptor, const void *aSource, size_t aLength,
                               void *aTarget)
{
    const unsigned char *source = aSource;
    if (source < aDescriptor->base || aTarget == NULL) {
        return 0;
    }
    size_t offset = (size_t)(source - aDescriptor->base);
    if (aDescriptor->contentSize < offset + aLength) {
        return 0;
    }
    if ((SLLicenseDescriptorBytesEncryptedFlag & aDescriptor->flags) == 0) {
        memcpy(aTarget, source, aLength);
    } else {
        const char *key = SLLicenseEncryptKeyForDate(aDescriptor->creationDate);
        SSDecryptBytesWithKey(source, (int)aLength, (unsigned int)offset, (const unsigned char *)key,
                              (unsigned int)strlen(key), aTarget);
    }
    return (unsigned int)aLength;
}

// Reads the header and the pointers into the content of a serialized license.
int SLLicenseValidateLicense(const unsigned char *aBytes, unsigned int aSize, const char *aKey,
                             SLLicenseDescriptor *aDescriptor)
{
    if (aSize <= 0x96 || BE32(aBytes + 0x8e) != 0x616c3031) {
        return -1;
    }
    struct SSCRC32Context crc;
    SSCRC32Init(&crc);
    if (SSCRC32Update(&crc, aBytes, 0x8e) != 0x8e) {
        return -1;
    }
    unsigned int contentSize = aSize - 0x96;
    const unsigned char *content = aBytes + 0x96;
    if (SSCRC32Update(&crc, content, contentSize) != contentSize || BE32(aBytes + 0x92) != ~crc.crc) {
        return -1;
    }
    unsigned char header[0x8e];
    SSDecryptBytesWithKey(aBytes, 0x8e, 0, (const unsigned char *)aKey, (unsigned int)strlen(aKey), header);
    if (contentSize <= 0x8d) {
        return -1;
    }
    SLLicenseDescriptor d;
    memset(&d, 0, sizeof(d));
#define POINTER_AT(offset) ({ unsigned int o_ = BE32(header + (offset)); o_ < contentSize ? content + o_ : (const unsigned char *)NULL; })
    d.version = BE32(header);
    d.creationDate = SLGetBEDouble(header + 4);
    d.dates[0] = SLGetBEDouble(header + 12);
    d.dates[1] = SLGetBEDouble(header + 20);
    d.dates[2] = SLGetBEDouble(header + 28);
    d.contentSize = BE32(header + 36);
    d.reserved = BE32(header + 40);
    d.codeInfo = BE32(header + 44);
    d.registrationLength = BE32(header + 48);
    d.registration = POINTER_AT(52);
    d.registrationCRC = (unsigned short)(header[56] << 8 | header[57]);
    d.identifierLength = BE32(header + 58);
    d.identifier = POINTER_AT(62);
    d.typeLength = BE32(header + 66);
    d.type = POINTER_AT(70);
    d.pathLength = BE32(header + 74);
    d.path = POINTER_AT(78);
    d.field84 = BE32(header + 82);
    d.field88 = POINTER_AT(86);
    d.codeLimit = BE32(header + 90);
    d.field96 = BE32(header + 94);
    d.field100 = POINTER_AT(98);
    d.shortVersionLength = BE32(header + 102);
    d.shortVersion = POINTER_AT(106);
    d.versionLength = BE32(header + 110);
    d.version2 = POINTER_AT(114);
    d.userDataLength = BE32(header + 118);
    d.userData = POINTER_AT(122);
    d.serialUserDataLength = BE32(header + 126);
    d.serialUserData = POINTER_AT(130);
    d.bannedLength = BE32(header + 134);
    d.banned = POINTER_AT(138);
#undef POINTER_AT
    d.flags = 0;
    d.base = content;
    if (d.version == 0 && d.creationDate != 0.0 && d.dates[0] != 0.0 && content != NULL && d.contentSize != 0
        && d.contentSize + 0x96 <= aSize && d.reserved == 0 && d.codeLimit != 0 && d.registrationLength != 0
        && d.registration != NULL && d.identifierLength != 0 && d.identifier != NULL && d.typeLength != 0
        && d.type != NULL && d.pathLength != 0 && d.path != NULL && d.field84 != 0 && d.field88 != NULL
        && d.field96 != 0 && d.field100 != NULL) {
        if ((d.shortVersionLength == 0) != (d.shortVersion == NULL)) {
            return -1;
        }
        if ((d.versionLength == 0) != (d.version2 == NULL)) {
            return -1;
        }
        if ((d.serialUserDataLength == 0) != (d.serialUserData == NULL)) {
            return -1;
        }
        if ((d.userDataLength == 0) != (d.userData == NULL)) {
            return -1;
        }
        if ((d.bannedLength == 0) != (d.banned == NULL)) {
            return -1;
        }
        if (aDescriptor != NULL) {
            *aDescriptor = d;
        }
        return 0;
    }
    return -1;
}

void SLLicenseDestroy(SLLicense *aLicense)
{
    if (aLicense->releaseCallBack != NULL) {
        aLicense->releaseCallBack(aLicense->releaseContext, aLicense->bytes, aLicense->bytesSize);
    }
    SLAllocatorDeallocate(aLicense->allocator, aLicense);
}

static const unsigned char *SLDescriptorPointerOffset(const unsigned char *aPointer, const unsigned char *aBase,
                                                       unsigned int *aOffset)
{
    *aOffset = aPointer == NULL ? 0xffffffff : (unsigned int)(aPointer - aBase);
    return aPointer;
}

// Writes the license into the blob format: the header (encrypted with the key stored in it), a CRC and the content.
int SLLicenseSerialize(const SLLicense *aLicense, unsigned char *aBytes, unsigned int *aSize)
{
    if (aSize == NULL) {
        return 1;
    }
    const SLLicenseDescriptor *d = &aLicense->descriptor;
    unsigned int total = d->contentSize + 0x96;
    if (aBytes == NULL) {
        *aSize = total;
        return 0;
    }
    if (*aSize < total) {
        return 1;
    }
    struct SSCRC32Context crc;
    SSCRC32Init(&crc);
    unsigned int o;
    SLPutBE32(aBytes, d->version);
    SLPutBEDouble(aBytes + 4, d->creationDate);
    SLPutBEDouble(aBytes + 12, d->dates[0]);
    SLPutBEDouble(aBytes + 20, d->dates[1]);
    SLPutBEDouble(aBytes + 28, d->dates[2]);
    SLPutBE32(aBytes + 36, d->contentSize);
    SLPutBE32(aBytes + 40, d->reserved);
    SLPutBE32(aBytes + 44, d->codeInfo);
    SLPutBE32(aBytes + 48, d->registrationLength);
    SLDescriptorPointerOffset(d->registration, d->base, &o);
    SLPutBE32(aBytes + 52, o);
    aBytes[56] = (unsigned char)(d->registrationCRC >> 8);
    aBytes[57] = (unsigned char)d->registrationCRC;
    SLPutBE32(aBytes + 58, d->identifierLength);
    SLDescriptorPointerOffset(d->identifier, d->base, &o);
    SLPutBE32(aBytes + 62, o);
    SLPutBE32(aBytes + 66, d->typeLength);
    SLDescriptorPointerOffset(d->type, d->base, &o);
    SLPutBE32(aBytes + 70, o);
    SLPutBE32(aBytes + 74, d->pathLength);
    SLDescriptorPointerOffset(d->path, d->base, &o);
    SLPutBE32(aBytes + 78, o);
    SLPutBE32(aBytes + 82, d->field84);
    SLDescriptorPointerOffset(d->field88, d->base, &o);
    SLPutBE32(aBytes + 86, o);
    SLPutBE32(aBytes + 90, d->codeLimit);
    SLPutBE32(aBytes + 94, d->field96);
    SLDescriptorPointerOffset(d->field100, d->base, &o);
    SLPutBE32(aBytes + 98, o);
    SLPutBE32(aBytes + 102, d->shortVersionLength);
    SLDescriptorPointerOffset(d->shortVersion, d->base, &o);
    SLPutBE32(aBytes + 106, o);
    SLPutBE32(aBytes + 110, d->versionLength);
    SLDescriptorPointerOffset(d->version2, d->base, &o);
    SLPutBE32(aBytes + 114, o);
    SLPutBE32(aBytes + 118, d->userDataLength);
    SLDescriptorPointerOffset(d->userData, d->base, &o);
    SLPutBE32(aBytes + 122, o);
    SLPutBE32(aBytes + 126, d->serialUserDataLength);
    SLDescriptorPointerOffset(d->serialUserData, d->base, &o);
    SLPutBE32(aBytes + 130, o);
    SLPutBE32(aBytes + 134, d->bannedLength);
    SLDescriptorPointerOffset(d->banned, d->base, &o);
    SLPutBE32(aBytes + 138, o);

    unsigned char *content = aBytes + 0x96;
    if ((SLLicenseDescriptorBytesEncryptedFlag & d->flags) == 0) {
        SSEncryptBytesWithKeyAndOffset(aBytes, 0x8e, d->field100, d->field96, 0, NULL);
        if (SSCRC32Update(&crc, aBytes, 0x8e) != 0x8e) {
            return 1;
        }
        const char *key = SLLicenseEncryptKeyForDate(d->creationDate);
        SSEncryptBytesWithKeyAndOffset(d->base, (int)d->contentSize, (const unsigned char *)key,
                                       (unsigned int)strlen(key), 0, content);
    } else {
        // The content is stored encrypted already; the key of the header is read back through the blob.
        unsigned char *key = malloc(d->field96 + 1);
        if (key == NULL || SLLicenseGetBytes(d, d->field100, d->field96 + 1, key) == 0) {
            free(key);
            return 1;
        }
        SSEncryptBytesWithKeyAndOffset(aBytes, 0x8e, key, d->field96, 0, NULL);
        free(key);
        if (SSCRC32Update(&crc, aBytes, 0x8e) != 0x8e) {
            return 1;
        }
        memcpy(content, d->base, d->contentSize);
    }
    if (SSCRC32Update(&crc, content, d->contentSize) != d->contentSize) {
        return 1;
    }
    memcpy(aBytes + 0x8e, "al01", 4);
    SLPutBE32(aBytes + 0x92, ~crc.crc);
    return 0;
}

#pragma mark - License getters

static const SLLicenseDescriptor *SLDescriptorOrCurrent(const SLLicense *aLicense)
{
    if (aLicense == NULL) {
        aLicense = SLEnvironmentGetLicense();
    }
    return aLicense != NULL ? &aLicense->descriptor : NULL;
}

// Copies a counted string of the descriptor (aLength characters plus a terminator).
static int SLLicenseCopyString(const SLLicenseDescriptor *aDescriptor, const unsigned char *aSource,
                               unsigned int aLength, void *aBuffer, unsigned int *aSize)
{
    unsigned int size = aLength + 1;
    if (aBuffer == NULL) {
        *aSize = size;
        return 0;
    }
    if (size <= *aSize) {
        return SLLicenseGetBytes(aDescriptor, aSource, size, aBuffer) == 0;
    }
    return 1;
}

int SLLicenseGetType(const SLLicense *aLicense)
{
    const SLLicenseDescriptor *d = SLDescriptorOrCurrent(aLicense);
    if (d == NULL || d->typeLength == 0) {
        return 0;
    }
    char *name = SLAllocatorAllocate(NULL, d->typeLength + 1);
    if (name == NULL) {
        return 0;
    }
    int type = 0;
    if (SLLicenseGetBytes(d, d->type, d->typeLength + 1, name) != 0) {
        if (strcmp(name, "LOCAL_MACHINE") == 0) {
            type = 1;
        } else if (strcmp(name, "LIMITED_NETWORK") == 0) {
            type = 2;
        } else if (strcmp(name, "LOCAL_MACHINE_TRIAL") == 0) {
            type = 3;
        }
    }
    SLAllocatorDeallocate(NULL, name);
    return type;
}

int SLLicenseGetIdentifier(const SLLicense *aLicense, char *aBuffer, unsigned int *aSize)
{
    if (aSize == NULL) {
        return 8;
    }
    const SLLicenseDescriptor *d = SLDescriptorOrCurrent(aLicense);
    if (d == NULL || d->identifierLength == 0) {
        return 0;
    }
    return SLLicenseCopyString(d, d->identifier, d->identifierLength, aBuffer, aSize);
}

double SLLicenseGetCreationDate(const SLLicense *aLicense)
{
    const SLLicenseDescriptor *d = SLDescriptorOrCurrent(aLicense);
    return d != NULL ? d->creationDate : 0.0;
}

unsigned int SLLicenseGetCodeLimit(const SLLicense *aLicense)
{
    const SLLicenseDescriptor *d = SLDescriptorOrCurrent(aLicense);
    return d != NULL ? d->codeLimit : 0;
}

int SLLicenseGetCodeInfo(const SLLicense *aLicense)
{
    const SLLicenseDescriptor *d = SLDescriptorOrCurrent(aLicense);
    return d != NULL ? (int)d->codeInfo : -1;
}

static int SLLicenseGetRawData(const SLLicense *aLicense, int aWhich, void *aBuffer, unsigned int *aSize)
{
    if (aSize == NULL) {
        return 8;
    }
    const SLLicenseDescriptor *d = SLDescriptorOrCurrent(aLicense);
    if (d == NULL) {
        return 0;
    }
    const unsigned char *data = aWhich == 0 ? d->userData : d->serialUserData;
    unsigned int length = aWhich == 0 ? d->userDataLength : d->serialUserDataLength;
    if (data == NULL) {
        *aSize = 0;
        return 0;
    }
    if (length == 0) {
        return 0;
    }
    if (aBuffer == NULL) {
        *aSize = length;
        return 0;
    }
    if (length <= *aSize) {
        return SLLicenseGetBytes(d, data, length, aBuffer) == 0;
    }
    return 0;
}

int SLLicenseGetUserData(const SLLicense *aLicense, void *aBuffer, unsigned int *aSize)
{
    return SLLicenseGetRawData(aLicense, 0, aBuffer, aSize);
}

int SLLicenseGetSerialUserData(const SLLicense *aLicense, void *aBuffer, unsigned int *aSize)
{
    return SLLicenseGetRawData(aLicense, 1, aBuffer, aSize);
}

int SLLicenseGetApplicationVersion(const SLLicense *aLicense, char *aBuffer, unsigned int *aSize)
{
    if (aSize == NULL) {
        return 8;
    }
    const SLLicenseDescriptor *d = SLDescriptorOrCurrent(aLicense);
    if (d == NULL) {
        return 0;
    }
    if (d->version2 == NULL) {
        *aSize = 0;
        return 0;
    }
    if (d->versionLength == 0) {
        return 0;
    }
    return SLLicenseCopyString(d, d->version2, d->versionLength, aBuffer, aSize);
}

int SLLicenseGetApplicationShortVersion(const SLLicense *aLicense, char *aBuffer, unsigned int *aSize)
{
    if (aSize == NULL) {
        return 8;
    }
    const SLLicenseDescriptor *d = SLDescriptorOrCurrent(aLicense);
    if (d == NULL) {
        return 0;
    }
    if (d->shortVersion == NULL) {
        *aSize = 0;
        return 0;
    }
    if (d->shortVersionLength == 0) {
        return 0;
    }
    return SLLicenseCopyString(d, d->shortVersion, d->shortVersionLength, aBuffer, aSize);
}

int SLLicenseGetRegistrationString(const SLLicense *aLicense, char *aBuffer, unsigned int *aSize)
{
    if (aSize == NULL) {
        return 8;
    }
    const SLLicenseDescriptor *d = SLDescriptorOrCurrent(aLicense);
    if (d == NULL || d->registrationLength == 0) {
        return 0;
    }
    unsigned int size = d->registrationLength + 1;
    if (aBuffer == NULL) {
        *aSize = size;
        return 0;
    }
    if (size <= *aSize && SLLicenseGetBytes(d, d->registration, size, aBuffer) != 0) {
        return SLValidateEncodedSerialString(aBuffer, (short)d->registrationCRC) != 0;
    }
    return 0;
}

int SLLicenseGetStoragePath(char *aBuffer, unsigned int *aSize)
{
    const SLLicense *license = SLEnvironmentGetLicense();
    if (license == NULL || aSize == NULL) {
        return 0;
    }
    const SLLicenseDescriptor *d = &license->descriptor;
    unsigned int size = d->pathLength + 1;
    if (aBuffer == NULL) {
        *aSize = size;
        return 0;
    }
    if (size <= *aSize) {
        return SLLicenseGetBytes(d, d->path, size, aBuffer) == 0;
    }
    return 0;
}

double SLLicenseGetSystemTime(void)
{
    return CFAbsoluteTimeGetCurrent();
}

#pragma mark - Identifiers

int SLLicenseGetBannedIdentifiers(const SLLicenseDescriptor *aDescriptor, int aMode,
                                  struct SLBannedIdentifier *aItems, unsigned int *aCount, int *aTotalLength)
{
    if (aDescriptor->banned == NULL) {
        *aCount = 0;
        return 0;
    }
    if (aDescriptor->bannedLength != 0) {
        unsigned char countBytes[4] = { 0, 0, 0, 0 };
        if (SLLicenseGetBytes(aDescriptor, aDescriptor->banned, 4, countBytes) != 0) {
            unsigned int count = BE32(countBytes);
            if (count == 0) {
                return 0;
            }
            unsigned int headerLength = count * 8 + 4;
            unsigned int available = aDescriptor->bannedLength;
            if (headerLength < available) {
                unsigned int found = 0;
                unsigned int totalLength = 0;
                if (aItems == NULL && aMode == 2) {
                    totalLength = available - headerLength;
                    found = count;
                } else {
                    unsigned int matchBits = 0x80, mask = 0x80;
                    if (aMode != 0) {
                        matchBits = 0;
                        if (aMode != 1) {
                            mask = 0;
                        }
                    }
                    available -= 4;
                    const unsigned char *position = aDescriptor->banned + 4;
                    for (unsigned int i = 0; i < count; i++) {
                        unsigned char entry[8];
                        if (available < 9 || SLLicenseGetBytes(aDescriptor, position, 8, entry) == 0) {
                            return 1;
                        }
                        unsigned int flags = BE32(entry);
                        unsigned int length = BE32(entry + 4);
                        if (available < length + 9) {
                            return 1;
                        }
                        if (matchBits == (flags & mask)) {
                            found++;
                            totalLength += length + 1;
                            if (aItems != NULL) {
                                aItems->data = position + 8;
                                aItems->length = length;
                                aItems->flags = flags;
                                aItems++;
                            }
                        }
                        position += length + 9;
                        available -= length + 9;
                    }
                }
                *aCount = found;
                if (aTotalLength != NULL) {
                    *aTotalLength = (int)totalLength;
                }
                return 0;
            }
        }
    }
    return 1;
}

// Compares an identifier in the stored form with one in the alphabet of letters and digits.
int SLLicenseCompareIdentifiers(const char *aFirst, const char *aSecond)
{
    char first;
    for (;;) {
        first = *aFirst;
        if (first == '\0' || *aSecond == '\0') {
            break;
        }
        char value = (char)(first - 0x32);
        char scaled = (char)((unsigned short)(value * 0x10093) >> 8);
        unsigned char decoded = (unsigned char)(((value + ((value >> 7) - value / 0x1d))
                                                 - (char)((short)(value * 0x100b3) >> 12))
                                                + (scaled >> 3) * -7 + (scaled >> 4) * 7);
        if ((unsigned char)*aSecond != (unsigned char)(decoded + 0x61 + (decoded / 0x1a) * -0x4b)) {
            return -1;
        }
        aFirst++;
        aSecond++;
    }
    return *aSecond != first ? -1 : 0;
}

#pragma mark - Serial strings

unsigned int SLDecodeGetBufferSizeForSerialStringLength(unsigned int aLength)
{
    return ((aLength * 6 + 5) >> 3) + 1;
}

// Decodes a serial string into its text; returns the text length plus one, or the buffer size needed when aBuffer is NULL.
unsigned int SLDecodeSerialString(char *aText, char *aBuffer, unsigned int aBufferSize, const short *aCRC)
{
    size_t length = strlen(aText);
    if (length == 0) {
        return 0;
    }
    unsigned int byteLength = (unsigned int)(length * 6 + 5) >> 3;
    unsigned int needed = byteLength + 1;
    if (aBuffer == NULL) {
        return needed;
    }
    if (needed <= aBufferSize && (aCRC == NULL || (short)SSCRC16Digest((unsigned char *)aText, (unsigned short)length) == *aCRC)
        && SSDecodeBytes(aText, (int)length, (unsigned char *)aBuffer, needed) == 0) {
        aBuffer[byteLength] = '\0';
        if (memcmp(aBuffer, "SLUH", 4) == 0) {
            char *text = aBuffer + 4;
            unsigned int textLength = 0;
            if (BE32(aBuffer + 4) == 0x312e3155) {
                textLength = (unsigned int)((unsigned char)aBuffer[8] << 8 | (unsigned char)aBuffer[9]);
                unsigned short stored = (unsigned short)((unsigned char)aBuffer[10] << 8 | (unsigned char)aBuffer[11]);
                aBuffer[10] = 0;
                aBuffer[11] = 0;
                text = aBuffer + 12;
                if (stored != SSCRC16Digest((unsigned char *)aBuffer, (unsigned short)(needed - 1))) {
                    return 0;
                }
            }
            memmove(aBuffer, text, strlen(text) + 1);
            return textLength + 1;
        }
    }
    return 0;
}

unsigned int SLEncodeSerialString(const char *aString, char *aBuffer, unsigned int aBufferSize, unsigned short *aCRC)
{
    unsigned short length = (unsigned short)strlen(aString);
    if (length == 0) {
        return 0;
    }
    unsigned int rawLength = (unsigned int)length + 12;
    unsigned int textLength = (rawLength * 8 + 5) / 6;
    if (textLength == 0) {
        return 0;
    }
    unsigned int total = rawLength + textLength;
    if (aBuffer == NULL) {
        return total;
    }
    if (total > aBufferSize) {
        return 0;
    }
    unsigned char *raw = (unsigned char *)aBuffer + textLength;
    memcpy(raw, "SLUH1.1U", 8);
    raw[8] = (unsigned char)(length >> 8);
    raw[9] = (unsigned char)length;
    raw[10] = 0;
    raw[11] = 0;
    memcpy(raw + 12, aString, length);
    unsigned short crc = SSCRC16Digest(raw, (unsigned short)rawLength);
    raw[10] = (unsigned char)(crc >> 8);
    raw[11] = (unsigned char)crc;
    if (SSEncodeBytes(raw, (int)rawLength, aBuffer, textLength) != 0) {
        return textLength;
    }
    raw[0] = 0;
    if (aCRC != NULL) {
        *aCRC = SSCRC16Digest((unsigned char *)aBuffer, (unsigned short)textLength);
    }
    return textLength;
}

int SLValidateEncodedSerialString(const char *aText, short aCRC)
{
    size_t length = strlen(aText);
    if (length != 0 && (short)SSCRC16Digest((const unsigned char *)aText, (unsigned short)length) == aCRC) {
        unsigned char decoded[0xe];
        if (SSDecodeBytes(aText, 0x11, decoded, 0xe) == 0 && memcmp(decoded, "SLUH", 4) == 0) {
            unsigned int version = BE32(decoded + 4);
            if (version == 1 || version == 0x312e3155) {
                return 0;
            }
        }
    }
    return -1;
}
