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

#pragma mark - Licensor data

static const unsigned char *SLBlobPointer(const unsigned char *aBase, unsigned int aOffset, unsigned int aSize)
{
    return aOffset < aSize ? aBase + aOffset : NULL;
}

int SLLicensorIsDataConsistent(const unsigned char *aBytes, unsigned int aSize, SLLicensorAnalysis *aAnalysis)
{
#define W(i) BE32(aBytes + 4 * (i))
    if (aSize < 0x7c) {
        return 0;
    }
    SLLicensorAnalysis *a = aAnalysis;
    a->base = aBytes + 0x7c;
    a->version = W(0);
    a->size = W(1);
    a->sizeA = W(2);
    a->baseA = SLBlobPointer(a->base, W(3), aSize);
    a->date = SLGetBEDouble(aBytes + 0x10);
    a->keyBase = SLBlobPointer(a->base, W(6), aSize);
    a->pathCount = W(7);
    a->pathTable = SLBlobPointer(a->base, W(8), aSize);
    a->typeCount = W(9);
    a->typeTable = SLBlobPointer(a->base, W(10), aSize);
    a->length11 = W(11);
    a->pointer12 = SLBlobPointer(a->base, W(12), aSize);
    a->defaultIndex = W(13);
    a->magic = W(14);
    a->codeMapCount = W(15);
    a->codeMapTable = SLBlobPointer(a->base, W(16), aSize);
    a->dateB = SLGetBEDouble(aBytes + 0x44);
    a->sizeB = W(0x13);
    a->baseB = SLBlobPointer(a->base, W(0x14), aSize);
    a->keyBaseB = SLBlobPointer(a->base, W(0x15), aSize);
    a->restrictionCount = W(0x16);
    a->restrictions = SLBlobPointer(a->base, W(0x17), aSize);
    a->dateC = SLGetBEDouble(aBytes + 0x60);
    a->sizeC = W(0x1a);
    a->baseC = SLBlobPointer(a->base, W(0x1b), aSize);
    a->pointerC = SLBlobPointer(a->base, W(0x1c), aSize);
    a->countC = W(0x1d);
    a->tableC = SLBlobPointer(a->base, W(0x1e), aSize);
#undef W

    if (a->version != 1 || a->size == 0 || a->size + 0x7c > aSize || a->date == 0.0 || a->baseA == NULL) {
        return 0;
    }
    unsigned int extra = 0;
    int hasB = 0, hasC = 0;
    if (a->dateB != 0.0) {
        if (a->baseB == NULL || a->keyBaseB == NULL || a->sizeB == 0 || a->date - a->dateB > 120.0 ||
            a->dateB - a->date > 120.0 || a->restrictionCount == 0 || a->restrictions == NULL) {
            return 0;
        }
        extra = a->sizeB;
        hasB = 1;
    }
    if (a->dateC != 0.0) {
        if (a->baseC == NULL || a->pointerC == NULL || a->sizeC == 0 || a->date - a->dateC > 120.0 ||
            a->dateC - a->date > 120.0 || a->countC == 0 || a->tableC == NULL) {
            return 0;
        }
        extra += a->sizeC;
        hasC = 1;
    }
    unsigned int sizeA = a->sizeA;
    if (sizeA == 0 || extra + sizeA > a->size || a->magic != 0x7369616c || a->pathCount == 0 ||
        a->pathTable == NULL) {
        return 0;
    }
    if (a->defaultIndex != 0xffffffff &&
        (a->defaultIndex >= a->pathCount || a->pointer12 == NULL || a->length11 == 0)) {
        return 0;
    }
    if (a->typeCount == 0 || a->typeTable == NULL) {
        return 0;
    }

    // Every path and type entry is a length and an offset into the strings.
    unsigned int pathBytes = a->pathCount * 8;
    if (pathBytes > sizeA) {
        return 0;
    }
    unsigned int i;
    for (i = 0; i < a->pathCount && sizeA > 7; i++) {
        const unsigned char *entry = a->pathTable + i * 8;
        unsigned int length = BE32(entry), offset = BE32(entry + 4);
        if (offset >= sizeA || length == 0 || (pathBytes += 1 + length) > sizeA) {
            break;
        }
    }
    if (i != a->pathCount) {
        return 0;
    }
    unsigned int typeBytes = a->typeCount * 8;
    if (typeBytes > sizeA) {
        return 0;
    }
    for (i = 0; i < a->typeCount && sizeA > 7; i++) {
        const unsigned char *entry = a->typeTable + i * 8;
        unsigned int length = BE32(entry), offset = BE32(entry + 4);
        if (offset >= sizeA || length == 0 || (typeBytes += 1 + length) > sizeA) {
            break;
        }
    }
    if (i != a->typeCount || a->codeMapCount == 0 || a->codeMapTable == NULL || sizeA < 0x18) {
        return 0;
    }

    unsigned int codeBytes = 0;
    for (i = 0; i < a->codeMapCount; i++) {
        const unsigned char *entry = a->codeMapTable + i * 0x18;
        unsigned int length = BE32(entry), offset = BE32(entry + 4), type = BE32(entry + 8);
        unsigned int index = BE32(entry + 12), length2 = BE32(entry + 16), offset2 = BE32(entry + 20);
        const unsigned char *string = SLBlobPointer(a->baseA, offset, sizeA);
        const unsigned char *string2 = SLBlobPointer(a->baseA, offset2, sizeA);
        if (length == 0 || string == NULL) {
            return 0;
        }
        if (string2 == NULL ? length2 != 0 : length2 == 0) {
            return 0;
        }
        if (type != 0x2e537552 && type != 0x2e54726c && type != 0x2e4e6574) {
            return 0;
        }
        if (index >= a->pathCount) {
            return 0;
        }
        codeBytes += 0x19 + length2 + length;
    }
    unsigned int total = pathBytes + typeBytes + codeBytes;
    if (a->length11 != 0) {
        total += 1 + a->length11;
    }
    if (total > sizeA) {
        return 0;
    }

    if (hasB) {
        unsigned int accumulated = 0;
        for (i = 0; i < a->restrictionCount && a->sizeB > 0x13; i++) {
            const unsigned char *entry = a->restrictions + i * 0x14;
            unsigned int length = BE32(entry), offset = BE32(entry + 4), count = BE32(entry + 8);
            unsigned int elementSize = BE32(entry + 12), offset2 = BE32(entry + 16);
            if (SLBlobPointer(a->baseB, offset, a->sizeB) == NULL || length == 0 ||
                SLBlobPointer(a->baseB, offset2, a->sizeB) == NULL || count == 0 || elementSize != 4) {
                break;
            }
            accumulated += 0x15 + length + count * 4;
        }
        if (i != a->restrictionCount || a->sizeB != accumulated) {
            return 0;
        }
    }
    if (hasC) {
        for (i = 0; i < a->countC; i++) {
            if (a->sizeC < 0x10) {
                return 0;
            }
            const unsigned char *entry = a->tableC + i * 16;
            unsigned int length = BE32(entry), offset = BE32(entry + 4);
            unsigned int length2 = BE32(entry + 8), offset2 = BE32(entry + 12);
            if (SLBlobPointer(a->baseC, offset, a->sizeC) == NULL || length == 0 ||
                SLBlobPointer(a->baseC, offset2, a->sizeC) == NULL || length2 == 0) {
                return 0;
            }
        }
    }
    return 1;
}

static void SLLicensorReleaseCallBack(void *aContext, void *aObject, size_t aSize)
{
    SLLicensor *licensor = aObject;
    if (licensor != NULL) {
        if (licensor->releaseCallBack != NULL) {
            licensor->releaseCallBack(licensor->releaseContext, (void *)licensor->bytes, licensor->size);
        }
        SLAllocatorDeallocate(NULL, licensor);
    }
}

static int SLLicensorInitializeWithBytesNoCopy(const void *aBytes, unsigned int aSize, void *aContext,
                                               SLReleaseCallBack aCallBack, unsigned int aGroup,
                                               unsigned int aRawLength)
{
    if (aBytes == NULL || aSize == 0) {
        return SLResultBadArgument;
    }
    if (SLEnvironmentGetLicenseeInfo() != NULL) {
        return SLResultAlreadyAttached;
    }
    SLLicensor *licensor = SLAllocatorAllocate(NULL, sizeof(SLLicensor));
    if (licensor == NULL) {
        return SLResultFailed;
    }
    memset(licensor, 0, sizeof(*licensor));
    if (!SLLicensorIsDataConsistent(aBytes, aSize, &licensor->analysis)) {
        SLAllocatorDeallocate(NULL, licensor);
        return SLResultInvalidData;
    }
    licensor->bytes = aBytes;
    licensor->size = aSize;
    licensor->releaseContext = aContext;
    licensor->releaseCallBack = aCallBack;
    SLEnvironmentSetLicensorNoCopy(licensor, sizeof(SLLicensor), licensor, SLLicensorReleaseCallBack);
    licensor->groupSize = aGroup;
    licensor->groupCount = aGroup;
    licensor->rawSerialLength = aRawLength;
    return SLResultOK;
}

int SLLicensor4444InitializeWithBytesNoCopy(const void *aBytes, unsigned int aSize, void *aContext,
                                             SLReleaseCallBack aCallBack)
{
    return SLLicensorInitializeWithBytesNoCopy(aBytes, aSize, aContext, aCallBack, 4, 0x13);
}

int SLLicensor55554InitializeWithBytesNoCopy(const void *aBytes, unsigned int aSize, void *aContext,
                                             SLReleaseCallBack aCallBack)
{
    return SLLicensorInitializeWithBytesNoCopy(aBytes, aSize, aContext, aCallBack, 5, 0x1c);
}

static unsigned int SLLicensorGetTableString(const SLLicensorAnalysis *aAnalysis, unsigned int aCount,
                                             const unsigned char *aTable, const unsigned char *aKey,
                                             unsigned int aKeyLength, unsigned int aIndex, char *aBuffer,
                                             unsigned int aSize)
{
    unsigned int size = aAnalysis->sizeA;
    if (aIndex >= aCount || aCount * 8 >= size || aTable == NULL || size < 8) {
        return 0;
    }
    const unsigned char *entry = aTable + aIndex * 8;
    unsigned int length = BE32(entry), offset = BE32(entry + 4);
    const unsigned char *string = offset < size ? aAnalysis->baseA + offset : NULL;
    if (string == NULL || length == 0) {
        return 0;
    }
    length++;
    if (aBuffer == NULL) {
        return length;
    }
    if (length > aSize) {
        return 0;
    }
    SSDecryptBytesWithKey(string, length, (unsigned int)(string - aAnalysis->keyBase), aKey, aKeyLength,
                          (unsigned char *)aBuffer);
    return length;
}

unsigned int SLLicensorGetLicensePathAtIndex(const SLLicensorAnalysis *aAnalysis, const unsigned char *aKey,
                                             unsigned int aKeyLength, unsigned int aIndex, char *aBuffer,
                                             unsigned int aSize)
{
    return SLLicensorGetTableString(aAnalysis, aAnalysis->pathCount, aAnalysis->pathTable, aKey, aKeyLength,
                                    aIndex, aBuffer, aSize);
}

