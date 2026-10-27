#include <stdlib.h>
#include <string.h>
#include "SSLicense.h"

// The alphabet of the encoded text: 0-9, @, A-Z, _, a-z (value 0 to 63).
static char SSAlphabetCharacter(unsigned int aValue)
{
    if (aValue < 10) {
        return (char)('0' + aValue);
    }
    if (aValue < 37) {
        return (char)('@' + (aValue - 10));
    }
    if (aValue == 37) {
        return '_';
    }
    return (char)('a' + (aValue - 38));
}

static unsigned char SSAlphabetValue(char aCharacter)
{
    unsigned char c = (unsigned char)aCharacter;
    if (c >= '0' && c <= '9') {
        return c - '0';
    }
    if (c >= '@' && c <= 'Z') {
        return 10 + (c - '@');
    }
    if (c == '_') {
        return 37;
    }
    if (c >= 'a' && c <= 'z') {
        return 38 + (c - 'a');
    }
    return 0;
}

unsigned short SSCRC16Digest(const unsigned char *aBytes, unsigned short aLength)
{
    if (aBytes == NULL || aLength == 0 || aLength > 0xfff) {
        return 0;
    }
    unsigned short crc = 0xffff;
    for (unsigned short i = 0; i < aLength; i++) {
        crc ^= (unsigned short)aBytes[i] << 8;
        for (int bit = 0; bit < 8; bit++) {
            if ((short)crc < 0) {
                crc = (unsigned short)((crc << 1) ^ 0x1021);
            } else {
                crc = (unsigned short)(crc << 1);
            }
        }
    }
    return crc;
}

static unsigned int sCRC32Table[256];
static char sCRC32IsTableFilled;

void SSCRC32Init(struct SSCRC32Context *aContext)
{
    if (!sCRC32IsTableFilled) {
        for (unsigned int i = 0; i < 0x100; i++) {
            unsigned int value = i;
            for (int bit = 0; bit < 8; bit++) {
                value = (value & 1) == 0 ? value >> 1 : (value >> 1) ^ 0xedb88320;
            }
            sCRC32Table[i] = value;
        }
        sCRC32IsTableFilled = 1;
    }
    aContext->crc = 0xffffffff;
    aContext->length = 0;
    aContext->table = sCRC32Table;
}

unsigned int SSCRC32Update(struct SSCRC32Context *aContext, const unsigned char *aBytes, unsigned int aLength)
{
    unsigned int length = aContext->length;
    if (0xfffffff < length + aLength) {
        aLength = 0xfffffff - length;
    }
    for (unsigned int i = 0; i < aLength; i++) {
        aContext->crc = (aContext->crc >> 8) ^ aContext->table[(aBytes[i] ^ aContext->crc) & 0xff];
    }
    aContext->length = aLength + length;
    return aLength;
}

// Moves bit aSourceBit of aSource to bit aTargetBit of *aTarget.
void SSCopyBit(unsigned char aSource, unsigned char aSourceBit, unsigned char *aTarget, unsigned char aTargetBit)
{
    unsigned char shifted;
    if (aSourceBit < aTargetBit) {
        shifted = aSource << (aTargetBit - aSourceBit);
    } else if (aTargetBit < aSourceBit) {
        shifted = aSource >> (aSourceBit - aTargetBit);
    } else {
        shifted = aSource;
    }
    *aTarget |= (unsigned char)(1 << aTargetBit) & shifted;
}

int SSEncodeBytes(const unsigned char *aBytes, int aLength, char *aText, unsigned int aTextSize)
{
    if (aLength == 0) {
        return -1;
    }
    unsigned int textLength = ((unsigned int)aLength * 8 + 5) / 6;
    if (textLength > aTextSize) {
        return -1;
    }
    memset(aText, 0, textLength);
    for (unsigned int bit = 0; bit < (unsigned int)aLength * 8; bit++) {
        unsigned char sourceBit = ~(unsigned char)bit & 7;
        unsigned char targetBit = 5 - (unsigned char)(bit - (bit / 6) * 6);
        unsigned char *target = (unsigned char *)aText + bit / 6;
        SSCopyBit(aBytes[bit >> 3], sourceBit, target, targetBit);
    }
    for (unsigned int i = 0; i < textLength; i++) {
        aText[i] = SSAlphabetCharacter((unsigned char)aText[i] & 0x3f);
    }
    return 0;
}

int SSDecodeBytes(const char *aText, int aLength, unsigned char *aBytes, unsigned int aBytesSize)
{
    if (aLength == 0) {
        return -1;
    }
    unsigned int byteLength = ((unsigned int)aLength * 6 + 5) >> 3;
    if (byteLength > aBytesSize) {
        return -1;
    }
    memset(aBytes, 0, byteLength);
    for (unsigned int first = 0; first < (unsigned int)aLength * 6; first += 6) {
        unsigned int bit = first;
        for (int n = 0; n < 6; n++, bit++) {
            unsigned char value = SSAlphabetValue(aText[bit / 6]);
            unsigned char sourceBit = (unsigned char)(5 - (bit - (bit / 6) * 6));
            unsigned char targetBit = ~(unsigned char)bit & 7;
            SSCopyBit(value, sourceBit, &aBytes[bit >> 3], targetBit);
        }
    }
    return 0;
}

void SSEncryptBytesWithKeyAndOffset(const unsigned char *aBytes, int aLength, const unsigned char *aKey,
                                    unsigned int aKeyLength, unsigned int aOffset, unsigned char *aResult)
{
    if (aResult == NULL) {
        aResult = (unsigned char *)aBytes;
    }
    const unsigned char *end = aBytes + aLength;
    while (aBytes != end) {
        const unsigned char *key = aKey + aOffset;
        for (; aOffset < aKeyLength && end != aBytes; aOffset++) {
            *aResult++ = *aBytes++ ^ *key++;
        }
        const unsigned char *back = aKey + aOffset;
        for (; aOffset != 0 && end != aBytes; aOffset--) {
            back--;
            *aResult++ = *aBytes++ ^ *back;
        }
    }
}

void SSDecryptBytesWithKey(const unsigned char *aBytes, int aLength, unsigned int aOffset,
                           const unsigned char *aKey, unsigned int aKeyLength, unsigned char *aResult)
{
    unsigned int position = 0;
    if (aOffset != 0) {
        if (aResult == NULL) {
            aResult = (unsigned char *)aBytes;
        }
        position = aOffset % aKeyLength;
        if (((unsigned long long)aOffset / aKeyLength & 1) != 0) {
            position = aKeyLength - position;
            const unsigned char *back = aKey + position;
            const unsigned char *end = aBytes + aLength;
            for (; position != 0 && end != aBytes; position--) {
                back--;
                *aResult++ = *aBytes++ ^ *back;
                aLength--;
            }
        }
    }
    if (aResult == NULL) {
        aResult = (unsigned char *)aBytes;
    }
    const unsigned char *end = aBytes + aLength;
    while (aBytes != end) {
        const unsigned char *key = aKey + position;
        for (; position < aKeyLength && aBytes != end; position++) {
            *aResult++ = *aBytes++ ^ *key++;
        }
        const unsigned char *back = aKey + position;
        for (; position != 0 && end != aBytes; position--) {
            back--;
            *aResult++ = *aBytes++ ^ *back;
        }
    }
}

// Decodes the five-bit characters of a code (counted from its end, up to eight at a time) into groups of
// five bytes.
int SSExtractCodeBytes(const char *aCode, unsigned int aLength, unsigned char *aBytes)
{
    unsigned char bits[0x100];
    memset(bits, 0, sizeof(bits));
    unsigned int remaining = aLength;
    for (;;) {
        unsigned char count = remaining < 9 ? (unsigned char)remaining : 8;
        const char *position = aCode + remaining;
        unsigned char bitIndex = 0;
        unsigned int left = remaining;
        for (; (unsigned char)((unsigned char)remaining - (unsigned char)left) < count; left--) {
            char value = (char)(*(position - 1) - 0x32);
            char scaled = (char)((unsigned short)(value * 0x10093) >> 8);
            unsigned char decoded = (unsigned char)(((value + ((value >> 7) - value / 0x1d))
                                                     - (char)((short)(value * 0x100b3) >> 12))
                                                    + (scaled >> 3) * -7 + (scaled >> 4) * 7);
            for (int bit = 0; bit < 5; bit++) {
                bits[(bitIndex + bit) & 0xff] = (unsigned char)((decoded >> bit) & 1);
            }
            bitIndex += 5;
            position--;
        }
        for (int byte = 0; byte < 5; byte++) {
            unsigned int value = 0;
            unsigned int index = ((unsigned int)byte & 0xff) << 3;
            for (int bit = 7; bit >= 0; bit--, index++) {
                value |= (unsigned int)(bits[index & 0xff] & 1) << bit;
            }
            *aBytes++ = (unsigned char)value;
        }
        if (left == 0) {
            break;
        }
        remaining = left;
    }
    return 0;
}