unsigned int SLLicensorGetLicenseTypeAtIndex(const SLLicensorAnalysis *aAnalysis, const unsigned char *aKey,
                                             unsigned int aKeyLength, unsigned int aIndex, char *aBuffer,
                                             unsigned int aSize)
{
    return SLLicensorGetTableString(aAnalysis, aAnalysis->typeCount, aAnalysis->typeTable, aKey, aKeyLength,
                                    aIndex, aBuffer, aSize);
}

int SLLicensorGetRestrictionAtIndex(const SLLicensorAnalysis *aAnalysis, const unsigned char *aKey,
                                    unsigned int aKeyLength, unsigned int aIndex, SLLicensorRestriction *aRestriction)
{
    if (aIndex >= aAnalysis->restrictionCount || aAnalysis->restrictionCount * 0x14 >= aAnalysis->sizeB ||
        aAnalysis->sizeB < 0x14) {
        return 0;
    }
    const unsigned char *entry = aAnalysis->restrictions + aIndex * 0x14;
    if (aRestriction == NULL) {
        return 0x14;
    }
    aRestriction->identifierLength = BE32(entry);
    aRestriction->identifier = SLBlobPointer(aAnalysis->baseB, BE32(entry + 4), aAnalysis->sizeB);
    aRestriction->serialCount = BE32(entry + 8);
    aRestriction->serialSize = BE32(entry + 12);
    aRestriction->serials = SLBlobPointer(aAnalysis->baseB, BE32(entry + 16), aAnalysis->sizeB);
    return 0x14;
}

#pragma mark - License types and serials

unsigned int SLLicenseTypeCodeToString(int aCode, char *aBuffer, unsigned int aSize)
{
    const char *string;
    switch (aCode) {
    case 0x2e537552: string = "LOCAL_MACHINE"; break;
    case 0x2e54726c: string = "LOCAL_MACHINE_TRIAL"; break;
    case 0x2e4e6574: string = "LIMITED_NETWORK"; break;
    default: return 0;
    }
    unsigned int length = (unsigned int)strlen(string) + 1;
    if (aBuffer == NULL || aSize == 0) {
        return length;
    }
    if (aSize >= length) {
        memcpy(aBuffer, string, length);
    }
    return length;
}

int SLLicenseTypeStringToCode(const char *aString)
{
    if (strcmp(aString, "LOCAL_MACHINE") == 0) {
        return 0x2e537552;
    }
    if (strcmp(aString, "LIMITED_NETWORK") == 0) {
        return 0x2e4e6574;
    }
    if (strcmp(aString, "LOCAL_MACHINE_TRIAL") == 0) {
        return 0x2e54726c;
    }
    return 0;
}

int SLLicenseIsSerialSame(const SLLicense *aLicense, const char *aSerial)
{
    unsigned int encodedLength = SLEncodeSerialString(aSerial, NULL, 0, NULL);
    if (encodedLength == 0) {
        return 0;
    }
    unsigned int registrationLength = aLicense->descriptor.registrationLength;
    char *buffer = SLAllocatorAllocate(NULL, encodedLength + registrationLength + 1);
    if (buffer == NULL) {
        return 0;
    }
    int same = 0;
    if (SLEncodeSerialString(aSerial, buffer, encodedLength, NULL) != 0 &&
        SLLicenseGetBytes(&aLicense->descriptor, aLicense->descriptor.registration, registrationLength + 1,
                          buffer + encodedLength) != 0) {
        same = strcmp(buffer, buffer + encodedLength) == 0;
    }
    SLAllocatorDeallocate(NULL, buffer);
    return same;
}

static int SLLicenseIsSerialPresentInBase(const SLLicenseDescriptor *aDescriptor, const char *aSerial,
                                          const struct SLBannedIdentifier *aItems, unsigned int aCount)
{
    if ((SLLicenseDescriptorBytesEncryptedFlag & aDescriptor->flags) == 0) {
        for (unsigned int i = 0; i < aCount; i++) {
            const char *identifier = (const char *)aItems[i].data;
            int result = (aItems[i].flags & 0x80) == 0 ? strcmp(aSerial, identifier)
                                                        : SLLicenseCompareIdentifiers(aSerial, identifier);
            if (result == 0) {
                return 7;
            }
        }
        return 0;
    }
    char *buffer = NULL;
    unsigned int capacity = 0;
    int status = 0;
    for (unsigned int i = 0; i < aCount && status == 0; i++) {
        if (capacity < aItems[i].length + 1) {
            if (buffer != NULL) {
                SLAllocatorDeallocate(NULL, buffer);
            }
            capacity = aItems[i].length + 1;
            buffer = SLAllocatorAllocate(NULL, capacity);
            if (buffer == NULL) {
                return 1;
            }
        }
        if (SLLicenseGetBytes(aDescriptor, aItems[i].data, aItems[i].length + 1, buffer) == 0) {
            status = 1;
            break;
        }
        int result = (aItems[i].flags & 0x80) == 0 ? strcmp(aSerial, buffer)
                                                    : SLLicenseCompareIdentifiers(aSerial, buffer);
        if (result == 0) {
            status = 7;
        }
    }
    if (buffer != NULL) {
        SLAllocatorDeallocate(NULL, buffer);
    }
    return status;
}

int SLLicenseIsSerialBanned(const SLLicense *aLicense, const char *aSerial)
{
    if (aLicense == NULL) {
        return 1;
    }
    const SLLicenseDescriptor *descriptor = &aLicense->descriptor;
    if (descriptor->bannedLength == 0 || descriptor->banned == NULL) {
        return 0;
    }
    unsigned int count = 0;
    int result = SLLicenseGetBannedIdentifiers(descriptor, 2, NULL, &count, NULL);
    if (result != 0) {
        return result;
    }
    if (count == 0) {
        return 0;
    }
    struct SLBannedIdentifier *items = SLAllocatorAllocate(NULL, count * sizeof(*items));
    if (items == NULL) {
        return 1;
    }
    result = SLLicenseGetBannedIdentifiers(descriptor, 2, items, &count, NULL);
    if (result == 0) {
        result = SLLicenseIsSerialPresentInBase(descriptor, aSerial, items, count);
    }
    SLAllocatorDeallocate(NULL, items);
    return result;
}

void SLLicenseMakeIdentifier(const char *aSerial, char *aIdentifier)
{
    char *target = aIdentifier != NULL ? aIdentifier : (char *)aSerial;
    for (; *aSerial != '\0'; aSerial++, target++) {
        // The serial alphabet (no 0, 1, I or O) is numbered 0 to 31 and written as a to z followed by 0 to 5.
        signed char offset = (signed char)(*aSerial - 0x32);
        signed char high = (signed char)((unsigned short)(offset * 0x10093) >> 8);
        unsigned char index = (unsigned char)((offset + ((offset >> 7) - offset / 0x1d)) -
                                              (signed char)((short)(offset * 0x100b3) >> 0xc) + (high >> 3) * -7 +
                                              (high >> 4) * 7);
        *target = (char)(index + 0x61 + (index / 0x1a) * -0x4b);
    }
    *target = '\0';
}

int SLLicenseUpdateOtherData(const SLLicense *aLicense, const char *aSerial, unsigned char *aBuffer,
                             unsigned int *aSize)
{
    const SLLicenseDescriptor *descriptor = &aLicense->descriptor;
    unsigned int flag = descriptor->codeInfo != 0 ? 0x80 : 0;
    unsigned int existing = descriptor->bannedLength;
    unsigned int identifierLength = descriptor->identifierLength;
    if (existing == 0 || descriptor->banned == NULL) {
        unsigned int needed = identifierLength + 0xd;
        if (aBuffer == NULL) {
            *aSize = needed;
            return 0;
        }
        if (*aSize < needed ||
            SLLicenseGetBytes(descriptor, descriptor->identifier, identifierLength + 1, aBuffer + 12) == 0) {
            return 1;
        }
        if (SLLicenseCompareIdentifiers(aSerial, (const char *)aBuffer + 12) == 0) {
            return 10;
        }
        SLPutBE32(aBuffer, 1);
        SLPutBE32(aBuffer + 4, flag << 24);
        SLPutBE32(aBuffer + 8, identifierLength);
        *aSize = needed;
        return 0;
    }
    unsigned int needed = existing + 9 + identifierLength;
    if (aBuffer == NULL) {
        *aSize = needed;
        return 0;
    }
    if (*aSize < needed) {
        return 1;
    }
    unsigned char *entry = aBuffer + existing;
    if (SLLicenseGetBytes(descriptor, descriptor->identifier, identifierLength + 1, entry + 8) == 0) {
        return 1;
    }
    if (SLLicenseCompareIdentifiers(aSerial, (const char *)entry + 8) == 0) {
        return 10;
    }
    if (SLLicenseGetBytes(descriptor, descriptor->banned, existing, aBuffer) == 0) {
        return 1;
    }
    SLPutBE32(aBuffer, BE32(aBuffer) + 1);
    SLPutBE32(entry, flag << 24);
    SLPutBE32(entry + 4, identifierLength);
    *aSize = needed;
    return 0;
}

int SLLicenseGetOldIdentifiers(const SLLicense *aLicense, unsigned int *aBuffer, unsigned int *aSize)
{
    if (aSize == NULL) {
        return 8;
    }
    if (aLicense == NULL) {
        aLicense = SLEnvironmentGetLicense();
        if (aLicense == NULL) {
            return 1;
        }
    }
    unsigned int count = 0;
    int stringsLength = 0;
    int result = SLLicenseGetBannedIdentifiers(&aLicense->descriptor, 0, NULL, &count, &stringsLength);
    if (result != 0) {
        return result;
    }
    if (count == 0) {
        *aSize = 0;
        return 0;
    }
    if (stringsLength == 0) {
        return 1;
    }
    // The result is a count followed by pointers to the strings, which follow the pointers.
    size_t needed = sizeof(void *) + count * sizeof(char *) + stringsLength;
    if (aBuffer == NULL) {
        *aSize = (unsigned int)needed;
        return 0;
    }
    if (needed > *aSize) {
        return 1;
    }
    struct SLBannedIdentifier *items = SLAllocatorAllocate(NULL, count * sizeof(*items));
    if (items == NULL) {
        return 1;
    }
    result = SLLicenseGetBannedIdentifiers(&aLicense->descriptor, 0, items, &count, NULL);
    if (result == 0) {
        size_t *countSlot = (size_t *)aBuffer;
        char **pointers = (char **)(countSlot + 1);
        char *string = (char *)(pointers + count);
        unsigned int i;
        for (i = 0; i < count; i++) {
            if (SLLicenseGetBytes(&aLicense->descriptor, items[i].data, items[i].length + 1, string) == 0) {
                break;
            }
            pointers[i] = string;
            string += items[i].length + 1;
        }
        if (i == count) {
            *countSlot = count;
            result = 0;
        } else {
            result = 1;
        }
    }
    SLAllocatorDeallocate(NULL, items);
    return result;
}

#pragma mark - License creation