// Packs the user info and a 48 bit trailer (a value and its CRC) into interleaved bit groups.
void SSPackUserInfo(const unsigned char *aInfo, int aLength, unsigned int aValue, unsigned short aCRC,
                    unsigned char *aResult)
{
    unsigned int infoBits = (unsigned int)aLength * 8;
    unsigned int groups = (infoBits + 0x34) / 5;
    unsigned char trailer[6];
    for (int i = 0; i < 4; i++) {
        trailer[i] = (unsigned char)(aValue >> (i * 8));
    }
    trailer[4] = (unsigned char)(aCRC);
    trailer[5] = (unsigned char)(aCRC >> 8);
    memset(aResult, 0, (groups * 5 + 7) >> 3);
    if (infoBits % groups == 0 && 0x30 % groups == 0) {
        unsigned int outputBit = 0;
        unsigned int trailerIndex = 0;
        unsigned char trailerBit = 0;
        unsigned char infoBit = 0;
        while (outputBit < infoBits + 0x30) {
            unsigned char first = trailerBit;
            for (; (unsigned char)(trailerBit - first) < 0x30 / groups; trailerBit++) {
                unsigned char sourceBit = ~trailerBit & 7;
                unsigned char targetBit = ~(unsigned char)outputBit & 7;
                SSCopyBit(trailer[trailerIndex], sourceBit, aResult, targetBit);
                trailerIndex += (sourceBit == 0);
                aResult += (targetBit == 0);
                outputBit++;
            }
            unsigned char firstInfo = infoBit;
            for (; (unsigned char)(infoBit - firstInfo) < infoBits / groups; infoBit++) {
                unsigned char sourceBit = ~infoBit & 7;
                unsigned char targetBit = ~(unsigned char)outputBit & 7;
                SSCopyBit(*aInfo, sourceBit, aResult, targetBit);
                aInfo += (sourceBit == 0);
                aResult += (targetBit == 0);
                outputBit++;
            }
        }
    }
}

void SSUnpackUserInfo(const unsigned char *aPacked, int aLength, unsigned char *aInfo, unsigned int aInfoLength,
                      unsigned int *aValue, unsigned short *aCRC)
{
    unsigned char trailer[6] = { 0, 0, 0, 0, 0, 0 };
    unsigned int packedBits = (unsigned int)aLength * 8;
    unsigned int groups = (packedBits + 4) / 5;
    memset(aInfo, 0, (packedBits - 0x29) >> 3);
    if ((packedBits - 0x30) % groups == 0 && 0x30 % groups == 0) {
        unsigned char infoBit = 0;
        unsigned char trailerBit = 0;
        unsigned int inputBit = 0;
        unsigned int trailerIndex = 0;
        while (inputBit < packedBits) {
            for (unsigned int n = 0; n < 0x30 / groups; n++) {
                unsigned char sourceBit = ~(unsigned char)inputBit & 7;
                unsigned char targetBit = ~trailerBit & 7;
                SSCopyBit(*aPacked, sourceBit, &trailer[trailerIndex], targetBit);
                aPacked += (sourceBit == 0);
                trailerIndex += (targetBit == 0);
                trailerBit++;
                inputBit++;
            }
            for (unsigned int n = 0; n < (packedBits - 0x30) / groups; n++) {
                unsigned char sourceBit = ~(unsigned char)inputBit & 7;
                unsigned char targetBit = ~infoBit & 7;
                SSCopyBit(*aPacked, sourceBit, aInfo, targetBit);
                aPacked += (sourceBit == 0);
                aInfo += (targetBit == 0);
                infoBit++;
                inputBit++;
            }
        }
    }
    *aValue = 0;
    *aCRC = 0;
    unsigned int value = 0;
    for (int i = 0; i < 4; i++) {
        value = (unsigned int)trailer[i] << (i * 8) | value;
    }
    *aValue = value;
    *aCRC = (unsigned short)(trailer[4] | (trailer[5] << 8));
}

int SSDecoderExtractUserBytes(void)
{
    return 2;
}

int SSDecoderExtractUserInfo(const char *aCode, int aLength, int aType, unsigned char *aInfo,
                             unsigned int *aInfoLength, unsigned int *aValue)
{
    if (0x27 < (unsigned int)(aLength * 5 - 0x51) || aType != 0x7369616c || aInfoLength == NULL) {
        return 3;
    }
    unsigned int packedLength = (unsigned int)(aLength * 5 + 7) >> 3;
    unsigned int infoLength = (packedLength * 8 - 0x29) >> 3;
    if (aInfo == NULL) {
        *aInfoLength = infoLength;
        return 0;
    }
    if (aCode == NULL || *aInfoLength < infoLength) {
        return 3;
    }
    unsigned char packed[0x20];
    int result = SSExtractCodeBytes(aCode, aLength, packed);
    if (result != 0) {
        return result;
    }
    unsigned int value = 0;
    unsigned short crc = 0;
    SSUnpackUserInfo(packed, packedLength, aInfo, infoLength, &value, &crc);
    memcpy(packed, aInfo, infoLength);
    for (int i = 3; i >= 0; i--) {
        packed[infoLength + (3 - i)] = (unsigned char)(value >> (i * 8));
    }
    if (0x41816abe < value + 0x469cf7ff || SSCRC16Digest(packed, (unsigned short)(infoLength + 4)) != crc) {
        return 5;
    }
    if (aValue != NULL) {
        *aValue = value;
    }
    *aInfoLength = infoLength;
    return 0;
}

// Splits the "_0" tail of a network signature: two characters giving a count (digits and a letter scale).
int SSDecomposeNetworkSignature(char *aSignature, unsigned int aLength, int *aCount)
{
    if (aLength < 2) {
        return -1;
    }
    char *tail = aSignature + aLength - 2;
    if (aCount != NULL) {
        if (strncmp(tail, "_0", 2) == 0) {
            return -1;
        }
        char first = tail[0];
        if ((unsigned char)(first - '0') < 10) {
            unsigned char second = (unsigned char)(tail[1] - '0');
            int count;
            if (second >= 0x33 || (count = first * 0x32 - 0x960 + (char)second, *aCount = count, count == 0)) {
                return -1;
            }
        } else {
            char scale = (char)(first - 'A');
            if (scale < 0) {
                return -1;
            }
            int digit = (int)tail[1] - '0';
            int count;
            if (scale == 0) {
                if (digit > 9 || digit < 0) {
                    return -1;
                }
                count = digit * 100 + 600;
            } else {
                if ((unsigned int)((int)tail[1] - 0x31) > 8) {
                    return -1;
                }
                count = digit * 1000;
                for (; scale != 1 && scale - 1 >= 0; scale--) {
                    count *= 10;
                }
            }
            *aCount = count;
        }
    }
    tail[0] = '_';
    tail[1] = '0';
    return 0;
}

int SSUDGenerateSecurityCodeWithUniqueDataString(void)
{
    return 2;
}

int SSUDValidateSecurityCode(void)
{
    return 2;
}