int SLLicenseCreateWithBytesNoCopy(const SLAllocatorContext *aAllocator, const char *aKey, const char *aVersion,
                                   const char *aShortVersion, const char *aTrialSign,
                                   const SLLicenseCheckContext *aContext, const void *aBytes, unsigned int aSize,
                                   void *aReleaseContext, SLReleaseCallBack aReleaseCallBack, SLLicense **aLicense)
{
    SLLicense *license = SLAllocatorAllocate(aAllocator, sizeof(SLLicense));
    if (license == NULL) {
        return 1;
    }
    memset(license, 0, sizeof(*license));
    license->allocator = aAllocator;
    SLLicenseDescriptor *d = &license->descriptor;
    if (SLLicenseValidateLicense(aBytes, aSize, aKey, d) != 0) {
        SLAllocatorDeallocate(aAllocator, license);
        return 1;
    }
    d->flags |= SLLicenseDescriptorBytesEncryptedFlag;
    if (d->dates[0] > aContext->dates[0] || d->dates[1] > aContext->dates[1] || d->dates[2] > aContext->dates[2]) {
        SLAllocatorDeallocate(aAllocator, license);
        return 1;
    }

    unsigned int largest = d->typeLength > d->pathLength ? d->typeLength : d->pathLength;
    if (largest < d->field84) largest = d->field84;
    if (largest < d->registrationLength) largest = d->registrationLength;
    if (largest < d->field96) largest = d->field96;
    if (largest < d->versionLength) largest = d->versionLength;
    if (largest < d->shortVersionLength) largest = d->shortVersionLength;
    unsigned int encodedLength = (d->field84 * 8 + 5) / 6;
    char *buffer = SLAllocatorAllocate(NULL, largest + 2 + encodedLength);
    int result = 1;
    int type = 0;
    if (buffer != NULL &&
        SLLicenseGetBytes(d, d->field100, d->field96 + 1, buffer) != 0 && strcmp(buffer, aKey) == 0 &&
        (d->version2 == NULL ||
         (SLLicenseGetBytes(d, d->version2, d->versionLength + 1, buffer) != 0 && strcmp(buffer, aVersion) == 0)) &&
        (d->shortVersion == NULL ||
         (SLLicenseGetBytes(d, d->shortVersion, d->shortVersionLength + 1, buffer) != 0 &&
          strcmp(buffer, aShortVersion) == 0)) &&
        SLLicenseGetBytes(d, d->registration, d->registrationLength + 1, buffer) != 0 &&
        SLValidateEncodedSerialString(buffer, (short)d->registrationCRC) == 0 &&
        SLLicenseGetBytes(d, d->type, d->typeLength + 1, buffer) != 0 &&
        (type = SLLicenseTypeStringToCode(buffer)) != 0) {
        int proceed = 0;
        const unsigned char *pathSource = d->path;
        unsigned int pathLength = d->pathLength;
        unsigned int stringLength;
        if (d->codeInfo == 0) {
            if (aTrialSign != NULL && type == 0x2e54726c &&
                SLLicenseGetBytes(d, d->field88, d->field84 + 1, buffer) != 0 && strcmp(aTrialSign, buffer) == 0) {
                stringLength = d->field84;
                proceed = 1;
            }
        } else if (type != 0x2e54726c && d->codeLimit != 0 && (type != 0x2e537552 || d->codeLimit >= 2) &&
                   SLLicenseGetBytes(d, d->field88, d->field84 + 1, buffer) != 0 &&
                   buffer[d->field84] == '\0') {
            int count = 0;
            if (type != 0x2e4e6574 ||
                (SSDecomposeNetworkSignature(buffer, d->field84, &count) == 0 && d->codeLimit == (unsigned int)count)) {
                char *encoded = buffer + d->field84 + 1;
                if (SSEncodeBytes((const unsigned char *)buffer, (int)d->field84, encoded, encodedLength) == 0) {
                    buffer[encodedLength + d->field84 + 1] = '\0';
                    if (aContext->isBanned(aContext->context, encoded, d->codeInfo) != 0) {
                        SLAllocatorDeallocate(aAllocator, license);
                        SLAllocatorDeallocate(NULL, buffer);
                        return 7;
                    }
                    memmove(buffer, encoded, encodedLength + 1);
                    stringLength = encodedLength;
                    proceed = 1;
                }
            }
        }
        if (proceed &&
            SLLicenseGetBytes(d, pathSource, pathLength + 1, buffer + stringLength + 1) != 0 &&
            aContext->checkSettings(aContext->context, type, buffer, buffer + stringLength + 1) != 0) {
            license->bytes = (void *)aBytes;
            license->bytesSize = aSize;
            license->releaseContext = aReleaseContext;
            license->releaseCallBack = aReleaseCallBack;
            SLAllocatorDeallocate(NULL, buffer);
            if (aLicense != NULL) {
                *aLicense = license;
            } else {
                SLAllocatorDeallocate(aAllocator, license);
            }
            return 0;
        }
    }
    SLAllocatorDeallocate(aAllocator, license);
    if (buffer != NULL) {
        SLAllocatorDeallocate(NULL, buffer);
    }
    return result;
}

static unsigned char *SLLicenseAppendString(unsigned char *aTarget, const char *aString, unsigned int *aLength,
                                            const unsigned char **aPointer)
{
    size_t length = strlen(aString);
    strcpy((char *)aTarget, aString);
    *aLength = (unsigned int)length;
    *aPointer = aTarget;
    return aTarget + length + 1;
}

int SLLicenseCreateWithSerial(const SLAllocatorContext *aAllocator, const char *aSerial, const char *aSerialString,
                              unsigned int aCodeInfo, unsigned int aCodeLimit, const char *aKey,
                              const char *aVersion, const char *aShortVersion,
                              const SLLicenseCreationContext *aContext, SLLicense **aLicense)
{
    size_t serialLength = strlen(aSerial);
    unsigned int encodedSize;
    if (serialLength == 0 || (encodedSize = SLEncodeSerialString(aSerial, NULL, 0, NULL)) == 0 ||
        aContext->pathLength == 0 || aContext->typeLength == 0) {
        return 1;
    }
    SLLicense *current = SLEnvironmentGetLicense();
    unsigned int otherLength = 0;
    if (current != NULL) {
        int status = SLLicenseUpdateOtherData(current, aSerial, NULL, &otherLength);
        if (status != 0) {
            return status;
        }
    }
    size_t keyLength = strlen(aKey), serialStringLength = strlen(aSerialString);
    size_t shortLength = aShortVersion != NULL ? strlen(aShortVersion) : 0;
    size_t versionLength = aVersion != NULL ? strlen(aVersion) : 0;
    size_t total = keyLength + 3 + serialLength + encodedSize + aContext->typeLength + aContext->pathLength +
                   serialStringLength + aContext->userDataLength + aContext->serialUserDataLength + otherLength +
                   (aShortVersion != NULL ? shortLength + 1 : 0) + (aVersion != NULL ? versionLength + 1 : 0) + 8;
    SLLicense *license = SLAllocatorAllocate(aAllocator, sizeof(SLLicense) + total);
    if (license == NULL) {
        return 1;
    }
    memset(license, 0, sizeof(*license));
    unsigned char *base = (unsigned char *)(license + 1);
    SLLicenseDescriptor d;
    memset(&d, 0, sizeof(d));
    d.creationDate = SLLicenseGetSystemTime();
    memcpy(d.dates, aContext->dates, sizeof(d.dates));
    d.codeInfo = aCodeInfo;
    d.codeLimit = aCodeLimit;
    d.base = base;

    unsigned short crc = 0;
    unsigned int encoded = SLEncodeSerialString(aSerial, (char *)base, encodedSize, &crc);
    int status = 1;
    if (encoded != 0) {
        d.registrationLength = encoded;
        d.registration = base;
        d.registrationCRC = crc;
        unsigned char *cursor = base + encoded + 1;
        d.identifierLength = (unsigned int)serialLength;
        d.identifier = cursor;
        if (aCodeInfo == 0) {
            strcpy((char *)cursor, aSerial);
        } else {
            SLLicenseMakeIdentifier(aSerial, (char *)cursor);
        }
        cursor += serialLength + 1;
        unsigned int length = aContext->getType(aContext->context, (char *)cursor, aContext->typeLength);
        if (length == aContext->typeLength) {
            d.type = cursor;
            d.typeLength = length - 1;
            cursor += length;
            length = aContext->getPath(aContext->context, (char *)cursor, aContext->pathLength);
            if (length == aContext->pathLength) {
                d.path = cursor;
                d.pathLength = length - 1;
                cursor += length;
                cursor = SLLicenseAppendString(cursor, aSerialString, &d.field84, &d.field88);
                cursor = SLLicenseAppendString(cursor, aKey, &d.field96, &d.field100);
                if (aShortVersion != NULL) {
                    cursor = SLLicenseAppendString(cursor, aShortVersion, &d.shortVersionLength, &d.shortVersion);
                }
                if (aVersion != NULL) {
                    cursor = SLLicenseAppendString(cursor, aVersion, &d.versionLength, &d.version2);
                }
                int ok = 1;
                if (aContext->userDataLength != 0 && aContext->getUserData != NULL) {
                    ok = aContext->getUserData(aContext->context, cursor, aContext->userDataLength) ==
                         aContext->userDataLength;
                    if (ok) {
                        d.userDataLength = aContext->userDataLength;
                        d.userData = cursor;
                        cursor += aContext->userDataLength;
                    }
                }
                if (ok && aContext->serialUserDataLength != 0 && aContext->getSerialUserData != NULL) {
                    ok = aContext->getSerialUserData(aContext->context, cursor, aContext->serialUserDataLength) ==
                         aContext->serialUserDataLength;
                    if (ok) {
                        d.serialUserDataLength = aContext->serialUserDataLength;
                        d.serialUserData = cursor;
                        cursor += aContext->serialUserDataLength;
                    }
                }
                if (ok) {
                    status = 0;
                    if (otherLength != 0) {
                        status = SLLicenseUpdateOtherData(current, aSerial, cursor, &otherLength);
                        if (status == 0) {
                            d.bannedLength = otherLength;
                            d.banned = cursor;
                            cursor += otherLength;
                        }
                    }
                    if (status == 0) {
                        d.contentSize = (unsigned int)(cursor - base);
                        license->allocator = aAllocator;
                        license->descriptor = d;
                        license->bytes = base;
                        license->bytesSize = d.contentSize;
                        *aLicense = license;
                        return 0;
                    }
                }
            }
        }
    }
    SLAllocatorDeallocate(aAllocator, license);
    *aLicense = NULL;
    return status;
}

#pragma mark - License storage

#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <sys/stat.h>

#define SLStoragePrefixLocalApplicationSupport "$(LOCAL_APP_SUPPORT)"
#define SLStoragePrefixApplicationInstallPath "$(APP_INSTALL_PATH)"

// The path of a license file; the prefix of the stored path stands for a folder that depends on the machine.
static char *SLLicenseStorageCreatePath(const char *aPath, const char *aInstallPath)
{
    const char *prefixes[2] = { SLStoragePrefixLocalApplicationSupport, SLStoragePrefixApplicationInstallPath };
    size_t length = strlen(aPath);
    for (int i = 0; i < 2; i++) {
        size_t prefixLength = strlen(prefixes[i]);
        if (prefixLength > length || strncmp(aPath, prefixes[i], prefixLength) != 0) {
            continue;
        }
        const char *folder = i == 0 ? "/Library/Application Support" : aInstallPath;
        if (folder == NULL) {
            return NULL;
        }
        const char *rest = aPath + prefixLength;
        if (*rest == '/') {
            rest++;
        }
        size_t size = strlen(folder) + strlen(rest) + 2;
        char *result = malloc(size);
        if (result != NULL) {
            snprintf(result, size, "%s/%s", folder, rest);
        }
        return result;
    }
    return strdup(aPath);
}

void *SLLicenseStorageCopyBytes(const char *aPath, const char *aInstallPath, size_t *aSize)
{
    char *path = SLLicenseStorageCreatePath(aPath, aInstallPath);
    if (path == NULL) {
        return NULL;
    }
    void *bytes = NULL;
    int file = open(path, O_RDONLY);
    free(path);
    if (file >= 0) {
        struct stat info;
        if (fstat(file, &info) == 0) {
            off_t size = lseek(file, 0, SEEK_END);
            if (size > 0 && lseek(file, 0, SEEK_SET) == 0) {
                bytes = SLAllocatorAllocate(NULL, (size_t)size);
                if (bytes != NULL) {
                    if (read(file, bytes, (size_t)size) == size) {
                        if (aSize != NULL) {
                            *aSize = (size_t)size;
                        }
                    } else {
                        SLAllocatorDeallocate(NULL, bytes);
                        bytes = NULL;
                    }
                }
            }
        }
        close(file);
    }
    return bytes;
}

static int SLLicenseStorageRestorePath(const char *aPath)
{
    struct stat info;
    if (stat(aPath, &info) == 0) {
        return 0;
    }
    if (errno == EACCES) {
        return 9;
    }
    char *parent = strdup(aPath);
    if (parent == NULL) {
        return 1;
    }
    char *slash = strrchr(parent, '/');
    if (slash == NULL || slash == parent) {
        free(parent);
        return 1;
    }
    *slash = '\0';
    int result = SLLicenseStorageRestorePath(parent);
    free(parent);
    if (result != 0) {
        return result;
    }
    if (mkdir(aPath, 0775) != 0) {
        if (errno == EACCES) {
            return 9;
        }
        if (errno != EEXIST) {
            return 1;
        }
    }
    return chmod(aPath, 0775) == 0 ? 0 : 9;
}

static int SLLicenseStorageSaveLicenseAtPath(const void *aBytes, size_t aSize, const char *aPath)
{
    FILE *file = fopen(aPath, "wb");
    if (file == NULL) {
        if (errno == EACCES) {
            return 9;
        }
        struct stat info;
        if (stat(aPath, &info) == 0 || errno == EACCES) {
            return 9;
        }
        char *parent = strdup(aPath);
        if (parent == NULL) {
            return 1;
        }
        char *slash = strrchr(parent, '/');
        if (slash != NULL) {
            *slash = '\0';
        }
        int result = SLLicenseStorageRestorePath(parent);
        free(parent);
        if (result != 0) {
            return result;
        }
        file = fopen(aPath, "wb");
        if (file == NULL) {
            return errno == EACCES ? 9 : 1;
        }
    }
    size_t written = fwrite(aBytes, 1, aSize, file);
    fclose(file);
    if (written != aSize) {
        return 1;
    }
    if (chmod(aPath, 0775) != 0) {
        return errno == EACCES || errno == EPERM ? 9 : 1;
    }
    return 0;
}

int SLLicenseStorageSaveData(const char *aPath, const char *aInstallPath, const void *aBytes, size_t aSize)
{
    char *path = SLLicenseStorageCreatePath(aPath, aInstallPath);
    if (path == NULL) {
        return 1;
    }
    int result = SLLicenseStorageSaveLicenseAtPath(aBytes, aSize, path);
    free(path);
    return result;
}

int SLLicenseStorageCleanup(const char *aPath, const char *aInstallPath)
{
    char *path = SLLicenseStorageCreatePath(aPath, aInstallPath);
    if (path == NULL) {
        return 1;
    }
    int result = 0;
    if (unlink(path) != 0 && errno != ENOENT && errno != ENOTDIR) {
        result = errno == EACCES ? 9 : 1;
    }
    free(path);
    return result;
}

#define SLStorageHeaderKey CFSTR("SLUtilityLicenseDataHeader")
#define SLStorageDataKey CFSTR("SLUtilityLicenseData")
#define SLStorageMagic 0x534c4c64

// A stored license is a property list with a 12 byte header (magic, revision, size) and the license bytes.
static CFDataRef SLLicenseStorageCreateDataItem(unsigned int aRevision, const void *aBytes, unsigned int aSize)
{
    unsigned char header[12];
    SLPutBE32(header, SLStorageMagic);
    SLPutBE32(header + 4, aRevision);
    SLPutBE32(header + 8, aSize);
    CFDataRef headerData = CFDataCreateWithBytesNoCopy(NULL, header, 12, kCFAllocatorNull);
    if (headerData == NULL) {
        return NULL;
    }
    CFDataRef bytesData = CFDataCreateWithBytesNoCopy(NULL, aBytes, aSize, kCFAllocatorNull);
    CFDataRef result = NULL;
    if (bytesData != NULL) {
        const void *keys[2] = { SLStorageHeaderKey, SLStorageDataKey };
        const void *values[2] = { headerData, bytesData };
        CFDictionaryRef dictionary = CFDictionaryCreate(NULL, keys, values, 2, &kCFTypeDictionaryKeyCallBacks,
                                                        &kCFTypeDictionaryValueCallBacks);
        CFRelease(bytesData);
        if (dictionary != NULL) {
            SSUtilityCreateDataWithPropertyList(NULL, dictionary, &result);
            CFRelease(dictionary);
        }
    }
    CFRelease(headerData);
    return result;
}

static int SLLicenseStorageValidateDataHeader(CFTypeRef aData, unsigned int *aRevision, CFDataRef *aBytes)
{
    if (CFGetTypeID(aData) != CFDataGetTypeID()) {
        return 1;
    }
    CFPropertyListRef list = SSUtilityCreatePropertyListWithBytes(NULL, CFDataGetBytePtr(aData), CFDataGetLength(aData));
    if (list == NULL) {
        return 1;
    }
    int result = 1;
    if (CFGetTypeID(list) == CFDictionaryGetTypeID()) {
        CFTypeRef header = CFDictionaryGetValue(list, SLStorageHeaderKey);
        if (header != NULL && CFGetTypeID(header) == CFDataGetTypeID() && CFDataGetLength(header) == 12) {
            const unsigned char *bytes = CFDataGetBytePtr(header);
            CFTypeRef data = CFDictionaryGetValue(list, SLStorageDataKey);
            if (BE32(bytes) == SLStorageMagic && data != NULL && CFGetTypeID(data) == CFDataGetTypeID() &&
                BE32(bytes + 8) == (unsigned int)CFDataGetLength(data)) {
                if (aRevision != NULL) {
                    *aRevision = BE32(bytes + 4);
                }
                if (aBytes != NULL) {
                    *aBytes = CFRetain(data);
                }
                result = 0;
            }
        }
    }
    CFRelease(list);
    return result;
}