// Builds the unique data string: a header, the data repeated and encrypted with the four strings as key
// stream, CRCs around it, all encoded as text.
int SSUDGenerateUniqueDataString(const void *aData, unsigned char aDataLength, const char *aString1,
                                 const char *aString2, const char *aString3, const char *aString4,
                                 int aReserved, char *aResult, unsigned int *aResultSize)
{
    if (aResultSize == NULL || aString1 == NULL || aString2 == NULL || strlen(aString1) == 0 || strlen(aString2) == 0) {
        return 3;
    }
    size_t length1 = strlen(aString1);
    size_t length2 = strlen(aString2);
    size_t length3 = aString3 != NULL ? strlen(aString3) : 0;
    size_t length4 = aString4 != NULL ? strlen(aString4) : 0;
    unsigned int dataLength = aDataLength;
    unsigned int keyLength = (unsigned int)(length1 + length2 + length3 + length4);
    unsigned int body = dataLength + 2;
    body = body + ((keyLength - 3U) / body) * body;
    unsigned int rawLength = body + 9;
    unsigned int textLength = (rawLength * 8 + 5U) / 6;
    unsigned int resultSize = textLength + 1;
    if (aResult == NULL) {
        *aResultSize = resultSize;
        return 0;
    }
    if (*aResultSize < resultSize) {
        return 6;
    }
    unsigned char *raw = malloc(keyLength + rawLength);
    if (raw == NULL) {
        return 1;
    }
    memcpy(raw, "U.DI", 4);
    raw[4] = 0x00;
    raw[5] = 0x01;
    raw[6] = aDataLength;
    unsigned char *bodyStart = raw + 7;
    unsigned short crc = SSCRC16Digest(aData, dataLength);
    bodyStart[0] = (unsigned char)(crc >> 8);
    bodyStart[1] = (unsigned char)crc;
    unsigned char *position = bodyStart + 2;
    unsigned int remaining = body - 2;
    while (remaining != 0) {
        unsigned int chunk = remaining < dataLength ? remaining : dataLength;
        if (chunk == 0) {
            break;
        }
        memcpy(position, aData, chunk);
        position += chunk;
        remaining -= chunk;
    }
    unsigned char *key = position + 2;
    unsigned char *keyPosition = key;
    const char *strings[4] = { aString1, aString2, aString3, aString4 };
    size_t lengths[4] = { length1, length2, length3, length4 };
    for (int i = 0; i < 4; i++) {
        memcpy(keyPosition, strings[i], lengths[i]);
        keyPosition += lengths[i];
    }
    SSEncryptBytesWithKeyAndOffset(bodyStart, body, key, keyLength, 0, NULL);
    crc = SSCRC16Digest(bodyStart, (unsigned short)body);
    position[0] = (unsigned char)(crc >> 8);
    position[1] = (unsigned char)crc;
    int result = SSEncodeBytes(raw, rawLength, aResult, textLength);
    if (result == 0) {
        aResult[textLength] = 0;
    }
    free(raw);
    return result != 0;
}

int SSUtilityIsPropertyListValid(CFPropertyListRef aList)
{
    return aList != NULL && CFPropertyListIsValid(aList, kCFPropertyListBinaryFormat_v1_0);
}

CFIndex SSUtilityCreateDataWithPropertyList(CFAllocatorRef aAllocator, CFPropertyListRef aList, CFDataRef *aData)
{
    CFIndex written = 0;
    CFWriteStreamRef stream = CFWriteStreamCreateWithAllocatedBuffers(aAllocator, aAllocator);
    if (stream == NULL) {
        return 0;
    }
    if (CFWriteStreamOpen(stream)) {
        written = CFPropertyListWriteToStream(aList, stream, kCFPropertyListBinaryFormat_v1_0, NULL);
        CFWriteStreamClose(stream);
        if (written != 0) {
            *aData = CFWriteStreamCopyProperty(stream, kCFStreamPropertyDataWritten);
            if (*aData != NULL) {
                if (CFDataGetTypeID() != CFGetTypeID(*aData) || written != CFDataGetLength(*aData)) {
                    written = 0;
                    CFRelease(*aData);
                    *aData = NULL;
                }
            }
        }
    }
    CFRelease(stream);
    return written;
}

CFPropertyListRef SSUtilityCreatePropertyListWithBytes(CFAllocatorRef aAllocator, const UInt8 *aBytes, CFIndex aLength)
{
    CFPropertyListRef list = NULL;
    CFReadStreamRef stream = CFReadStreamCreateWithBytesNoCopy(aAllocator, aBytes, aLength, kCFAllocatorNull);
    if (stream != NULL) {
        if (CFReadStreamOpen(stream)) {
            list = CFPropertyListCreateFromStream(aAllocator, stream, 0, kCFPropertyListImmutable, NULL, NULL);
            CFReadStreamClose(stream);
        }
        CFRelease(stream);
    }
    return list;
}