static CFDictionaryRef SLLicenseStorageCopyExternalDomain(CFStringRef aDomain, CFStringRef aKey)
{
    CFArrayRef keys = CFArrayCreate(NULL, (const void **)&aKey, 1, &kCFTypeArrayCallBacks);
    if (keys == NULL) {
        return NULL;
    }
    CFPreferencesSynchronize(aDomain, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    CFDictionaryRef values = CFPreferencesCopyMultiple(keys, aDomain, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    CFRelease(keys);
    return values;
}

static CFStringRef SLLicenseStorageCreateItemKey(const char *aVersion, const char *aShortVersion, const char *aName)
{
    return CFStringCreateWithFormat(NULL, NULL, CFSTR("%s-%s-%s"), aVersion != NULL ? aVersion : "SLGeneric",
                                    aShortVersion != NULL ? aShortVersion : "SLGeneric", aName);
}

void *SLLicenseStorageCopyExternal(const char *aDomain, unsigned int aRevision, const char *aName,
                                   const char *aVersion, const char *aShortVersion, size_t *aSize)
{
    void *result = NULL;
    CFStringRef domain = CFStringCreateWithCStringNoCopy(NULL, aDomain, kCFStringEncodingUTF8, kCFAllocatorNull);
    if (domain == NULL) {
        return NULL;
    }
    CFStringRef revision = CFStringCreateWithFormat(NULL, NULL, CFSTR("%u"), aRevision);
    if (revision != NULL) {
        CFDictionaryRef values = SLLicenseStorageCopyExternalDomain(domain, revision);
        if (values != NULL) {
            CFTypeRef item = CFDictionaryGetValue(values, revision);
            if (item != NULL && CFGetTypeID(item) == CFDictionaryGetTypeID()) {
                CFStringRef key = SLLicenseStorageCreateItemKey(aVersion, aShortVersion, aName);
                if (key != NULL) {
                    CFTypeRef stored = CFDictionaryGetValue(item, key);
                    CFRelease(key);
                    unsigned int storedRevision = 0;
                    CFDataRef bytes = NULL;
                    if (stored != NULL && SLLicenseStorageValidateDataHeader(stored, &storedRevision, &bytes) == 0) {
                        if (storedRevision == aRevision) {
                            size_t length = (size_t)CFDataGetLength(bytes);
                            result = SLAllocatorAllocate(NULL, length);
                            if (result != NULL) {
                                memcpy(result, CFDataGetBytePtr(bytes), length);
                                if (aSize != NULL) {
                                    *aSize = length;
                                }
                            }
                        }
                        CFRelease(bytes);
                    }
                }
            }
            CFRelease(values);
        }
        CFRelease(revision);
    }
    CFRelease(domain);
    return result;
}

int SLLicenseStorageUpdateExternal(const char *aDomain, unsigned int aRevision, const char *aName,
                                   const char *aVersion, const char *aShortVersion, const void *aBytes,
                                   size_t aSize)
{
    int failed = 1;
    CFStringRef domain = CFStringCreateWithCStringNoCopy(NULL, aDomain, kCFStringEncodingUTF8, kCFAllocatorNull);
    CFStringRef revision = CFStringCreateWithFormat(NULL, NULL, CFSTR("%u"), aRevision);
    if (domain != NULL && revision != NULL) {
        CFDictionaryRef values = SLLicenseStorageCopyExternalDomain(domain, revision);
        if (values != NULL) {
            int remove = aSize == 0;
            CFMutableDictionaryRef item = NULL;
            CFTypeRef existing = CFDictionaryGetValue(values, revision);
            if (existing == NULL) {
                if (!remove) {
                    item = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks,
                                                     &kCFTypeDictionaryValueCallBacks);
                }
            } else if (CFGetTypeID(existing) == CFDictionaryGetTypeID()) {
                item = CFDictionaryCreateMutableCopy(NULL, 0, existing);
            } else if (remove) {
                item = NULL;
            } else {
                item = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks,
                                                 &kCFTypeDictionaryValueCallBacks);
            }
            if (item != NULL) {
                CFStringRef key = SLLicenseStorageCreateItemKey(aVersion, aShortVersion, aName);
                if (key != NULL) {
                    unsigned int storedRevision = 0;
                    CFTypeRef stored = CFDictionaryGetValue(item, key);
                    // Only an older revision of the same item is replaced.
                    if (stored == NULL || SLLicenseStorageValidateDataHeader(stored, &storedRevision, NULL) != 0 ||
                        storedRevision <= aRevision) {
                        if (remove) {
                            CFDictionaryRemoveValue(item, key);
                            failed = 0;
                        } else {
                            CFDataRef data = SLLicenseStorageCreateDataItem(aRevision, aBytes, (unsigned int)aSize);
                            if (data != NULL) {
                                CFDictionarySetValue(item, key, data);
                                CFRelease(data);
                                failed = 0;
                            }
                        }
                    }
                    CFRelease(key);
                }
                if (!failed) {
                    const void *keys[1] = { revision };
                    const void *entries[1] = { item };
                    CFDictionaryRef update = CFDictionaryCreate(NULL, keys, entries, 1, &kCFTypeDictionaryKeyCallBacks,
                                                                &kCFTypeDictionaryValueCallBacks);
                    if (update != NULL) {
                        CFPreferencesSetMultiple(update, NULL, domain, kCFPreferencesAnyUser,
                                                 kCFPreferencesCurrentHost);
                        failed = !CFPreferencesSynchronize(domain, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
                        CFRelease(update);
                    }
                }
                CFRelease(item);
            } else {
                failed = !remove;
            }
            CFRelease(values);
        }
    }
    if (revision != NULL) {
        CFRelease(revision);
    }
    if (domain != NULL) {
        CFRelease(domain);
    }
    return failed;
}

int SLLicenseStorageGetEnvironmentRepresentationForLicensor(const SLLicensorAnalysis *aAnalysis,
                                                            const char *aSecret, unsigned int aRevision,
                                                            const char *aKey, unsigned int aKeyLength,
                                                            const char *aName, const char *aCurrentPath,
                                                            unsigned char *aBuffer, unsigned int *aSize)
{
    if (aSize == NULL) {
        return 8;
    }
    size_t secretLength = strlen(aSecret);
    unsigned int total = (unsigned int)secretLength + 0xd;
    for (unsigned int i = 0; i < aAnalysis->pathCount; i++) {
        total += SLLicensorGetLicensePathAtIndex(aAnalysis, (const unsigned char *)aKey, aKeyLength, i, NULL, 0);
    }
    if (aBuffer != NULL) {
        if (*aSize < total) {
            return 1;
        }
        unsigned char *content = aBuffer + 12;
        strcpy((char *)content, aSecret);
        unsigned int index = 0xffffffff;
        unsigned int used = (unsigned int)secretLength + 1;
        char *cursor = (char *)content + used;
        for (unsigned int i = 0; i < aAnalysis->pathCount; i++) {
            unsigned int length = SLLicensorGetLicensePathAtIndex(aAnalysis, (const unsigned char *)aKey, aKeyLength,
                                                                  i, cursor, total - used);
            if (length == 0) {
                return 1;
            }
            if (index == 0xffffffff && aCurrentPath != NULL && strcmp(cursor, aCurrentPath) == 0) {
                index = i;
            }
            used += length;
            cursor += length;
        }
        SLPutBE32(aBuffer, aRevision);
        SLPutBE32(aBuffer + 4, aAnalysis->pathCount);
        SLPutBE32(aBuffer + 8, index);
        SSEncryptBytesWithKeyAndOffset(content, used, (const unsigned char *)aName, (unsigned int)strlen(aName), 0,
                                       NULL);
    }
    *aSize = total;
    return 0;
}

int SLLicenseStorageValidateEnvironmentRepresentation(const unsigned char *aBytes, unsigned int aSize,
                                                      const char *aKey, SLStorageEnvironment *aEnvironment,
                                                      unsigned int *aEnvironmentSize)
{
    if (aSize < 0xd) {
        return 8;
    }
    if (BE32(aBytes) != 6) {
        return 1;
    }
    unsigned int count = BE32(aBytes + 4);
    size_t keyLength = strlen(aKey);
    unsigned int needed = (unsigned int)(sizeof(SLStorageEnvironment) + count * sizeof(char *) + aSize - 12 + keyLength + 1);
    if (aEnvironment == NULL) {
        *aEnvironmentSize = needed;
        return 0;
    }
    if (needed > *aEnvironmentSize) {
        return 1;
    }
    char *strings = (char *)aEnvironment->paths + count * sizeof(char *);
    SSDecryptBytesWithKey(aBytes + 12, (int)(aSize - 12), 0, (const unsigned char *)aKey, (unsigned int)keyLength,
                          (unsigned char *)strings);
    if (strings[aSize - 12 - 1] != '\0' || strlen(strings) == 0) {
        return 1;
    }
    char *cursor = strings + strlen(strings) + 1;
    aEnvironment->secret = strings;
    for (unsigned int i = 0; i < count; i++) {
        size_t length = strlen(cursor);
        if (length == 0) {
            return 1;
        }
        aEnvironment->paths[i] = cursor;
        cursor += length + 1;
    }
    aEnvironment->key = cursor;
    memmove(cursor, aKey, keyLength + 1);
    aEnvironment->revision = 6;
    aEnvironment->count = count;
    aEnvironment->index = BE32(aBytes + 8);
    return 0;
}

#pragma mark - Licensor

#define SLLicensorHostDomain ".com.mackiev.licensor.host"

int SLLicensorGetCodeMapItemForKey(const SLLicensorAnalysis *aAnalysis, const char *aEncoded, const char *aKey,
                                   unsigned int aKeyLength, SLCodeMapItem *aItem)
{
    if (aAnalysis->codeMapCount == 0 || aAnalysis->codeMapTable == NULL) {
        return 0;
    }
    char *buffer = NULL;
    unsigned int capacity = 0;
    int found = 0;
    for (unsigned int i = 0; i < aAnalysis->codeMapCount; i++) {
        unsigned int size = aAnalysis->sizeA;
        const unsigned char *entry = aAnalysis->codeMapTable + i * 0x18;
        if (size < 0x18) {
            break;
        }
        unsigned int length = BE32(entry);
        const unsigned char *string = SLBlobPointer(aAnalysis->baseA, BE32(entry + 4), size);
        if (length == 0 || string == NULL) {
            found = 1;
            break;
        }
        length++;
        if (capacity < length) {
            if (buffer != NULL) {
                SLAllocatorDeallocate(NULL, buffer);
            }
            buffer = SLAllocatorAllocate(NULL, length);
            capacity = length;
        }
        SSDecryptBytesWithKey(string, length, (unsigned int)(string - aAnalysis->keyBase),
                              (const unsigned char *)aKey, aKeyLength, (unsigned char *)buffer);
        if (strcmp(buffer, aEncoded) == 0) {
            if (aItem != NULL) {
                aItem->type = BE32(entry + 8);
                aItem->index = BE32(entry + 12);
                aItem->length = BE32(entry + 16);
                aItem->data = SLBlobPointer(aAnalysis->baseA, BE32(entry + 20), size);
            }
            found = 1;
            break;
        }
    }
    if (buffer != NULL) {
        SLAllocatorDeallocate(NULL, buffer);
    }
    return found;
}

unsigned int SLLicensorGetSerialUserData(const SLLicensorAnalysis *aAnalysis, const char *aEncoded,
                                         unsigned int aValue, const char *aKey, unsigned int aKeyLength,
                                         const unsigned char **aData)
{
    size_t length = strlen(aEncoded);
    if (length == 0 || aAnalysis->countC * 16 >= aAnalysis->sizeC) {
        return 0;
    }
    char *buffer = SLAllocatorAllocate(NULL, length + 1);
    if (buffer == NULL) {
        return 0;
    }
    const unsigned char *items = NULL;
    unsigned int itemCount = 0;
    unsigned int i;
    int found = 0;
    for (i = 0; i < aAnalysis->countC; i++) {
        const unsigned char *entry = aAnalysis->tableC + i * 16;
        if (aAnalysis->sizeC < 0x10) {
            break;
        }
        const unsigned char *string = SLBlobPointer(aAnalysis->baseC, BE32(entry + 4), aAnalysis->sizeC);
        itemCount = BE32(entry + 8);
        items = SLBlobPointer(aAnalysis->baseC, BE32(entry + 12), aAnalysis->sizeC);
        if (length == BE32(entry) && string != NULL) {
            SSDecryptBytesWithKey(string, (int)length, (unsigned int)(string - aAnalysis->pointerC),
                                  (const unsigned char *)aKey, aKeyLength, (unsigned char *)buffer);
            // The compared text carries no terminator of its own.
            buffer[length] = '\0';
            if (strcmp(buffer, aEncoded) == 0) {
                found = 1;
                break;
            }
        }
    }
    SLAllocatorDeallocate(NULL, buffer);
    if (!found || items == NULL) {
        return 0;
    }
    for (unsigned int j = 0; j < itemCount; j++) {
        unsigned char item[12];
        SSDecryptBytesWithKey(items, 12, (unsigned int)(items - aAnalysis->pointerC), (const unsigned char *)aKey,
                              aKeyLength, item);
        if (aAnalysis->sizeC < 0xc) {
            return 0;
        }
        unsigned int value = BE32(item), itemLength = BE32(item + 4);
        const unsigned char *data = SLBlobPointer(aAnalysis->baseC, BE32(item + 8), aAnalysis->sizeC);
        items += 12;
        if (value == aValue) {
            if (aData != NULL) {
                *aData = data;
            }
            return itemLength;
        }
    }
    return 0;
}

int SLLicensorGetRawSerialString(unsigned int aLength, unsigned int aGroupSize, unsigned int aGroupCount,
                                 const char *aSerial, char *aBuffer, unsigned int aSize)
{
    if (aLength - aGroupCount + 2 > aSize) {
        return -1;
    }
    int result;
    unsigned int groups = 0;
    for (;;) {
        const char *dash = strchr(aSerial, '-');
        if (dash == NULL) {
            result = 0;
            break;
        }
        if ((unsigned int)(dash - aSerial) != aGroupSize) {
            result = -1;
            break;
        }
        strncpy(aBuffer, aSerial, aGroupCount);
        aBuffer += aGroupCount;
        groups++;
        aSerial += aGroupCount + 1;
    }
    *aBuffer = '\0';
    if (result == 0 && groups < aGroupCount) {
        strcpy(aBuffer, aSerial);
    }
    return result;
}

int SLLicensorMakeFullSerialString(unsigned int aLength, unsigned int aGroupSize, unsigned int aGroupCount,
                                   const char *aRaw, char *aBuffer, unsigned int aSize)
{
    if (aLength + 1 > aSize) {
        return -1;
    }
    for (unsigned int i = 0; i < aGroupCount - 1; i++) {
        strncpy(aBuffer, aRaw, aGroupSize);
        aBuffer += aGroupSize;
        aRaw += aGroupSize;
        *aBuffer++ = '-';
    }
    strcpy(aBuffer, aRaw);
    return 0;
}

unsigned int SLLicensorGetTrialSign(const SLLicensorAnalysis *aAnalysis, const char *aKey, unsigned int aKeyLength,
                                    char *aBuffer, unsigned int aSize)
{
    if (aAnalysis->defaultIndex == 0xffffffff || aAnalysis->pointer12 == NULL || aAnalysis->length11 == 0) {
        return 0;
    }
    unsigned int length = aAnalysis->length11 + 1;
    if (aBuffer == NULL) {
        return length;
    }
    if (length > aSize) {
        return 0;
    }
    SSDecryptBytesWithKey(aAnalysis->pointer12, (int)length, (unsigned int)(aAnalysis->pointer12 - aAnalysis->keyBase),
                          (const unsigned char *)aKey, aKeyLength, (unsigned char *)aBuffer);
    return length;
}

int SLLicensorIsRawSerialProbablyTrial(const char *aRaw, const char *aKey, const char *aPrefix)
{
    size_t keyLength = strlen(aKey), prefixLength = strlen(aPrefix), length = strlen(aRaw);
    if (keyLength + 5 + prefixLength > length) {
        return 1;
    }
    if (prefixLength != 0 && strncmp(aRaw, aPrefix, prefixLength) != 0) {
        return 1;
    }
    aRaw += prefixLength;
    if (strncmp(aRaw, aKey, keyLength) != 0) {
        return 1;
    }
    return strncmp(aRaw + keyLength, "TRIAL", 5) == 0 ? 0 : 1;
}

int SLLicensorMakeRawTrialSerial(unsigned int aLength, unsigned int aGroupSize, unsigned int aGroupCount,
                                 const char *aKey, const char *aPrefix, char *aBuffer, unsigned int aSize)
{
    unsigned int size = aLength - aGroupCount + 2;
    if (size > aSize) {
        return 1;
    }
    size_t keyLength = strlen(aKey), prefixLength = strlen(aPrefix);
    if (keyLength + 6 + prefixLength > size) {
        return 1;
    }
    strcpy(aBuffer, aPrefix);
    strcpy(aBuffer + prefixLength, aKey);
    aBuffer += keyLength + prefixLength;
    unsigned int remaining = size - (unsigned int)(keyLength + prefixLength) - 1;
    unsigned int filled = 0, left = remaining;
    while (filled != remaining) {
        filled += 5;
        if (left < 5) {
            strncpy(aBuffer, "TRIAL", left);
            aBuffer[left] = '\0';
            return 0;
        }
        memcpy(aBuffer, "TRIAL", 6);
        left -= 5;
        aBuffer += 5;
    }
    return 0;
}

int SLLicensorFillRawTrialSerial(SLLicenseeInfo *aInfo, unsigned int aLength, unsigned int aGroupSize,
                                 unsigned int aGroupCount)
{
    if (*aInfo->trialSign == '\0') {
        return 1;
    }
    if (*aInfo->trialSerial != '\0') {
        return 0;
    }
    return SLLicensorMakeRawTrialSerial(aLength, aGroupSize, aGroupCount, aInfo->key, aInfo->trialSign,
                                        aInfo->trialSerial, aLength - aGroupCount + 2) != 0;
}

int SLLicensorIsSerialBanned(const SLLicensorAnalysis *aAnalysis, const char *aKey, unsigned int aKeyLength,
                             const char *aEncoded, unsigned int aValue)
{
    if (aAnalysis->restrictionCount == 0 || aAnalysis->baseB == NULL) {
        return 0;
    }
    char *buffer = NULL;
    unsigned int capacity = 0;
    SLLicensorRestriction restriction;
    unsigned int i;
    int banned = 0, found = 0;
    for (i = 0; i < aAnalysis->restrictionCount; i++) {
        if (!SLLicensorGetRestrictionAtIndex(aAnalysis, (const unsigned char *)aKey, aKeyLength, i, &restriction) ||
            restriction.identifierLength == 0) {
            goto done;
        }
        unsigned int length = restriction.identifierLength + 1;
        if (capacity < length) {
            if (buffer != NULL) {
                SLAllocatorDeallocate(NULL, buffer);
            }
            buffer = SLAllocatorAllocate(NULL, length);
            capacity = length;
        }
        SSDecryptBytesWithKey(restriction.identifier, (int)length,
                              (unsigned int)(restriction.identifier - aAnalysis->keyBaseB),
                              (const unsigned char *)aKey, aKeyLength, (unsigned char *)buffer);
        if (strcmp(buffer, aEncoded) == 0) {
            found = 1;
            break;
        }
    }
    if (found && restriction.serialCount != 0 && restriction.serialSize == 4 && restriction.serials != NULL) {
        const unsigned char *serial = restriction.serials;
        for (unsigned int j = 0; j < restriction.serialCount; j++, serial += 4) {
            unsigned char value[4];
            SSDecryptBytesWithKey(serial, 4, (unsigned int)(serial - aAnalysis->keyBaseB), (const unsigned char *)aKey,
                                  aKeyLength, value);
            if (BE32(value) == aValue) {
                banned = 1;
                break;
            }
        }
    }
done:
    if (buffer != NULL) {
        SLAllocatorDeallocate(NULL, buffer);
    }
    return banned;
}

int SLLicensorCreateSerialInfoWithRawSerial(const SLAllocatorContext *aAllocator, const SLLicensorAnalysis *aAnalysis,
                                            const char *aKey, const char *aRaw, SLSerialInfo **aInfo)
{
    size_t rawLength = strlen(aRaw);
    if (rawLength == 0) {
        return 8;
    }
    size_t keyLength = strlen(aKey);
    unsigned int infoLength = 0;
    if (SSDecoderExtractUserInfo(NULL, (int)rawLength, (int)aAnalysis->magic, NULL, &infoLength, NULL) != 0 ||
        infoLength <= keyLength) {
        return 1;
    }
    unsigned int userLength = infoLength - (unsigned int)keyLength;
    unsigned int encodedLength = (userLength * 8 + 5) / 6;
    SLSerialInfo *info = SLAllocatorAllocate(aAllocator, sizeof(SLSerialInfo) + userLength * 2 + infoLength +
                                                             encodedLength + 8);
    if (info == NULL) {
        return 1;
    }
    memset(info, 0, sizeof(*info));
    char *data = (char *)(info + 1);
    unsigned int value = 0;
    int result = 1;
    if (SSDecoderExtractUserInfo(aRaw, (int)rawLength, (int)aAnalysis->magic, (unsigned char *)data, &infoLength,
                                 &value) == 0) {
        data[infoLength] = '\0';
        if (strncmp(data, aKey, keyLength) == 0) {
            char *user = data + keyLength;
            char *encoded = user + userLength + 1;
            if (SSEncodeBytes((const unsigned char *)user, (int)userLength, encoded, encodedLength) == 0) {
                char *end = encoded + encodedLength;
                *end = '\0';
                int count = -1;
                SLCodeMapItem item = { 0, 0, 0, NULL };
                int matched = SLLicensorGetCodeMapItemForKey(aAnalysis, encoded, aKey, (unsigned int)keyLength, &item);
                int resolved = matched;
                if (!matched) {
                    char *copy = end + 1;
                    memcpy(copy, user, userLength + 1);
                    if (SSDecomposeNetworkSignature(copy, userLength, &count) == 0 && count != 0 && count != -1 &&
                        SSEncodeBytes((const unsigned char *)copy, (int)userLength, encoded, encodedLength) == 0) {
                        *end = '\0';
                        resolved = SLLicensorGetCodeMapItemForKey(aAnalysis, encoded, aKey, (unsigned int)keyLength,
                                                                  &item) && item.type == 0x2e4e6574;
                    }
                }
                if (resolved && item.type != 0 && item.index < aAnalysis->pathCount) {
                    unsigned int typeIndex = 0;
                    char *typeString = NULL;
                    unsigned int typeCapacity = 0;
                    unsigned int length;
                    while (typeIndex < aAnalysis->typeCount &&
                           (length = SLLicensorGetLicenseTypeAtIndex(aAnalysis, (const unsigned char *)aKey,
                                                                     (unsigned int)keyLength, typeIndex, NULL, 0)) != 0) {
                        if (typeCapacity < length) {
                            if (typeString != NULL) {
                                SLAllocatorDeallocate(NULL, typeString);
                            }
                            typeString = SLAllocatorAllocate(NULL, length);
                            typeCapacity = length;
                            if (typeString == NULL) {
                                break;
                            }
                        }
                        if (SLLicensorGetLicenseTypeAtIndex(aAnalysis, (const unsigned char *)aKey,
                                                            (unsigned int)keyLength, typeIndex, typeString,
                                                            typeCapacity) == 0 ||
                            SLLicenseTypeStringToCode(typeString) == (int)item.type) {
                            break;
                        }
                        typeIndex++;
                    }
                    if (typeString != NULL) {
                        SLAllocatorDeallocate(NULL, typeString);
                    }
                    if (typeIndex != aAnalysis->typeCount) {
                        if (SLLicensorIsSerialBanned(aAnalysis, aKey, (unsigned int)keyLength, encoded, value)) {
                            result = 7;
                        } else if (aInfo != NULL) {
                            info->value = value;
                            info->typeCode = item.type;
                            info->pathIndex = item.index;
                            info->count = count == -1 ? 1 : (unsigned int)count;
                            info->codeLength = item.length;
                            info->code = item.data;
                            info->encoded = encoded;
                            memmove(data, user, userLength + 1);
                            *aInfo = info;
                            return 0;
                        } else {
                            result = 0;
                        }
                    }
                }
            }
        }
    }
    SLAllocatorDeallocate(aAllocator, info);
    return result;
}

int SLLicensorCreateSerialInfo(const SLAllocatorContext *aAllocator, const char *aSerial, unsigned int aLength,
                               unsigned int aGroupSize, unsigned int aGroupCount,
                               const SLLicensorAnalysis *aAnalysis, const char *aKey, const char *aTrialSerial,
                               char *aRawBuffer, unsigned int aRawSize, SLSerialInfo **aInfo)
{
    size_t length = strlen(aSerial);
    if (length != aLength ||
        SLLicensorGetRawSerialString((unsigned int)length, aGroupSize, aGroupCount, aSerial, aRawBuffer,
                                     aRawSize) != 0) {
        return 1;
    }
    SLLicense *current = SLEnvironmentGetLicense();
    if (current != NULL) {
        if (SLLicenseIsSerialSame(current, aRawBuffer)) {
            return 10;
        }
        if (SLLicenseIsSerialBanned(current, aRawBuffer) == 7) {
            return 7;
        }
    }
    if (aTrialSerial != NULL && *aTrialSerial != '\0' && strcmp(aTrialSerial, aRawBuffer) == 0) {
        if (aInfo != NULL) {
            unsigned int signLength = aAnalysis->length11 + 1;
            SLSerialInfo *info = SLAllocatorAllocate(aAllocator, sizeof(SLSerialInfo) + 1 + signLength);
            *aInfo = info;
            if (info != NULL) {
                memset(info, 0, sizeof(*info));
                info->typeCode = 0x2e54726c;
                info->pathIndex = aAnalysis->defaultIndex;
                info->count = 0xffffffff;
                char *sign = (char *)(info + 1) + 1;
                ((char *)(info + 1))[0] = '\0';
                info->encoded = sign;
                SLLicensorGetTrialSign(aAnalysis, aKey, (unsigned int)strlen(aKey), sign, signLength);
            }
        }
        return 0;
    }
    return SLLicensorCreateSerialInfoWithRawSerial(aAllocator, aAnalysis, aKey, aRawBuffer, aInfo);
}

#pragma mark - Environment

typedef struct SLLicensorCheckState {
    SLLicenseeInfo *info;
    const SLLicensorAnalysis *analysis;
    int external;
} SLLicensorCheckState;

static int SLLicensorLicenseValidationCheckForBanning(void *aContext, const char *aEncoded, unsigned int aValue)
{
    SLLicensorCheckState *state = aContext;
    if (aEncoded == NULL) {
        return 1;
    }
    return SLLicensorIsSerialBanned(state->analysis, state->info->key, (unsigned int)strlen(state->info->key),
                                    aEncoded, aValue);
}

static int SLLicensorLicenseValidationCheckSettings(void *aContext, int aType, const char *aEncoded,
                                                    const char *aPath)
{
    SLLicensorCheckState *state = aContext;
    if (aEncoded == NULL || aType == 0) {
        return 0;
    }
    SLLicenseeInfo *info = state->info;
    const SLLicensorAnalysis *analysis = state->analysis;
    unsigned int keyLength = (unsigned int)strlen(info->key);
    size_t pathLength = strlen(aPath);
    unsigned int fallback = 0xffffffff, index;
    int lookup = 1;
    if (aType == 0x2e537552 && state->external) {
        fallback = analysis->defaultIndex;
    } else if (aType == 0x2e54726c) {
        if (strcmp(aEncoded, info->trialSign) != 0) {
            return 0;
        }
        index = analysis->defaultIndex;
        lookup = 0;
    }
    if (lookup) {
        SLCodeMapItem item = { 0, 0, 0, NULL };
        if (!SLLicensorGetCodeMapItemForKey(analysis, aEncoded, info->key, keyLength, &item) ||
            (int)item.type != aType) {
            return 0;
        }
        index = item.index;
        if (fallback == index) {
            index = fallback;
            fallback = 0xffffffff;
        }
    } else {
        fallback = 0xffffffff;
    }
    if (index == 0xffffffff) {
        return 0;
    }
    unsigned int size = (unsigned int)pathLength + 1;
    char *buffer = SLAllocatorAllocate(NULL, size);
    if (buffer == NULL) {
        return 0;
    }
    int matches = SLLicensorGetLicensePathAtIndex(analysis, (const unsigned char *)info->key, keyLength, index, buffer,
                                                  size) == size;
    if (fallback != 0xffffffff && !matches) {
        matches = SLLicensorGetLicensePathAtIndex(analysis, (const unsigned char *)info->key, keyLength, fallback,
                                                  buffer, size) == size;
    }
    int result = matches && buffer[pathLength] == '\0' && strcmp(buffer, aPath) == 0;
    SLAllocatorDeallocate(NULL, buffer);
    return result;
}

static void SLLicensorLicenseReleaseCallBack(void *aContext, void *aObject, size_t aSize)
{
    SLLicenseDestroy(aObject);
}

static void SLLicensorMemoryReleaseBytesCallBack(void *aContext, void *aObject, size_t aSize)
{
    SLAllocatorDeallocate(NULL, aObject);
}

static int SLLicensorAnalyzeRealLicenseData(const void *aBytes, unsigned int aSize, void *aContext,
                                            SLReleaseCallBack aCallBack, SLLicenseeInfo *aInfo,
                                            const SLLicensorAnalysis *aAnalysis, int aExternal)
{
    if (aBytes == NULL || aSize == 0) {
        return 1;
    }
    SLLicensorCheckState state = { aInfo, aAnalysis, aExternal };
    SLLicenseCheckContext check;
    check.context = &state;
    check.dates[0] = aAnalysis->date;
    check.dates[1] = aAnalysis->dateB;
    check.dates[2] = aAnalysis->dateC;
    check.isBanned = SLLicensorLicenseValidationCheckForBanning;
    check.checkSettings = SLLicensorLicenseValidationCheckSettings;
    SLLicense *license = NULL;
    int result = SLLicenseCreateWithBytesNoCopy(NULL, aInfo->name, aInfo->version, aInfo->shortVersion,
                                                aInfo->trialSign, &check, aBytes, aSize, aContext, aCallBack,
                                                &license);
    if (license != NULL) {
        SLEnvironmentSetLicenseNoCopy(license, 0, NULL, SLLicensorLicenseReleaseCallBack);
    }
    return result;
}

int SLLicensorAttach(const char *aKey, const char *aName, const char *aShortVersion, const char *aVersion)
{
    if (aKey == NULL || aName == NULL) {
        return 8;
    }
    size_t keyLength = strlen(aKey), nameLength = strlen(aName);
    if (keyLength == 0 || nameLength == 0) {
        return 8;
    }
    SLLicensor *licensor = SLEnvironmentGetLicensor();
    if (licensor == NULL) {
        return 3;
    }
    if (SLEnvironmentGetLicenseeInfo() != NULL) {
        return 5;
    }
    size_t shortLength = aShortVersion != NULL ? strlen(aShortVersion) + 1 : 0;
    size_t versionLength = aVersion != NULL ? strlen(aVersion) + 1 : 0;
    unsigned int rawSize = licensor->rawSerialLength - licensor->groupCount + 2;
    unsigned int signLength = SLLicensorGetTrialSign(&licensor->analysis, aKey, (unsigned int)keyLength, NULL, 0);
    size_t total = sizeof(SLLicenseeInfo) + rawSize + 3 + shortLength + versionLength + nameLength + 1 + keyLength +
                   rawSize + signLength + 1 + (signLength != 0 ? rawSize : 0);
    SLLicenseeInfo *info = SLAllocatorAllocate(NULL, total);
    if (info == NULL) {
        return 1;
    }
    memset(info, 0, sizeof(*info));
    char *cursor = (char *)(info + 1);
    if (aShortVersion != NULL) {
        info->shortVersion = cursor;
        strcpy(cursor, aShortVersion);
        cursor += shortLength;
    }
    if (aVersion != NULL) {
        info->version = cursor;
        strcpy(cursor, aVersion);
        cursor += versionLength;
    }
    info->name = cursor;
    strcpy(cursor, aName);
    cursor += nameLength + 1;
    info->key = cursor;
    strcpy(cursor, aKey);
    cursor += keyLength + 1;
    info->rawSerial = cursor;
    cursor += rawSize;
    int result = 0;
    if (signLength != 0) {
        info->trialSign = cursor;
        cursor += rawSize;
        if (SLLicensorGetTrialSign(&licensor->analysis, aKey, (unsigned int)keyLength, info->trialSign, signLength) ==
            signLength) {
            info->trialSerial = info->trialSign + signLength;
            *info->trialSerial = '\0';
        } else {
            SLAllocatorDeallocate(NULL, info);
            info = NULL;
            result = 1;
        }
    }
    SLEnvironmentSetLicenseeInfoNoCopy(info, total, NULL, SLLicensorMemoryReleaseBytesCallBack);
    return result;
}

void SLLicensorDestroy(void)
{
    SLEnvironmentCleanUp();
}

int SLLicensorGetLicense(SLLicense **aLicense)
{
    if (aLicense == NULL) {
        return 8;
    }
    if (SLEnvironmentGetLicensor() == NULL) {
        return 3;
    }
    if (SLEnvironmentGetLicenseeInfo() == NULL) {
        return 4;
    }
    *aLicense = SLEnvironmentGetLicense();
    return 0;
}

int SLLicensorSetLicense(SLLicense *aLicense)
{
    if (aLicense == NULL) {
        return 8;
    }
    if (SLEnvironmentGetLicensor() == NULL) {
        return 3;
    }
    if (SLEnvironmentGetLicenseeInfo() == NULL) {
        return 4;
    }
    SLEnvironmentSetLicenseNoCopy(aLicense, 0, NULL, SLLicensorLicenseReleaseCallBack);
    return 0;
}

void SLLicensorDestroyLicense(SLLicense *aLicense)
{
    if (aLicense != NULL && aLicense != SLEnvironmentGetLicense()) {
        SLLicenseDestroy(aLicense);
    }
}

int SLLicensorGetLicenseInfo(const SLLicense *aLicense, void *aBytes, unsigned int *aSize)
{
    if (aSize == NULL) {
        return 8;
    }
    if (SLEnvironmentGetLicensor() == NULL) {
        return 3;
    }
    if (SLEnvironmentGetLicenseeInfo() == NULL) {
        return 4;
    }
    if (aLicense == NULL) {
        aLicense = SLEnvironmentGetLicense();
        if (aLicense == NULL) {
            return 1;
        }
    }
    return SLLicenseSerialize(aLicense, aBytes, aSize);
}

int SLLicensorLoadLicenseInfoFromBytesNoCopy(const void *aBytes, unsigned int aSize, void *aContext,
                                             SLReleaseCallBack aCallBack)
{
    if (aBytes == NULL || aSize == 0) {
        return 8;
    }
    SLLicensor *licensor = SLEnvironmentGetLicensor();
    if (licensor == NULL) {
        return 3;
    }
    SLLicenseeInfo *info = SLEnvironmentGetLicenseeInfo();
    if (info == NULL) {
        return 4;
    }
    return SLLicensorAnalyzeRealLicenseData(aBytes, aSize, aContext, aCallBack, info, &licensor->analysis, 0);
}

int SLLicensorLoadLicenseInfo(const char *aInstallPath)
{
    if (aInstallPath == NULL || strlen(aInstallPath) == 0) {
        return 8;
    }
    SLLicensor *licensor = SLEnvironmentGetLicensor();
    if (licensor == NULL) {
        return 3;
    }
    SLLicenseeInfo *info = SLEnvironmentGetLicenseeInfo();
    if (info == NULL) {
        return 4;
    }
    const SLLicensorAnalysis *analysis = &licensor->analysis;
    unsigned int keyLength = (unsigned int)strlen(info->key);
    size_t size = 0;
    void *bytes = NULL;
    char *path = NULL;
    unsigned int capacity = 0;
    for (unsigned int i = 0;; i++) {
        unsigned int length = SLLicensorGetLicensePathAtIndex(analysis, (const unsigned char *)info->key, keyLength, i,
                                                              NULL, 0);
        if (length == 0) {
            break;
        }
        if (capacity < length) {
            if (path != NULL) {
                SLAllocatorDeallocate(NULL, path);
            }
            path = SLAllocatorAllocate(NULL, length);
            capacity = length;
            if (path == NULL) {
                break;
            }
        }
        if (SLLicensorGetLicensePathAtIndex(analysis, (const unsigned char *)info->key, keyLength, i, path,
                                            length) != length) {
            break;
        }
        bytes = SLLicenseStorageCopyBytes(path, aInstallPath, &size);
        if (bytes != NULL) {
            break;
        }
    }
    if (path != NULL) {
        SLAllocatorDeallocate(NULL, path);
    }
    int result = 1;
    for (int external = 0;; external = 1) {
        if (bytes != NULL) {
            result = SLLicensorAnalyzeRealLicenseData(bytes, (unsigned int)size, NULL,
                                                      SLLicensorMemoryReleaseBytesCallBack, info, analysis, external);
            if (result == 0) {
                return 0;
            }
            SLAllocatorDeallocate(NULL, bytes);
        }
        if (external) {
            break;
        }
        bytes = SLLicenseStorageCopyExternal(SLLicensorHostDomain, 6, info->name, info->version, info->shortVersion,
                                             &size);
        if (bytes == NULL) {
            bytes = SLLicenseStorageCopyExternal(SLLicensorHostDomain, 4, info->name, info->version,
                                                 info->shortVersion, &size);
        }
    }
    return result;
}

int SLLicensorCleanupLicenses(const SLLicensorAnalysis *aAnalysis, const char *aInstallPath, const char *aKey,
                              unsigned int aKeyLength, const char *aCurrentPath)
{
    char *path = NULL;
    unsigned int capacity = 0;
    int result = 0;
    for (unsigned int i = 0; i < aAnalysis->pathCount; i++) {
        unsigned int length = SLLicensorGetLicensePathAtIndex(aAnalysis, (const unsigned char *)aKey, aKeyLength, i,
                                                              NULL, 0);
        if (length == 0) {
            break;
        }
        if (capacity < length) {
            if (path != NULL) {
                SLAllocatorDeallocate(NULL, path);
            }
            path = SLAllocatorAllocate(NULL, length);
            capacity = length;
            if (path == NULL) {
                return 1;
            }
        }
        if (SLLicensorGetLicensePathAtIndex(aAnalysis, (const unsigned char *)aKey, aKeyLength, i, path,
                                            capacity) != capacity) {
            break;
        }
        if (strcmp(aCurrentPath, path) != 0) {
            result = SLLicenseStorageCleanup(path, aInstallPath);
            if (result != 0) {
                break;
            }
        }
    }
    if (path != NULL) {
        SLAllocatorDeallocate(NULL, path);
    }
    return result;
}

int SLLicensorSaveLicenseInfo(const char *aInstallPath)
{
    if (aInstallPath == NULL) {
        return 8;
    }
    SLLicensor *licensor = SLEnvironmentGetLicensor();
    if (licensor == NULL) {
        return 3;
    }
    SLLicenseeInfo *info = SLEnvironmentGetLicenseeInfo();
    if (info == NULL) {
        return 4;
    }
    SLLicense *license = SLEnvironmentGetLicense();
    if (license == NULL) {
        return 1;
    }
    unsigned int serializedSize = 0;
    if (SLLicenseSerialize(license, NULL, &serializedSize) != 0 || serializedSize == 0) {
        return 1;
    }
    unsigned int pathSize = 0;
    if (SLLicenseGetStoragePath(NULL, &pathSize) != 0) {
        return 1;
    }
    unsigned char *buffer = SLAllocatorAllocate(NULL, serializedSize + pathSize);
    if (buffer == NULL) {
        return 1;
    }
    int result = 1;
    if (SLLicenseGetStoragePath((char *)buffer, &pathSize) == 0) {
        unsigned char *serialized = buffer + pathSize;
        if (SLLicenseSerialize(license, serialized, &serializedSize) == 0) {
            result = SLLicenseStorageSaveData((const char *)buffer, aInstallPath, serialized, serializedSize);
            if (result == 0) {
                result = SLLicensorCleanupLicenses(&licensor->analysis, aInstallPath, info->key,
                                                   (unsigned int)strlen(info->key), (const char *)buffer);
                if (result == 0) {
                    SLLicenseStorageUpdateExternal(SLLicensorHostDomain, 6, info->name, info->version,
                                                   info->shortVersion, serialized, serializedSize);
                }
            }
        }
    }
    SLAllocatorDeallocate(NULL, buffer);
    return result;
}

#pragma mark - License creation callbacks

typedef struct SLLicensorCreationState {
    SLLicensor *licensor;
    SLLicenseeInfo *info;
    SLSerialInfo *serial;
    unsigned int pathIndex;
    unsigned int licenseDataLength;
    const unsigned char *licenseData;
} SLLicensorCreationState;

static unsigned int SLLicensorCreationContextGetTypeString(void *aContext, char *aBuffer, unsigned int aSize)
{
    SLLicensorCreationState *state = aContext;
    return SLLicenseTypeCodeToString((int)state->serial->typeCode, aBuffer, aSize);
}

static unsigned int SLLicensorCreationContextGetPathString(void *aContext, char *aBuffer, unsigned int aSize)
{
    SLLicensorCreationState *state = aContext;
    return SLLicensorGetLicensePathAtIndex(&state->licensor->analysis, (const unsigned char *)state->info->key,
                                           (unsigned int)strlen(state->info->key), state->pathIndex, aBuffer, aSize);
}

static unsigned int SLLicensorCreationContextGetLicenseData(void *aContext, void *aBuffer, unsigned int aSize)
{
    SLLicensorCreationState *state = aContext;
    if (state->licenseData == NULL || state->licenseDataLength == 0 || aSize < state->licenseDataLength) {
        return 0;
    }
    SSDecryptBytesWithKey(state->licenseData, (int)state->licenseDataLength,
                          (unsigned int)(state->licenseData - state->licensor->analysis.pointerC),
                          (const unsigned char *)state->info->key, (unsigned int)strlen(state->info->key), aBuffer);
    return state->licenseDataLength;
}

static unsigned int SLLicensorCreationContextGetCodeData(void *aContext, void *aBuffer, unsigned int aSize)
{
    SLLicensorCreationState *state = aContext;
    const unsigned char *code = state->serial->code;
    unsigned int length = state->serial->codeLength;
    if (code == NULL || length == 0 || aSize < length) {
        return 0;
    }
    SSDecryptBytesWithKey(code, (int)length, (unsigned int)(code - state->licensor->analysis.keyBase),
                          (const unsigned char *)state->info->key, (unsigned int)strlen(state->info->key), aBuffer);
    return length;
}

int SLLicensorCreateLicenseForSerial(const SLAllocatorContext *aAllocator, const char *aSerial, SLLicense **aLicense)
{
    if (aSerial == NULL || *aSerial == '\0' || aLicense == NULL) {
        return 8;
    }
    SLLicensor *licensor = SLEnvironmentGetLicensor();
    if (licensor == NULL) {
        return 3;
    }
    SLLicenseeInfo *info = SLEnvironmentGetLicenseeInfo();
    if (info == NULL) {
        return 4;
    }
    SLSerialInfo *serial = NULL;
    SLLicensorCreationState state = { licensor, info, NULL, 0xffffffff, 0, NULL };
    int result = 0;
    if (info->trialSign == NULL || SLLicensorFillRawTrialSerial(info, licensor->rawSerialLength,
                                                                  licensor->groupSize, licensor->groupCount) == 0) {
        result = SLLicensorCreateSerialInfo(NULL, aSerial, licensor->rawSerialLength, licensor->groupSize,
                                            licensor->groupCount, &licensor->analysis, info->key, info->trialSerial,
                                            info->rawSerial, licensor->rawSerialLength - licensor->groupCount + 2,
                                            &serial);
        if (result == 0) {
            if (serial == NULL) {
                return 0;
            }
            const char *dataString;
            if (serial->typeCode == 0x2e54726c || serial->value == 0) {
                state.pathIndex = licensor->analysis.defaultIndex;
                dataString = info->trialSign;
            } else {
                state.pathIndex = serial->pathIndex;
                dataString = (const char *)(serial + 1);
            }
            unsigned int keyLength = (unsigned int)strlen(info->key);
            state.serial = serial;
            SLLicenseCreationContext creation;
            memset(&creation, 0, sizeof(creation));
            creation.context = &state;
            creation.dates[0] = licensor->analysis.date;
            creation.dates[1] = licensor->analysis.dateB;
            creation.dates[2] = licensor->analysis.dateC;
            creation.getType = SLLicensorCreationContextGetTypeString;
            creation.getPath = SLLicensorCreationContextGetPathString;
            creation.getUserData = SLLicensorCreationContextGetLicenseData;
            creation.getSerialUserData = SLLicensorCreationContextGetCodeData;
            creation.typeLength = SLLicenseTypeCodeToString((int)serial->typeCode, NULL, 0);
            creation.pathLength = SLLicensorGetLicensePathAtIndex(&licensor->analysis,
                                                                  (const unsigned char *)info->key, keyLength,
                                                                  state.pathIndex, NULL, 0);
            if (creation.typeLength == 0 || creation.pathLength == 0) {
                result = 1;
            } else {
                creation.userDataLength = SLLicensorGetSerialUserData(&licensor->analysis, serial->encoded,
                                                                      serial->value, info->key, keyLength,
                                                                      &state.licenseData);
                state.licenseDataLength = creation.userDataLength;
                creation.serialUserDataLength = serial->codeLength;
                result = SLLicenseCreateWithSerial(aAllocator, info->rawSerial, dataString, serial->value,
                                                   serial->count, info->name, info->version, info->shortVersion,
                                                   &creation, aLicense);
            }
        }
    } else {
        result = 1;
    }
    if (serial != NULL) {
        SLAllocatorDeallocate(NULL, serial);
    }
    return result;
}

int SLLicensorMakeLicenseForSerial(const char *aSerial, SLLicense **aLicense)
{
    return SLLicensorCreateLicenseForSerial(NULL, aSerial, aLicense);
}

int SLLicensorGetTrialSerial(char *aBuffer, unsigned int *aSize)
{
    if (aSize == NULL) {
        return 8;
    }
    SLLicensor *licensor = SLEnvironmentGetLicensor();
    if (licensor == NULL) {
        return 3;
    }
    SLLicenseeInfo *info = SLEnvironmentGetLicenseeInfo();
    if (info == NULL) {
        return 4;
    }
    unsigned int needed = licensor->rawSerialLength + 1;
    if (aBuffer == NULL) {
        *aSize = needed;
        return 0;
    }
    if (info->trialSign != NULL && needed <= *aSize) {
        int result = SLLicensorFillRawTrialSerial(info, licensor->rawSerialLength, licensor->groupSize,
                                                  licensor->groupCount);
        if (result != 0) {
            return result;
        }
        if (SLLicensorMakeFullSerialString(licensor->rawSerialLength, licensor->groupSize, licensor->groupCount,
                                           info->trialSerial, aBuffer, *aSize) == 0) {
            *aSize = needed;
            return 0;
        }
    }
    return 1;
}

int SLLicensorIsTrialLicenseAvailable(void)
{
    SLLicensor *licensor = SLEnvironmentGetLicensor();
    if (licensor == NULL) {
        return 3;
    }
    SLLicenseeInfo *info = SLEnvironmentGetLicenseeInfo();
    if (info == NULL) {
        return 4;
    }
    if (info->trialSign == NULL) {
        return 1;
    }
    int result = SLLicensorFillRawTrialSerial(info, licensor->rawSerialLength, licensor->groupSize,
                                              licensor->groupCount);
    if (result == 0) {
        SLLicense *license = SLEnvironmentGetLicense();
        if (license != NULL) {
            result = SLLicenseIsSerialBanned(license, info->trialSerial);
        }
    }
    return result;
}

int SLLicensorGetStorageEnvironment(unsigned char *aBuffer, unsigned int *aSize)
{
    if (aSize == NULL) {
        return 8;
    }
    SLLicensor *licensor = SLEnvironmentGetLicensor();
    if (licensor == NULL) {
        return 3;
    }
    SLLicenseeInfo *info = SLEnvironmentGetLicenseeInfo();
    if (info == NULL) {
        return 4;
    }
    SLLicense *license = SLEnvironmentGetLicense();
    const char *path = license != NULL ? (const char *)license->descriptor.path : NULL;
    return SLLicenseStorageGetEnvironmentRepresentationForLicensor(&licensor->analysis, SLLicensorHostDomain, 6,
                                                                   info->key, (unsigned int)strlen(info->key),
                                                                   info->name, path, aBuffer, aSize);
}

int SLLicensorGenerateIdentifierWithBytes(const void *aBytes, unsigned char aLength, char *aResult, unsigned int *aSize)
{
    if (aSize == NULL) {
        return 8;
    }
    SLLicensor *licensor = SLEnvironmentGetLicensor();
    if (licensor == NULL) {
        return 3;
    }
    SLLicenseeInfo *info = SLEnvironmentGetLicenseeInfo();
    if (info == NULL) {
        return 4;
    }
    unsigned int size = *aSize;
    int result = SSUDGenerateUniqueDataString(aBytes, aLength, info->key, info->name, NULL, NULL,
                                              (int)licensor->analysis.magic, aResult, &size);
    if (result == 0) {
        *aSize = size;
        return 0;
    }
    return result == 3 ? 8 : 1;
}
