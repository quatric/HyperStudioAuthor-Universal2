/*
 * SL: the licensing library embedded in the HyperStudio executable.
 * Ported from the i386 original (functions 002aab8b-002b4ecb). The original
 * stored 4-byte pointers inside its context structures; here the structures
 * are typed so that they stay valid for 64-bit pointers.
 */
#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <fcntl.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include "SLLicense.h"

#define SL_LICENSE_ENCRYPTED_FLAG 1 /* *PTR_DAT_00336a24 */

#define SL_TYPE_LOCAL_MACHINE 0x2e537552
#define SL_TYPE_LOCAL_MACHINE_TRIAL 0x2e54726c
#define SL_TYPE_LIMITED_NETWORK 0x2e4e6574

#include "sl_tables.h"

static const char kSLBase64Alphabet[] = "0123456789@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz";
static const char kSLObfuscatedAlphabet[] = "abcdefghijklmnopqrstuvwxyz012345";

static uint32_t be32(const void *p)
{
    const uint8_t *b = p;
    return (uint32_t)b[0] << 24 | (uint32_t)b[1] << 16 | (uint32_t)b[2] << 8 | b[3];
}

static uint16_t be16(const void *p)
{
    const uint8_t *b = p;
    return (uint16_t)(b[0] << 8 | b[1]);
}

static void put_be32(void *p, uint32_t v)
{
    uint8_t *b = p;
    b[0] = v >> 24;
    b[1] = v >> 16;
    b[2] = v >> 8;
    b[3] = v;
}

static void put_be16(void *p, uint16_t v)
{
    uint8_t *b = p;
    b[0] = v >> 8;
    b[1] = v;
}

/* A big-endian double stored as two big-endian words, high word first. */
static double be_double(const void *p)
{
    const uint8_t *b = p;
    uint64_t bits = (uint64_t)be32(b) << 32 | be32(b + 4);
    double d;
    memcpy(&d, &bits, sizeof d);
    return d;
}

static void put_be_double(void *p, double d)
{
    uint64_t bits;
    memcpy(&bits, &d, sizeof bits);
    put_be32(p, (uint32_t)(bits >> 32));
    put_be32((uint8_t *)p + 4, (uint32_t)bits);
}

static void *SLAlloc(size_t size)   /* FUN_002ab813 */
{
    return malloc(size);
}

static void SLFree(void *p)         /* FUN_002ab83d */
{
    free(p);
}

/* FUN_002aab8b: xor with the key, reflecting it at both ends */
static void SLXorReflected(const uint8_t *src, size_t length, const uint8_t *key, size_t keyLength, size_t pos, uint8_t *out)
{
    if (out == NULL) {
        out = (uint8_t *)src;
    }
    const uint8_t *end = src + length;
    while (src != end) {
        const uint8_t *k = key + pos;
        for (; pos < keyLength && end != src; pos++) {
            *out++ = *src++ ^ *k++;
        }
        const uint8_t *r = key + pos;
        for (; pos != 0 && end != src; pos--) {
            *out++ = *src++ ^ *--r;
        }
    }
}

/* FUN_002ab466: same, starting at an absolute stream position */
static void SLXorAt(const uint8_t *src, size_t length, size_t start, const uint8_t *key, size_t keyLength, uint8_t *out)
{
    size_t pos = 0;
    if (start != 0) {
        if (out == NULL) {
            out = (uint8_t *)src;
        }
        pos = start % keyLength;
        if (((start / keyLength) & 1) != 0) {
            pos = keyLength - pos;
            const uint8_t *k = key + pos;
            const uint8_t *end = src + length;
            for (; pos != 0 && end != src; pos--) {
                *out++ = *src++ ^ *--k;
                length--;
            }
        }
    }
    if (out == NULL) {
        out = (uint8_t *)src;
    }
    const uint8_t *end = src + length;
    while (src != end) {
        const uint8_t *k = key + pos;
        for (; pos < keyLength && src != end; pos++) {
            *out++ = *src++ ^ *k++;
        }
        const uint8_t *r = key + pos;
        for (; pos != 0 && end != src; pos--) {
            *out++ = *src++ ^ *--r;
        }
    }
}

/* FUN_002aaee3: splits 48 bits (a 32-bit value and a 16-bit checksum) out of a bit stream of 5-bit digits */
static void SLUnpackDigits(const uint8_t *src, int byteCount, uint8_t *out, uint32_t *value, uint16_t *checksum)
{
    uint8_t header[6] = { 0, 0, 0, 0, 0, 0 };
    uint32_t bits = byteCount * 8;
    uint32_t digitBits = (bits + 4) / 5;
    memset(out, 0, (bits - 0x29) >> 3);
    if ((bits - 0x30) % digitBits == 0 && 0x30 % digitBits == 0) {
        uint8_t headerBit = 0;
        uint8_t outBit = 0;
        uint32_t position = 0;
        uint8_t headerIndex = 0;
        while (position < bits) {
            for (uint32_t i = 0; i < 0x30 / digitBits; i++) {
                uint8_t *dst = header + headerIndex;
                uint8_t srcShift = ~(uint8_t)position & 7;
                uint8_t dstShift = ~headerBit & 7;
                uint8_t byte = *src;
                uint8_t mask = (uint8_t)(1 << dstShift);
                if (srcShift < dstShift) {
                    *dst |= mask & (uint8_t)(byte << (dstShift - srcShift));
                }
                else if (dstShift < srcShift) {
                    *dst |= mask & (uint8_t)(byte >> (srcShift - dstShift));
                }
                else {
                    *dst |= byte & mask;
                }
                src += (srcShift == 0);
                headerIndex += (dstShift == 0);
                headerBit++;
                position++;
            }
            for (uint32_t i = 0; i < (bits - 0x30) / digitBits; i++) {
                uint8_t srcShift = ~(uint8_t)position & 7;
                uint8_t dstShift = ~outBit & 7;
                uint8_t byte = *src;
                uint8_t mask = (uint8_t)(1 << dstShift);
                if (srcShift < dstShift) {
                    *out |= mask & (uint8_t)(byte << (dstShift - srcShift));
                }
                else if (dstShift < srcShift) {
                    *out |= mask & (uint8_t)(byte >> (srcShift - dstShift));
                }
                else {
                    *out |= byte & mask;
                }
                src += (srcShift == 0);
                out += (dstShift == 0);
                outBit++;
                position++;
            }
        }
    }
    *value = 0;
    *checksum = 0;
    for (int i = 0; i < 4; i++) {
        *value |= (uint32_t)header[i] << (i * 8);
    }
    for (int i = 0; i < 2; i++) {
        *checksum |= (uint16_t)((uint16_t)header[4 + i] << (i * 8));
    }
}

/* FUN_002b2ed2: CRC-16/CCITT-FALSE */
static uint16_t SLCRC16(const uint8_t *data, uint16_t length)
{
    if (data == NULL || length == 0 || length > 0xfff) {
        return 0;
    }
    uint16_t crc = 0xffff;
    for (uint16_t i = 0; i < length; i++) {
        crc ^= (uint16_t)data[i] << 8;
        for (int bit = 0; bit < 8; bit++) {
            crc = (crc & 0x8000) ? (uint16_t)((crc << 1) ^ 0x1021) : (uint16_t)(crc << 1);
        }
    }
    return crc;
}

typedef struct {
    uint32_t crc;
    uint32_t length;
    const uint32_t *table;
} SLCRC32;

static uint32_t sCRC32Table[256];
static char sCRC32TableReady;

/* FUN_002b2dfa */
static void SLCRC32Init(SLCRC32 *state)
{
    if (!sCRC32TableReady) {
        for (uint32_t n = 0; n < 0x100; n++) {
            uint32_t c = n;
            for (int k = 0; k < 8; k++) {
                c = (c & 1) ? (c >> 1) ^ 0xedb88320 : c >> 1;
            }
            sCRC32Table[n] = c;
        }
        sCRC32TableReady = 1;
    }
    state->crc = 0xffffffff;
    state->length = 0;
    state->table = sCRC32Table;
}

/* FUN_002b2e6c */
static uint32_t SLCRC32Update(SLCRC32 *state, const void *data, uint32_t length)
{
    uint32_t done = state->length;
    if (0xfffffff < done + length) {
        length = 0xfffffff - done;
    }
    const uint8_t *p = data;
    for (uint32_t i = 0; i < length; i++) {
        state->crc = state->crc >> 8 ^ state->table[(p[i] ^ state->crc) & 0xff];
    }
    state->length = length + done;
    return length;
}

/* FUN_002ab132: packs bytes into 6-bit digits and maps them onto the base-64 alphabet */
static int SLEncodeBase64(const uint8_t *src, int length, char *out, uint32_t outSize)
{
    if (length != 0) {
        uint32_t digits = (length * 8 + 5U) / 6;
        if (digits <= outSize) {
            memset(out, 0, digits);
            for (uint32_t bit = 0; bit < (uint32_t)(length * 8); bit++) {
                uint8_t *dst = (uint8_t *)out + bit / 6;
                uint8_t byte = src[bit >> 3];
                uint8_t srcShift = ~(uint8_t)bit & 7;
                uint8_t dstShift = 5 - (uint8_t)(bit % 6);
                uint8_t mask = (uint8_t)(1 << dstShift);
                if (srcShift < dstShift) {
                    *dst |= mask & (uint8_t)(byte << (dstShift - srcShift));
                }
                else {
                    if (dstShift < srcShift) {
                        byte = (uint8_t)(byte >> (srcShift - dstShift));
                    }
                    *dst |= mask & byte;
                }
            }
            for (uint32_t i = 0; i < digits; i++) {
                out[i] = kSLBase64Alphabet[(uint8_t)out[i] & 0x3f];
            }
            return 0;
        }
    }
    return -1;
}

/* FUN_002ab2df: inverse of SLEncodeBase64 */
static int SLDecodeBase64(const char *src, int length, uint8_t *out, uint32_t outSize)
{
    if (length != 0) {
        uint32_t bytes = (length * 6 + 5U) >> 3;
        if (bytes <= outSize) {
            memset(out, 0, bytes);
            for (uint32_t i = 0; i < (uint32_t)(length * 6); i += 6) {
                uint32_t bit = i;
                for (int n = 0; n < 6; n++) {
                    uint8_t *dst = out + (bit >> 3);
                    uint8_t value = kSLBase64Value[(uint8_t)src[bit / 6]];
                    uint8_t srcShift = (uint8_t)((bit / 6) * 6 - bit) + 5;
                    uint8_t dstShift = ~(uint8_t)bit & 7;
                    uint8_t mask = (uint8_t)(1 << dstShift);
                    if (srcShift < dstShift) {
                        *dst |= mask & (uint8_t)(value << (dstShift - srcShift));
                    }
                    else {
                        if (dstShift < srcShift) {
                            value = (uint8_t)(value >> (srcShift - dstShift));
                        }
                        *dst |= mask & value;
                    }
                    bit++;
                }
            }
            return 0;
        }
    }
    return -1;
}

/* FUN_002ab539: converts serial characters (5 bits each) to bytes, 8 digits at a time */
static int SLDecodeSerialDigits(const char *src, uint32_t length, uint8_t *out)
{
    uint8_t bits[40] = { 0 };
    for (;;) {
        uint8_t digitCount = length < 9 ? (uint8_t)length : 8;
        uint8_t position = 0;
        const char *end = src + length;
        uint32_t remaining = length;
        for (; (uint8_t)((uint8_t)length - remaining) < digitCount; remaining--) {
            uint8_t value = kSLSerialValue[(uint8_t)end[-1]];
            for (int bit = 0; bit < 5; bit++) {
                bits[(uint8_t)(position + bit)] = (value >> bit) & 1;
            }
            position += 5;
            end--;
        }
        for (uint32_t i = 0; i < 5; i++) {
            uint32_t byte = 0;
            uint32_t index = (i & 0xff) << 3;
            for (int shift = 7; shift != -1; shift--) {
                byte |= (uint32_t)(bits[index++ & 0xff] & 1) << shift;
            }
            *out++ = (uint8_t)byte;
        }
        if (remaining == 0) {
            break;
        }
        length = remaining;
    }
    return 0;
}

/* FUN_002ab674: decodes the digits of a serial number into its payload */
static int SLDecodeSerialPayload(const char *digits, int count, uint32_t magic, void *out, uint32_t *size, uint32_t *valueOut)
{
    if (0x27 < count * 5 - 0x51U || magic != 0x7369616c || size == NULL) {
        return 3;
    }
    uint32_t bytes = (count * 5 + 7U) >> 3;
    uint32_t payload = (bytes * 8 - 0x29) >> 3;
    if (out == NULL) {
        *size = payload;
    }
    else {
        if (digits == NULL || *size < payload) {
            return 3;
        }
        uint8_t temp[15];
        int status = SLDecodeSerialDigits(digits, count, temp);
        if (status != 0) {
            return status;
        }
        uint32_t value = 0;
        uint16_t checksum = 0;
        SLUnpackDigits(temp, bytes, out, &value, &checksum);
        memcpy(temp, out, payload);
        put_be32(temp + payload, value);
        if (0x41816abe < value + 0x469cf7ff || SLCRC16(temp, (uint16_t)(payload + 4)) != checksum) {
            return 5;
        }
        if (valueOut != NULL) {
            *valueOut = value;
        }
        *size = payload;
    }
    return 0;
}

/* FUN_002ab867: inserts the dashes between the groups of a serial number */
static int SLFormatSerial(int serialLength, size_t groupSize, int groupCount, const char *src, char *dst, uint32_t dstSize)
{
    if (serialLength + 1U <= dstSize) {
        for (uint32_t i = 0; i < groupCount - 1U; i++) {
            strncpy(dst, src, groupSize);
            dst += groupSize;
            src += groupSize;
            *dst++ = '-';
        }
        strcpy(dst, src);
        return 0;
    }
    return -1;
}

/* FUN_002ab8d7: builds the serial of a trial license (prefix, product name, then TRIAL padding) */
static int SLBuildTrialSerial(int serialLength, int groupSize, int groupCount, const char *productName, const char *prefix, char *out, uint32_t outSize)
{
    (void)groupSize;
    uint32_t total = (serialLength - groupCount) + 2;
    if (total <= outSize) {
        size_t productLength = strlen(productName);
        size_t prefixLength = strlen(prefix);
        if (productLength + 6 + prefixLength <= total) {
            strcpy(out, prefix);
            strcpy(out + prefixLength, productName);
            out += productLength + prefixLength;
            uint32_t remaining = (total - (productLength + prefixLength)) - 1;
            uint32_t fill = remaining;
            uint32_t count = 0;
            for (;;) {
                if (remaining == count) {
                    return 0;
                }
                count += 5;
                if (fill < 5) {
                    break;
                }
                memcpy(out, "TRIAL", 6);
                fill -= 5;
                out += 5;
            }
            strncpy(out, "TRIAL", fill);
            out[fill] = '\0';
            return 0;
        }
    }
    return -1;
}

/* FUN_002aba71: removes the dashes between the groups of a serial number */
static int SLUnformatSerial(int serialLength, int groupSize, uint32_t groupCount, const char *src, char *out, uint32_t outSize)
{
    int status = -1;
    if ((serialLength - (int)groupCount) + 2 <= (int)outSize) {
        uint32_t groups = 0;
        for (;;) {
            const char *dash = strchr(src, '-');
            if (dash == NULL) {
                status = 0;
                break;
            }
            if ((int)(dash - src) != groupSize) {
                status = -1;
                break;
            }
            strncpy(out, src, groupCount);
            out += groupCount;
            groups++;
            src += groupCount + 1;
        }
        *out = '\0';
        if (status == 0 && groups < groupCount) {
            strcpy(out, src);
        }
    }
    return status;
}

/* FUN_002abd98: license type code of a type name */
static uint32_t SLLicenseTypeCode(const char *name)
{
    if (strcmp(name, "LOCAL_MACHINE") == 0) {
        return SL_TYPE_LOCAL_MACHINE;
    }
    if (strcmp(name, "LIMITED_NETWORK") == 0) {
        return SL_TYPE_LIMITED_NETWORK;
    }
    if (strcmp(name, "LOCAL_MACHINE_TRIAL") == 0) {
        return SL_TYPE_LOCAL_MACHINE_TRIAL;
    }
    return 0;
}

/* FUN_002ac204: type name of a license type code */
static size_t SLLicenseTypeName(uint32_t code, char *buffer, size_t size)
{
    const char *name = NULL;
    if (code == SL_TYPE_LOCAL_MACHINE) {
        name = "LOCAL_MACHINE";
    }
    else if (code == SL_TYPE_LOCAL_MACHINE_TRIAL) {
        name = "LOCAL_MACHINE_TRIAL";
    }
    else if (code == SL_TYPE_LIMITED_NETWORK) {
        name = "LIMITED_NETWORK";
    }
    if (name == NULL) {
        return 0;
    }
    size_t length = strlen(name) + 1;
    if (buffer == NULL || size == 0) {
        return length;
    }
    if (size >= length) {
        memcpy(buffer, name, length);
    }
    return length;
}

/* ---- slots holding the library, the application and the current license ---- */

typedef void (*SLSlotDestructor)(void *context, void *value, size_t size);

typedef struct SLSlot {
    void *value;
    void *context;
    size_t size;
    SLSlotDestructor destructor;
} SLSlot;

static SLSlot sLibrarySlot;      /* DAT_00342a80 */
static SLSlot sApplicationSlot;  /* DAT_00342a90 */
static SLSlot sLicenseSlot;      /* DAT_00342aa0 */

static void SLSlotSet(SLSlot *slot, void *value, size_t size, void *context, SLSlotDestructor destructor)
{
    if (slot->value != value) {
        if (slot->destructor != NULL) {
            slot->destructor(slot->context, slot->value, slot->size);
        }
        slot->value = value;
        slot->context = context;
        slot->size = size;
        slot->destructor = destructor;
    }
}

/* FUN_002abc88 */
void SLShutdown(void)
{
    SLSlot *slots[3] = { &sLibrarySlot, &sApplicationSlot, &sLicenseSlot };
    for (int i = 0; i < 3; i++) {
        if (slots[i]->destructor != NULL) {
            slots[i]->destructor(slots[i]->context, slots[i]->value, slots[i]->size);
        }
    }
    memset(&sLibrarySlot, 0, sizeof sLibrarySlot);
    memset(&sApplicationSlot, 0, sizeof sApplicationSlot);
    memset(&sLicenseSlot, 0, sizeof sLicenseSlot);
}

/* ---- the parsed library blob ---- */

typedef struct SLBlob {
    uint32_t version;              /* [0x00] 1 */
    uint32_t payloadSize;          /* [0x01] */
    double creationTime;           /* [0x02] */
    uint32_t heapSize;             /* [0x04] */
    const uint8_t *heap;           /* [0x05] */
    const uint8_t *heapKey;        /* [0x06] origin of the xor stream positions */
    uint32_t nameCount;            /* [0x07] */
    const uint8_t *names;          /* [0x08] */
    uint32_t groupCount;           /* [0x09] */
    const uint8_t *groups;         /* [0x0a] */
    uint32_t trialPrefixLength;    /* [0x0b] */
    const uint8_t *trialPrefix;    /* [0x0c] */
    uint32_t trialPrefixFlag;      /* [0x0d] */
    uint32_t magic;                /* [0x0e] 'lais' */
    uint32_t typeCount;            /* [0x0f] */
    const uint8_t *types;          /* [0x10] */
    double timeB;                  /* [0x11] */
    uint32_t recordsSize;          /* [0x13] */
    const uint8_t *recordsHeap;    /* [0x14] */
    const uint8_t *recordsKey;     /* [0x15] */
    uint32_t recordCount;          /* [0x16] */
    const uint8_t *records;        /* [0x17] */
    double timeC;                  /* [0x18] */
    uint32_t stringsSize;          /* [0x1a] */
    const uint8_t *stringsHeap;    /* [0x1b] */
    const uint8_t *stringsKey;     /* [0x1c] */
    uint32_t stringCount;          /* [0x1d] */
    const uint8_t *strings;        /* [0x1e] */
    const uint8_t *base;           /* [0x1f] */
} SLBlob;

/* FUN_002abd35: the encrypted trial prefix string */
static uint32_t SLBlobTrialPrefix(const SLBlob *blob, const uint8_t *key, size_t keyLength, char *out, uint32_t outSize)
{
    if (blob->trialPrefixFlag != 0xffffffff && blob->trialPrefix != NULL && blob->trialPrefixLength != 0) {
        uint32_t size = blob->trialPrefixLength + 1;
        if (out == NULL) {
            return size;
        }
        if (size <= outSize) {
            SLXorAt(blob->trialPrefix, size, blob->trialPrefix - blob->heapKey, key, keyLength, (uint8_t *)out);
            return size;
        }
    }
    return 0;
}

typedef struct SLRecord {
    uint32_t nameLength;
    const uint8_t *name;
    uint32_t count;
    uint32_t elementSize;
    const uint8_t *elements;
} SLRecord;

/* FUN_002abe4c */
static uint32_t SLBlobRecordAt(const SLBlob *blob, uint32_t index, SLRecord *out)
{
    if (index < blob->recordCount && blob->recordCount * 0x14 < blob->recordsSize) {
        uint32_t size = blob->recordsSize;
        const uint8_t *entry = blob->records + index * 0x14;
        if (size > 0x13) {
            uint32_t nameLength = be32(entry);
            uint32_t nameOffset = be32(entry + 4);
            const uint8_t *name = nameOffset < size ? blob->recordsHeap + nameOffset : NULL;
            uint32_t count = be32(entry + 8);
            uint32_t elementSize = be32(entry + 12);
            uint32_t elementsOffset = be32(entry + 16);
            const uint8_t *elements = elementsOffset < size ? blob->recordsHeap + elementsOffset : NULL;
            if (out == NULL) {
                return 0x14;
            }
            out->nameLength = nameLength;
            out->name = name;
            out->count = count;
            out->elementSize = elementSize;
            out->elements = elements;
            return 0x14;
        }
    }
    return 0;
}

/* FUN_002ac005: is the value one of the elements of the named record? */
static int SLBlobRecordHasValue(const SLBlob *blob, const uint8_t *key, size_t keyLength, const char *name, uint32_t value)
{
    if (blob == NULL || blob->recordCount == 0 || blob->recordsHeap == NULL) {
        return 0;
    }
    char *decoded = NULL;
    uint32_t decodedSize = 0;
    SLRecord record = { 0, NULL, 0, 0, NULL };
    int found = 0;
    uint32_t index = 0;
    for (;;) {
        if (blob->recordCount <= index || SLBlobRecordAt(blob, index, &record) == 0 || record.nameLength == 0) {
            goto done;
        }
        uint32_t size = record.nameLength + 1;
        if (decodedSize < size) {
            if (decoded != NULL) {
                SLFree(decoded);
            }
            decoded = SLAlloc(size);
            decodedSize = size;
        }
        SLXorAt(record.name, size, record.name - blob->recordsKey, key, keyLength, (uint8_t *)decoded);
        if (strcmp(decoded, name) == 0) {
            break;
        }
        index++;
    }
    if (record.elements != NULL && record.elementSize == 4 && record.count != 0) {
        const uint8_t *element = record.elements;
        for (uint32_t i = 0; i < record.count; i++, element += 4) {
            uint8_t raw[4];
            SLXorAt(element, 4, element - blob->recordsKey, key, keyLength, raw);
            if (be32(raw) == value) {
                found = 1;
                break;
            }
        }
    }
done:
    if (decoded != NULL) {
        SLFree(decoded);
    }
    return found;
}

/* FUN_002ac2ea and FUN_002ac3e3: a string of the group table / of the name table */
static uint32_t SLBlobTableString(const SLBlob *blob, const uint8_t *table, uint32_t tableCount, const uint8_t *key, size_t keyLength, uint32_t index, char *out, uint32_t outSize)
{
    uint32_t size = blob->heapSize;
    if (index < tableCount && tableCount << 3 < size && table != NULL && size > 7) {
        const uint8_t *entry = table + index * 8;
        uint32_t length = be32(entry);
        uint32_t offset = be32(entry + 4);
        const uint8_t *string;
        if (offset < size && (string = blob->heap + offset) != NULL && length != 0) {
            length++;
            if (out == NULL) {
                return length;
            }
            if (length <= outSize) {
                SLXorAt(string, length, string - blob->heapKey, key, keyLength, (uint8_t *)out);
                return length;
            }
        }
    }
    return 0;
}

static uint32_t SLBlobGroupString(const SLBlob *blob, const uint8_t *key, size_t keyLength, uint32_t index, char *out, uint32_t outSize)
{
    return SLBlobTableString(blob, blob->groups, blob->groupCount, key, keyLength, index, out, outSize);
}

static uint32_t SLBlobNameString(const SLBlob *blob, const uint8_t *key, size_t keyLength, uint32_t index, char *out, uint32_t outSize)
{
    return SLBlobTableString(blob, blob->names, blob->nameCount, key, keyLength, index, out, outSize);
}

typedef struct SLTypeInfo {
    uint32_t value0;
    uint32_t value1;
    uint32_t value2;
    const uint8_t *data;
} SLTypeInfo;

/* FUN_002ac4dc: looks a type up by its name; returns 0x18 when the table was searched far enough to find it */
static uint32_t SLBlobFindType(const SLBlob *blob, const char *name, const uint8_t *key, size_t keyLength, SLTypeInfo *out)
{
    if (blob->typeCount != 0 && blob->types != NULL) {
        uint32_t status = 0;
        char *decoded = NULL;
        uint32_t decodedSize = 0;
        uint32_t index;
        size_t entryOffset = 0;
        for (index = 0; index < blob->typeCount; index++) {
            uint32_t size = blob->heapSize;
            const uint8_t *entry = blob->types + entryOffset;
            if (size < 0x18) {
                status = 0;
                break;
            }
            uint32_t length = be32(entry);
            uint32_t offset = be32(entry + 4);
            const uint8_t *string = offset < size ? blob->heap + offset : NULL;
            uint32_t offset2 = be32(entry + 0x14);
            const uint8_t *data = offset2 < size ? blob->heap + offset2 : NULL;
            if (length == 0 || string == NULL) {
                status = 0x18;
                break;
            }
            length++;
            if (decodedSize < length) {
                if (decoded != NULL) {
                    SLFree(decoded);
                }
                decoded = SLAlloc(length);
                decodedSize = length;
            }
            SLXorAt(string, length, string - blob->heapKey, key, keyLength, (uint8_t *)decoded);
            entryOffset += 0x18;
            if (strcmp(decoded, name) == 0) {
                if (out != NULL) {
                    out->value0 = be32(entry + 8);
                    out->value1 = be32(entry + 12);
                    out->value2 = be32(entry + 16);
                    out->data = data;
                }
                status = 0x18;
                break;
            }
            status = 0x18;
        }
        if (decoded != NULL) {
            SLFree(decoded);
        }
        if (blob->typeCount != index) {
            return status;
        }
    }
    return 0;
}

/* FUN_002ac7dc: looks a code up in the list of the named string table entry */
static uint32_t SLBlobFindString(const SLBlob *blob, const char *name, uint32_t code, const uint8_t *key, size_t keyLength, const uint8_t **valueOut, uint32_t *lengthOut)
{
    size_t nameLength = strlen(name);
    if (nameLength == 0 || (blob->stringCount << 4) >= blob->stringsSize) {
        return 0;
    }
    char *decoded = SLAlloc(nameLength + 1);
    if (decoded == NULL) {
        return 0;
    }
    uint32_t status = 0;
    const uint8_t *items = NULL;
    uint32_t itemCount = 0;
    uint32_t index;
    for (index = 0; index < blob->stringCount; index++) {
        uint32_t size = blob->stringsSize;
        const uint8_t *entry = blob->strings + index * 0x10;
        if (size < 0x10) {
            status = 0;
            break;
        }
        uint32_t length = be32(entry);
        uint32_t offset = be32(entry + 4);
        const uint8_t *string = offset < size ? blob->stringsHeap + offset : NULL;
        itemCount = be32(entry + 8);
        uint32_t itemsOffset = be32(entry + 12);
        items = itemsOffset < size ? blob->stringsHeap + itemsOffset : NULL;
        if (nameLength == length) {
            SLXorAt(string, nameLength, string - blob->stringsKey, key, keyLength, (uint8_t *)decoded);
            decoded[nameLength] = '\0';
            if (strcmp(decoded, name) == 0) {
                status = 0x10;
                break;
            }
        }
        status = 0x10;
    }
    SLFree(decoded);
    if (status != 0) {
        uint32_t i = 0;
        const uint8_t *item = items;
        if (blob->stringCount != index) {
            for (; i < itemCount; i++) {
                uint8_t raw[12];
                SLXorAt(item, 12, item - blob->stringsKey, key, keyLength, raw);
                if (blob->stringsSize < 0xc) {
                    return 0;
                }
                uint32_t itemCode = be32(raw);
                uint32_t itemLength = be32(raw + 4);
                uint32_t valueOffset = be32(raw + 8);
                const uint8_t *value = valueOffset < blob->stringsSize ? blob->stringsHeap + valueOffset : NULL;
                item += 12;
                if (code == itemCode) {
                    if (valueOut != NULL) {
                        *lengthOut = itemLength;
                        *valueOut = value;
                    }
                    return itemLength;
                }
                status = 0xc;
            }
            if (i != itemCount) {
                return status;
            }
        }
    }
    return 0;
}

/* FUN_002acba2: parses the library blob header (big endian) */
static int SLParseBlob(const uint8_t *raw, uint32_t size, SLBlob *b)
{
    if (size < 0x7c) {
        return 0;
    }
    const uint8_t *base = raw + 0x7c;
    b->base = base;
    b->version = be32(raw);
    b->payloadSize = be32(raw + 4);
    b->heapSize = be32(raw + 8);
    uint32_t offset = be32(raw + 0xc);
    b->heap = offset < size ? base + offset : NULL;
    b->creationTime = be_double(raw + 0x10);
    offset = be32(raw + 0x18);
    b->heapKey = offset < size ? b->heap + offset : NULL;
    b->nameCount = be32(raw + 0x1c);
    offset = be32(raw + 0x20);
    b->names = offset < size ? base + offset : NULL;
    b->groupCount = be32(raw + 0x24);
    offset = be32(raw + 0x28);
    b->groups = offset < size ? base + offset : NULL;
    b->trialPrefixLength = be32(raw + 0x2c);
    offset = be32(raw + 0x30);
    b->trialPrefix = offset < size ? base + offset : NULL;
    b->trialPrefixFlag = be32(raw + 0x34);
    b->magic = be32(raw + 0x38);
    b->typeCount = be32(raw + 0x3c);
    offset = be32(raw + 0x40);
    b->types = offset < size ? base + offset : NULL;
    b->timeB = be_double(raw + 0x44);
    b->recordsSize = be32(raw + 0x4c);
    offset = be32(raw + 0x50);
    b->recordsHeap = offset < size ? base + offset : NULL;
    offset = be32(raw + 0x54);
    b->recordsKey = offset < size ? base + offset : NULL;
    b->recordCount = be32(raw + 0x58);
    offset = be32(raw + 0x5c);
    b->records = offset < size ? base + offset : NULL;
    b->timeC = be_double(raw + 0x60);
    b->stringsSize = be32(raw + 0x68);
    offset = be32(raw + 0x6c);
    b->stringsHeap = offset < size ? base + offset : NULL;
    offset = be32(raw + 0x70);
    b->stringsKey = offset < size ? base + offset : NULL;
    b->stringCount = be32(raw + 0x74);
    offset = be32(raw + 0x78);
    b->strings = offset < size ? base + offset : NULL;

    /* validation */
    if (b->version != 1 || b->payloadSize == 0 || b->payloadSize + 0x7c > size || b->creationTime == 0.0 || b->heap == NULL) {
        return 0;
    }
    uint32_t extent = 0;
    const SLBlob *recordsOwner = NULL;
    const SLBlob *stringsOwner = NULL;
    if (b->timeB != 0.0) {
        if (b->recordsHeap == NULL || b->recordsKey == NULL || b->recordsSize == 0) {
            return 0;
        }
        extent = b->recordsSize;
        if (120.0 < fabs(b->creationTime - b->timeB)) {
            return 0;
        }
        if (b->records == NULL || b->recordCount == 0) {
            return 0;
        }
        recordsOwner = b;
    }
    if (b->timeC != 0.0) {
        if (b->stringsHeap == NULL || b->stringsKey == NULL || b->stringsSize == 0) {
            return 0;
        }
        if (120.0 < fabs(b->creationTime - b->timeC)) {
            return 0;
        }
        if (b->strings == NULL || b->stringCount == 0) {
            return 0;
        }
        stringsOwner = b;
        extent += b->stringsSize;
    }
    uint32_t heapSize = b->heapSize;
    if (heapSize == 0 || extent + heapSize > b->payloadSize || b->magic != 0x7369616c) {
        return 0;
    }
    uint32_t nameCount = b->nameCount;
    if (nameCount == 0 || b->names == NULL) {
        return 0;
    }
    if (b->trialPrefixFlag != 0xffffffff && !(b->trialPrefixFlag < nameCount && b->trialPrefix != NULL && b->trialPrefixLength != 0)) {
        return 0;
    }
    if (b->groupCount == 0 || b->groups == NULL) {
        return 0;
    }
    uint32_t nameBytes = nameCount << 3;
    if (nameBytes > heapSize) {
        return 0;
    }
    uint32_t n = 0;
    while (n < nameCount && heapSize > 7) {
        const uint8_t *entry = b->names + n * 8;
        uint32_t length = be32(entry);
        uint32_t entryOffset = be32(entry + 4);
        if (heapSize <= entryOffset || b->heap + entryOffset == NULL || length == 0) {
            break;
        }
        nameBytes += 1 + length;
        if (heapSize < nameBytes) {
            break;
        }
        n++;
    }
    if (nameCount != n) {
        return 0;
    }
    uint32_t groupCount = b->groupCount;
    uint32_t groupBytes = groupCount << 3;
    if (groupBytes > heapSize) {
        return 0;
    }
    uint32_t g = 0;
    while (g < groupCount && heapSize > 7) {
        const uint8_t *entry = b->groups + g * 8;
        uint32_t length = be32(entry);
        uint32_t entryOffset = be32(entry + 4);
        if (heapSize <= entryOffset || b->heap + entryOffset == NULL || length == 0) {
            break;
        }
        groupBytes += 1 + length;
        if (heapSize < groupBytes) {
            break;
        }
        g++;
    }
    if (groupCount != g || b->typeCount == 0 || b->types == NULL || heapSize < 0x18) {
        return 0;
    }
    uint32_t typeBytes = 0;
    const uint8_t *type = b->types;
    uint32_t t = 0;
    do {
        uint32_t nameLength = be32(type);
        uint32_t nameOffset = be32(type + 4);
        const uint8_t *name = nameOffset < heapSize ? b->heap + nameOffset : NULL;
        uint32_t typeCode = be32(type + 8);
        uint32_t groupIndex = be32(type + 12);
        uint32_t dataLength = be32(type + 16);
        uint32_t dataOffset = be32(type + 20);
        const uint8_t *data = dataOffset < heapSize ? b->heap + dataOffset : NULL;
        if (nameLength == 0 || name == NULL) {
            return 0;
        }
        if (data == NULL) {
            if (dataLength != 0) {
                return 0;
            }
        }
        else if (dataLength == 0) {
            return 0;
        }
        if (typeCode != SL_TYPE_LOCAL_MACHINE && typeCode != SL_TYPE_LOCAL_MACHINE_TRIAL && typeCode != SL_TYPE_LIMITED_NETWORK) {
            return 0;
        }
        if (nameCount <= groupIndex) {
            return 0;
        }
        t++;
        type += 0x18;
        typeBytes += 0x19 + dataLength + nameLength;
    } while (b->typeCount != t);
    uint32_t total = nameBytes + groupBytes + typeBytes;
    if (b->trialPrefixLength != 0) {
        total += 1 + b->trialPrefixLength;
    }
    if (total > heapSize) {
        return 0;
    }
    if (recordsOwner != NULL) {
        uint32_t recordsSize = b->recordsSize;
        const uint8_t *record = b->records;
        uint32_t recordsBytes = 0;
        uint32_t r = 0;
        while (r < b->recordCount && recordsSize > 0x13) {
            uint32_t nameLength = be32(record);
            uint32_t nameOffset = be32(record + 4);
            const uint8_t *name = nameOffset < recordsSize ? b->recordsHeap + nameOffset : NULL;
            uint32_t count = be32(record + 8);
            uint32_t elementSize = be32(record + 12);
            uint32_t elementsOffset = be32(record + 16);
            const uint8_t *elements = elementsOffset < recordsSize ? b->recordsHeap + elementsOffset : NULL;
            if (name == NULL || nameLength == 0 || elements == NULL || count == 0 || elementSize != 4) {
                break;
            }
            record += 20;
            r++;
            recordsBytes += 0x15 + nameLength + count * 4;
        }
        if (b->recordCount != r || recordsSize != recordsBytes) {
            return 0;
        }
    }
    if (stringsOwner != NULL) {
        uint32_t stringsSize = b->stringsSize;
        const uint8_t *entry = b->strings;
        for (uint32_t s = 0; s < b->stringCount; s++) {
            if (stringsSize < 0x10) {
                return 0;
            }
            uint32_t length = be32(entry);
            uint32_t stringOffset = be32(entry + 4);
            const uint8_t *string = stringOffset < stringsSize ? b->stringsHeap + stringOffset : NULL;
            uint32_t count = be32(entry + 8);
            uint32_t listOffset = be32(entry + 12);
            const uint8_t *list = listOffset < stringsSize ? b->stringsHeap + listOffset : NULL;
            if (string == NULL || length == 0 || list == NULL || count == 0) {
                return 0;
            }
            entry += 0x10;
        }
    }
    return 1;
}

/* ---- the library: a parsed blob plus the format of its serial numbers ---- */

typedef void (*SLReleaseCallback)(void *context, const void *data, size_t size);

typedef struct SLLibrary {
    const uint8_t *data;
    size_t size;
    void *releaseContext;
    SLReleaseCallback release;
    uint32_t serialLength;
    uint32_t groupSize;
    uint32_t groupCount;
    SLBlob blob;
} SLLibrary;

/* FUN_002af44b */
static void SLLibraryDestroy(void *context, void *value, size_t size)
{
    (void)context;
    (void)size;
    SLLibrary *library = value;
    if (library->release != NULL) {
        library->release(library->releaseContext, library->data, library->size);
    }
    SLFree(library);
}

static int SLLibraryCreate(const void *data, size_t size, void *context, SLReleaseCallback release, uint32_t serialLength, uint32_t groupSize, uint32_t groupCount)
{
    if (data == NULL || size == 0) {
        return 8;
    }
    if (sApplicationSlot.value != NULL) {
        return 5;
    }
    SLLibrary *library = SLAlloc(sizeof *library);
    if (library == NULL) {
        return 1;
    }
    memset(library, 0, sizeof *library);
    if (SLParseBlob(data, (uint32_t)size, &library->blob) == 0) {
        SLFree(library);
        return 2;
    }
    library->data = data;
    library->size = size;
    library->releaseContext = context;
    library->release = release;
    SLSlotSet(&sLibrarySlot, library, sizeof *library, library, SLLibraryDestroy);
    library->serialLength = serialLength;
    library->groupSize = groupSize;
    library->groupCount = groupCount;
    return 0;
}

/* FUN_002adfc8: library with 4x4 serial numbers */
int SLInitializeShortSerials(const void *data, size_t size, void *context, SLReleaseCallback release)
{
    return SLLibraryCreate(data, size, context, release, 0x13, 4, 4);
}

/* FUN_002afbe2 */
int SLInitialize(const void *data, size_t size, void *context, void (*release)(void *, const void *, size_t))
{
    return SLLibraryCreate(data, size, context, release, 0x1c, 5, 5);
}

/* ---- the application ---- */

typedef struct SLApplication {
    const char *bundleIdentifier;
    const char *majorVersion;
    const char *minorVersion;
    const char *productName;
    char *serialBuffer;
    char *trialPrefix;
    char *trialSerial;
} SLApplication;

static void SLApplicationDestroy(void *context, void *value, size_t size)
{
    (void)context;
    (void)size;
    SLFree(value);
}

static SLLibrary *SLCurrentLibrary(void)
{
    return sLibrarySlot.value;
}

static SLApplication *SLCurrentApplication(void)
{
    return sApplicationSlot.value;
}

/* FUN_002af494 */
int SLSetApplicationInfo(const char *name, const char *bundleIdentifier, const char *major, const char *minor)
{
    if (name == NULL || bundleIdentifier == NULL) {
        return 8;
    }
    size_t nameLength = strlen(name);
    size_t bundleLength = strlen(bundleIdentifier);
    if (nameLength == 0 || bundleLength == 0) {
        return 8;
    }
    SLLibrary *library = SLCurrentLibrary();
    if (library == NULL) {
        return 3;
    }
    if (SLCurrentApplication() != NULL) {
        return 5;
    }
    size_t majorSize = major != NULL ? strlen(major) + 1 : 0;
    size_t minorSize = minor != NULL ? strlen(minor) + 1 : 0;
    uint32_t bufferSize = library->serialLength - library->groupSize + 2;
    size_t total = sizeof(SLApplication) + bufferSize + 0x23 + majorSize + minorSize + bundleLength + 1 + nameLength;
    uint32_t prefixSize = SLBlobTrialPrefix(&library->blob, (const uint8_t *)name, nameLength, NULL, 0);
    if (prefixSize != 0) {
        total += bufferSize + prefixSize;
    }
    SLApplication *application = SLAlloc(total);
    if (application == NULL) {
        return 1;
    }
    memset(application, 0, sizeof *application);
    char *cursor = (char *)(application + 1);
    if (major != NULL) {
        application->majorVersion = cursor;
        strcpy(cursor, major);
    }
    if (minor != NULL) {
        application->minorVersion = cursor + majorSize;
        strcpy(cursor + majorSize, minor);
    }
    cursor += majorSize + minorSize;
    application->bundleIdentifier = cursor;
    strcpy(cursor, bundleIdentifier);
    cursor += bundleLength + 1;
    application->productName = cursor;
    strcpy(cursor, name);
    cursor += nameLength + 1;
    application->serialBuffer = cursor;
    int status = 0;
    if (prefixSize != 0) {
        cursor += bufferSize;
        application->trialPrefix = cursor;
        if (SLBlobTrialPrefix(&library->blob, (const uint8_t *)name, nameLength, cursor, prefixSize) == prefixSize) {
            application->trialSerial = cursor + prefixSize;
            cursor[prefixSize] = '\0';
        }
        else {
            status = 1;
            SLFree(application);
            application = NULL;
        }
    }
    SLSlotSet(&sApplicationSlot, application, total, NULL, SLApplicationDestroy);
    return status;
}

/* ---- licenses ---- */

typedef struct SLLicenseBody {      /* the field names are the i386 offsets within the license */
    uint32_t w04;                   /* 0 */
    double d08;                     /* creation time (also the key of the encrypted data) */
    double d10;
    double d18;
    double d20;
    uint32_t w28;                   /* size of the data */
    uint32_t w2c;
    uint32_t w30;                   /* usage time flags */
    uint32_t w34;                   /* length of the registration info */
    const uint8_t *p38;             /* registration info */
    uint16_t h3c;                   /* its checksum */
    uint32_t w40;                   /* length of the serial number */
    const uint8_t *p44;             /* serial number */
    uint32_t w48;                   /* length of the type name */
    const uint8_t *p4c;             /* type name */
    uint32_t w50;                   /* length of the name */
    const uint8_t *p54;             /* name */
    uint32_t w58;                   /* length of the text */
    const uint8_t *p5c;             /* text */
    uint32_t w60;                   /* allowed copies count */
    uint32_t w64;                   /* length of the bundle identifier */
    const uint8_t *p68;             /* bundle identifier (the key of the stored license) */
    uint32_t w6c;                   /* length of the major version */
    const uint8_t *p70;
    uint32_t w74;                   /* length of the minor version */
    const uint8_t *p78;
    uint32_t w7c;
    const uint8_t *p80;
    uint32_t w84;
    const uint8_t *p88;
    uint32_t w8c;                   /* size of the list of serial numbers */
    const uint8_t *p90;             /* the list */
    uint32_t w94;                   /* flags */
    const uint8_t *p98;             /* the data the pointers point into */
} SLLicenseBody;

struct SLLicense {
    SLLicenseBody body;
    const void *data;               /* 0x9c */
    size_t dataSize;                /* 0xa0 */
    void *releaseContext;           /* 0xa4 */
    SLReleaseCallback release;      /* 0xa8 */
};

/* FUN_002afe15 */
static void SLLicenseDestroy(SLLicense *license)
{
    if (license->release != NULL) {
        license->release(license->releaseContext, license->data, license->dataSize);
    }
    SLFree(license);
}

/* FUN_002af485 */
static void SLLicenseSlotDestroy(void *context, void *value, size_t size)
{
    (void)context;
    (void)size;
    SLLicenseDestroy(value);
}

static SLLicense *SLCurrentLicense(void)
{
    return sLicenseSlot.value;
}

static size_t SLFormatTimeKey(double time, char *buffer, size_t size)
{
    snprintf(buffer, size, "%f", time);
    return strlen(buffer);
}

/* FUN_002afe5c: copies (and decrypts) data of the license */
static size_t SLLicenseRead(const SLLicenseBody *body, const uint8_t *src, size_t length, void *out)
{
    if (src < body->p98 || out == NULL || body->w28 < (size_t)(src - body->p98) + length) {
        return 0;
    }
    if ((SL_LICENSE_ENCRYPTED_FLAG & body->w94) == 0) {
        memcpy(out, src, length);
    }
    else {
        char key[512];
        size_t keyLength = SLFormatTimeKey(body->d08, key, sizeof key);
        SLXorAt(src, length, src - body->p98, (const uint8_t *)key, keyLength, out);
    }
    return length;
}

/* FUN_002afd36: compares a serial number with its obfuscated form; 0 when they match */
static int SLCompareObfuscated(const char *serial, const char *obfuscated)
{
    char c;
    for (;;) {
        c = *serial;
        if (c == '\0' || *obfuscated == '\0') {
            break;
        }
        uint8_t value = kSLSerialValue[(uint8_t)c];
        if (*obfuscated != (char)(uint8_t)(value + 0x61 + (value / 0x1a) * -0x4b)) {
            return -1;
        }
        serial++;
        obfuscated++;
    }
    return *obfuscated != c ? -1 : 0;
}

/* FUN_002b07e8: obfuscates a serial number */
static void SLObfuscateSerial(const char *serial, char *out)
{
    for (; *serial != '\0'; serial++) {
        uint8_t value = kSLSerialValue[(uint8_t)*serial];
        *out++ = kSLObfuscatedAlphabet[value < 0x1a ? value : value - 0x1a] ;
    }
    *out = '\0';
}

typedef struct SLListItem {
    uint32_t flags;
    uint32_t length;
    const uint8_t *data;
} SLListItem;

/* FUN_002aff63: 7 when the serial number is in the list */
static int SLLicenseListContains(const SLLicenseBody *body, const char *serial, const SLListItem *items, uint32_t count)
{
    if ((SL_LICENSE_ENCRYPTED_FLAG & body->w94) == 0) {
        for (uint32_t i = 0; i < count; i++, items++) {
            int result = (items->flags & 0x80) == 0 ? strcmp(serial, (const char *)items->data) : SLCompareObfuscated(serial, (const char *)items->data);
            if (result == 0) {
                return 7;
            }
        }
        return 0;
    }
    char *buffer = NULL;
    uint32_t bufferSize = 0;
    int status = 0;
    for (uint32_t i = 0; i < count; i++, items++) {
        if (bufferSize < items->length + 1) {
            if (buffer != NULL) {
                SLFree(buffer);
            }
            bufferSize = items->length + 1;
            buffer = SLAlloc(bufferSize);
            if (buffer == NULL) {
                return 1;
            }
        }
        if (SLLicenseRead(body, items->data, items->length + 1, buffer) == 0) {
            status = 1;
            break;
        }
        int result = (items->flags & 0x80) == 0 ? strcmp(serial, buffer) : SLCompareObfuscated(serial, buffer);
        if (result == 0) {
            status = 7;
            break;
        }
    }
    if (buffer != NULL) {
        SLFree(buffer);
    }
    return status;
}

/* FUN_002b00cc: the data of the current license for the environment (the name) */
static int SLLicenseCopyName(void *out, uint32_t *size)
{
    SLLicense *license = SLCurrentLicense();
    if (license != NULL && size != NULL) {
        uint32_t needed = license->body.w50 + 1;
        if (out == NULL) {
            *size = needed;
            return 0;
        }
        if (needed <= *size) {
            return SLLicenseRead(&license->body, license->body.p54, needed, out) == 0;
        }
    }
    return 1;
}

/* FUN_002b2a3d: encodes a string into a registration info string */
static uint32_t SLEncodeRegistrationInfo(const char *string, char *out, uint32_t outSize, uint16_t *checksum)
{
    size_t length = (uint16_t)strlen(string);
    if (length != 0) {
        int raw = (int)length + 0xc;
        uint32_t digits = (raw * 8 + 5U) / 6;
        if (digits != 0) {
            uint32_t total = raw + digits;
            if (out == NULL) {
                return total;
            }
            if (total <= outSize) {
                uint8_t *temp = (uint8_t *)out + digits;
                memcpy(temp, "SLUH", 4);
                memcpy(temp + 4, "1.1U", 4);
                put_be16(temp + 8, (uint16_t)length);
                put_be16(temp + 10, 0);
                memcpy(temp + 12, string, length);
                put_be16(temp + 10, SLCRC16(temp, (uint16_t)raw));
                if (SLEncodeBase64(temp, raw, out, digits) != 0) {
                    return digits;
                }
                temp[0] = 0;
                if (checksum != NULL) {
                    *checksum = SLCRC16((const uint8_t *)out, (uint16_t)digits);
                }
                return digits;
            }
        }
    }
    return 0;
}

/* FUN_002b2d06: 0 when the registration info string is valid */
static int SLValidateRegistrationInfo(const char *info, uint16_t checksum)
{
    size_t length = strlen(info);
    if (length != 0 && SLCRC16((const uint8_t *)info, (uint16_t)length) == checksum) {
        uint8_t decoded[14];
        if (SLDecodeBase64(info, 0x11, decoded, 0xe) == 0) {
            if (memcmp(decoded, "SLUH", 4) == 0) {
                uint32_t version = be32(decoded + 4);
                if (version == 1 || version == 0x312e3155) {
                    return 0;
                }
            }
        }
    }
    return -1;
}

/* FUN_002b2f32: reads the number of users out of a serial number ending with it */
static int SLParseUserCount(char *serial, uint32_t length, int *count)
{
    if (1 < length) {
        char *tail = serial + length - 2;
        if (count == NULL) {
            goto restore;
        }
        if (strncmp(tail, "_0", 2) != 0) {
            char c = tail[0];
            if ((uint8_t)(c - 0x30) < 10) {
                uint8_t digit = tail[1] - 0x30;
                if (digit < 0x33) {
                    int value = c * 0x32 + -0x960 + (int)(char)digit;
                    *count = value;
                    if (value != 0) {
                        goto restore;
                    }
                }
            }
            else {
                c = c - 0x41;
                if (-1 < c) {
                    uint32_t digit = (int)tail[1] - 0x30;
                    int value;
                    if (c == 0) {
                        if (9 < digit) {
                            return -1;
                        }
                        value = digit * 100 + 600;
                    }
                    else {
                        if (8 < (int)tail[1] - 0x31U) {
                            return -1;
                        }
                        value = digit * 1000;
                        for (; c != 1 && -1 < c - 1; c--) {
                            value *= 10;
                        }
                    }
                    *count = value;
                    goto restore;
                }
            }
        }
    }
    return -1;
restore:
    serial[length - 2] = '_';
    serial[length - 1] = '0';
    return 0;
}

/* FUN_002b01ff: the serial numbers of the list of the license */
static int SLLicenseListItems(const SLLicenseBody *body, int mode, SLListItem *items, uint32_t *count, uint32_t *bytes)
{
    if (body->p90 == NULL) {
        *count = 0;
        return 0;
    }
    if (body->w8c != 0) {
        uint8_t header[4] = { 0, 0, 0, 0 };
        if (SLLicenseRead(body, body->p90, 4, header) != 0) {
            uint32_t entries = be32(header);
            if (entries == 0) {
                return 0;
            }
            uint32_t headerSize = entries * 8 + 4;
            uint32_t remaining = body->w8c;
            if (headerSize < remaining) {
                uint32_t found = 0;
                uint32_t foundBytes = 0;
                if (items == NULL && mode == 2) {
                    foundBytes = remaining - headerSize;
                    found = entries;
                }
                else {
                    uint32_t wanted = 0x80;
                    uint32_t mask = 0x80;
                    if (mode != 0) {
                        wanted = 0;
                        if (mode != 1) {
                            mask = 0;
                        }
                    }
                    remaining -= 4;
                    const uint8_t *cursor = body->p90 + 4;
                    for (uint32_t i = 0; i < entries; i++) {
                        uint8_t entry[8];
                        if (remaining < 9 || SLLicenseRead(body, cursor, 8, entry) == 0) {
                            return 1;
                        }
                        uint32_t flags = be32(entry);
                        uint32_t length = be32(entry + 4);
                        if (remaining < length + 9) {
                            return 1;
                        }
                        if (wanted == (flags & mask)) {
                            found++;
                            foundBytes += length + 1;
                            if (items != NULL) {
                                items->data = cursor + 8;
                                items->length = length;
                                items->flags = flags;
                                items++;
                            }
                        }
                        cursor += length + 9;
                        remaining -= length + 9;
                    }
                }
                *count = found;
                if (bytes != NULL) {
                    *bytes = foundBytes;
                }
                return 0;
            }
        }
    }
    return 1;
}

/* FUN_002b0445: 7 when the serial number is in the list of the license */
static int SLLicenseCheckList(SLLicense *license, const char *serial)
{
    if (license == NULL) {
        return 1;
    }
    if (license->body.p90 != NULL && license->body.w8c != 0) {
        const SLLicenseBody *body = &license->body;
        uint32_t count = 0;
        int status = SLLicenseListItems(body, 2, NULL, &count, NULL);
        if (status != 0) {
            return status;
        }
        if (count != 0) {
            SLListItem *items = SLAlloc(count * sizeof *items);
            if (items == NULL) {
                return 1;
            }
            status = SLLicenseListItems(body, 2, items, &count, NULL);
            if (status == 0) {
                status = SLLicenseListContains(body, serial, items, count);
            }
            SLFree(items);
            return status;
        }
    }
    return 0;
}

/* FUN_002b0130: is the serial number the one the current license was registered with? */
static int SLLicenseMatchesSerial(SLLicense *license, const char *serial)
{
    uint32_t size = SLEncodeRegistrationInfo(serial, NULL, 0, NULL);
    if (size == 0) {
        return 0;
    }
    char *buffer = SLAlloc(size + license->body.w34 + 1);
    if (buffer == NULL) {
        return 0;
    }
    int result = 0;
    if (SLEncodeRegistrationInfo(serial, buffer, size, NULL) != 0) {
        if (SLLicenseRead(&license->body, license->body.p38, license->body.w34 + 1, buffer + size) != 0) {
            result = strcmp(buffer, buffer + size) == 0;
        }
    }
    SLFree(buffer);
    return result;
}

/* FUN_002b0551: appends a serial number to the list of the license (size query when out is NULL) */
static int SLLicenseAppendSerial(SLLicense *license, const char *serial, uint8_t *out, uint32_t *size)
{
    int hasOut = out != NULL;
    uint32_t listSize = license->body.w8c;
    uint32_t flags = license->body.w30 == 0 ? 0 : 0x80;
    uint32_t needed;
    if (listSize == 0 || license->body.p90 == NULL) {
        needed = license->body.w40 + 0xd;
        if (hasOut) {
            if (*size < needed) {
                return 1;
            }
            if (SLLicenseRead(&license->body, license->body.p44, license->body.w40 + 1, out + 12) == 0) {
                return 1;
            }
            if (SLCompareObfuscated(serial, (const char *)out + 12) == 0) {
                return 10;
            }
            put_be32(out, 1);
            put_be32(out + 4, flags);
            put_be32(out + 8, license->body.w40);
        }
    }
    else {
        needed = listSize + 9 + license->body.w40;
        if (hasOut) {
            if (*size < needed) {
                return 1;
            }
            uint8_t *entry = out + listSize;
            if (SLLicenseRead(&license->body, license->body.p44, license->body.w40 + 1, entry + 8) == 0) {
                return 1;
            }
            if (SLCompareObfuscated(serial, (const char *)entry + 8) == 0) {
                return 10;
            }
            if (SLLicenseRead(&license->body, license->body.p90, listSize, out) == 0) {
                return 1;
            }
            put_be32(out, be32(out) + 1);
            put_be32(entry, flags);
            put_be32(entry + 4, license->body.w40);
        }
    }
    *size = needed;
    return 0;
}

/* FUN_002b180d: reads a stored license; returns 0 when valid, -1 when not */
static uint32_t SLLicenseParse(const uint8_t *data, uint32_t size, const char *key, SLLicenseBody *out)
{
    if (size > 0x96 && be32(data + 0x8e) == 0x616c3031) {
        SLCRC32 crc;
        SLCRC32Init(&crc);
        if (SLCRC32Update(&crc, data, 0x8e) == 0x8e) {
            uint32_t payloadSize = size - 0x96;
            const uint8_t *payload = data + 0x96;
            if (payloadSize == SLCRC32Update(&crc, payload, payloadSize) && be32(data + 0x92) == ~crc.crc) {
                uint8_t h[0x8e];
                SLXorAt(data, 0x8e, 0, (const uint8_t *)key, strlen(key), h);
                SLLicenseBody b;
                memset(&b, 0, sizeof b);
                if (payloadSize > 0x8d) {
                    b.w04 = be32(h);
                    b.d08 = be_double(h + 4);
                    b.d10 = be_double(h + 0xc);
                    b.d18 = be_double(h + 0x14);
                    b.d20 = be_double(h + 0x1c);
                    b.w28 = be32(h + 0x24);
                    b.w2c = be32(h + 0x28);
                    b.w30 = be32(h + 0x2c);
                    b.w34 = be32(h + 0x30);
                    uint32_t off = be32(h + 0x34);
                    b.p38 = off < payloadSize ? payload + off : NULL;
                    b.h3c = be16(h + 0x38);
                    b.w40 = be32(h + 0x3a);
                    off = be32(h + 0x3e);
                    b.p44 = off < payloadSize ? payload + off : NULL;
                    b.w48 = be32(h + 0x42);
                    off = be32(h + 0x46);
                    b.p4c = off < payloadSize ? payload + off : NULL;
                    b.w50 = be32(h + 0x4a);
                    off = be32(h + 0x4e);
                    b.p54 = off < payloadSize ? payload + off : NULL;
                    b.w58 = be32(h + 0x52);
                    off = be32(h + 0x56);
                    b.p5c = off < payloadSize ? payload + off : NULL;
                    b.w60 = be32(h + 0x5a);
                    b.w64 = be32(h + 0x5e);
                    off = be32(h + 0x62);
                    b.p68 = off < payloadSize ? payload + off : NULL;
                    b.w6c = be32(h + 0x66);
                    off = be32(h + 0x6a);
                    b.p70 = off < payloadSize ? payload + off : NULL;
                    b.w74 = be32(h + 0x6e);
                    off = be32(h + 0x72);
                    b.p78 = off < payloadSize ? payload + off : NULL;
                    b.w7c = be32(h + 0x76);
                    off = be32(h + 0x7a);
                    b.p80 = off < payloadSize ? payload + off : NULL;
                    b.w84 = be32(h + 0x7e);
                    off = be32(h + 0x82);
                    b.p88 = off < payloadSize ? payload + off : NULL;
                    b.w8c = be32(h + 0x86);
                    off = be32(h + 0x8a);
                    b.p90 = off < payloadSize ? payload + off : NULL;
                    b.p98 = payload;
                    if (b.w04 == 0 && b.d08 != 0.0 && b.d10 != 0.0 && payload != NULL && b.w28 != 0 && b.w28 + 0x96 <= size && b.w2c == 0 && b.w60 != 0 && b.w34 != 0 && b.p38 != NULL && b.w40 != 0 && b.p44 != NULL
                        && b.w48 != 0 && b.p4c != NULL && b.w50 != 0 && b.p54 != NULL && b.w58 != 0 && b.p5c != NULL && b.w64 != 0 && b.p68 != NULL) {
                        /* the optional parts come with their length or not at all */
                        if ((b.w6c == 0) != (b.p70 == NULL) || (b.w74 == 0) != (b.p78 == NULL) || (b.w84 == 0) != (b.p88 == NULL) || (b.w7c == 0) != (b.p80 == NULL) || (b.w8c == 0) != (b.p90 == NULL)) {
                            return (uint32_t)-1;
                        }
                        if (out != NULL) {
                            *out = b;
                        }
                        return 0;
                    }
                }
            }
        }
    }
    return (uint32_t)-1;
}

/* FUN_002b0dc9: serializes a license (size query when out is NULL) */
static int SLLicenseSerialize(SLLicense *license, uint8_t *out, uint32_t *size)
{
    if (size == NULL) {
        return 1;
    }
    const SLLicenseBody *b = &license->body;
    uint32_t needed = b->w28 + 0x96;
    if (out == NULL) {
        *size = needed;
        return 0;
    }
    if (*size < needed) {
        return 1;
    }
    SLCRC32 crc;
    SLCRC32Init(&crc);
    put_be32(out, b->w04);
    put_be_double(out + 4, b->d08);
    put_be_double(out + 0xc, b->d10);
    put_be_double(out + 0x14, b->d18);
    put_be_double(out + 0x1c, b->d20);
    put_be32(out + 0x24, b->w28);
    put_be32(out + 0x28, b->w2c);
    put_be32(out + 0x2c, b->w30);
    put_be32(out + 0x30, b->w34);
    const uint8_t *base = b->p98;
#define SL_OFFSET(p) ((p) == NULL ? 0xffffffffU : (uint32_t)((p) - base))
    put_be32(out + 0x34, SL_OFFSET(b->p38));
    put_be16(out + 0x38, b->h3c);
    put_be32(out + 0x3a, b->w40);
    put_be32(out + 0x3e, SL_OFFSET(b->p44));
    put_be32(out + 0x42, b->w48);
    put_be32(out + 0x46, SL_OFFSET(b->p4c));
    put_be32(out + 0x4a, b->w50);
    put_be32(out + 0x4e, SL_OFFSET(b->p54));
    put_be32(out + 0x52, b->w58);
    put_be32(out + 0x56, SL_OFFSET(b->p5c));
    put_be32(out + 0x5a, b->w60);
    put_be32(out + 0x5e, b->w64);
    put_be32(out + 0x62, SL_OFFSET(b->p68));
    put_be32(out + 0x66, b->w6c);
    put_be32(out + 0x6a, SL_OFFSET(b->p70));
    put_be32(out + 0x6e, b->w74);
    put_be32(out + 0x72, SL_OFFSET(b->p78));
    put_be32(out + 0x76, b->w7c);
    put_be32(out + 0x7a, SL_OFFSET(b->p80));
    put_be32(out + 0x7e, b->w84);
    put_be32(out + 0x82, SL_OFFSET(b->p88));
    put_be32(out + 0x86, b->w8c);
    put_be32(out + 0x8a, SL_OFFSET(b->p90));
#undef SL_OFFSET
    uint8_t *payload = out + 0x96;
    if ((SL_LICENSE_ENCRYPTED_FLAG & b->w94) == 0) {
        SLXorReflected(out, 0x8e, b->p68, b->w64, 0, NULL);
        if (SLCRC32Update(&crc, out, 0x8e) != 0x8e) {
            return 1;
        }
        char key[512];
        size_t keyLength = SLFormatTimeKey(b->d08, key, sizeof key);
        SLXorReflected(b->p98, b->w28, (const uint8_t *)key, keyLength, 0, payload);
    }
    else {
        if (SLLicenseRead(b, b->p68, b->w64 + 1, payload) == 0) {
            return 1;
        }
        SLXorReflected(out, 0x8e, payload, b->w64, 0, NULL);
        if (SLCRC32Update(&crc, out, 0x8e) != 0x8e) {
            return 1;
        }
        memcpy(payload, b->p98, b->w28);
    }
    if (SLCRC32Update(&crc, payload, b->w28) != b->w28) {
        return 1;
    }
    memcpy(out + 0x8e, "al01", 4);
    put_be32(out + 0x92, ~crc.crc);
    return 0;
}

/* ---- the serial number information (FUN_002ae0dd) ---- */

typedef struct SLSerialInfo {
    uint32_t value;
    uint32_t nameIndex;
    uint32_t typeCode;
    uint32_t count;
    uint32_t extraLength;
    const uint8_t *extra;
    char *encoded;
    char payload[1];
} SLSerialInfo;

/* FUN_002ae0dd */
static int SLParseSerialDigits(const SLBlob *blob, const char *productName, const char *digits, SLSerialInfo **out)
{
    size_t digitCount = strlen(digits);
    if (digitCount == 0) {
        return 8;
    }
    size_t productLength = strlen(productName);
    uint32_t payloadSize = 0;
    if (SLDecodeSerialPayload(NULL, (int)digitCount, blob->magic, NULL, &payloadSize, NULL) != 0 || payloadSize <= productLength) {
        return 1;
    }
    int restLength = (int)(payloadSize - productLength);
    uint32_t encodedLength = (restLength * 8 + 5U) / 6;
    SLSerialInfo *info = SLAlloc(sizeof *info + restLength + 0x1f + payloadSize + encodedLength);
    if (info == NULL) {
        return 1;
    }
    char *payload = info->payload;
    uint32_t value = 0;
    int result = 1;
    if (SLDecodeSerialPayload(digits, (int)digitCount, blob->magic, payload, &payloadSize, &value) == 0) {
        payload[payloadSize] = '\0';
        if (strncmp(payload, productName, productLength) == 0) {
            char *rest = payload + productLength;
            char *encoded = rest + restLength + 1;
            if (SLEncodeBase64((const uint8_t *)rest, restLength, encoded, encodedLength) == 0) {
                char *encodedEnd = encoded + encodedLength;
                *encodedEnd = '\0';
                int count = -1;
                SLTypeInfo type = { 0, 0, 0, NULL };
                int found = SLBlobFindType(blob, encoded, (const uint8_t *)productName, productLength, &type) != 0;
                int check = found;
                if (!found) {
                    char *copy = encodedEnd + 1;
                    memcpy(copy, rest, restLength + 1);
                    if (SLParseUserCount(copy, restLength, &count) == 0 && count != 0 && count != -1 && SLEncodeBase64((const uint8_t *)copy, restLength, encoded, encodedLength) == 0) {
                        *encodedEnd = '\0';
                        found = SLBlobFindType(blob, encoded, (const uint8_t *)productName, productLength, &type) != 0;
                        check = found && type.value0 == SL_TYPE_LIMITED_NETWORK;
                    }
                }
                if (check && type.value0 != 0 && type.value1 < blob->nameCount) {
                    char *groupName = NULL;
                    uint32_t groupNameSize = 0;
                    uint32_t group = 0;
                    while (group < blob->groupCount) {
                        uint32_t size = SLBlobGroupString(blob, (const uint8_t *)productName, productLength, group, NULL, 0);
                        if (size == 0) {
                            break;
                        }
                        if (groupNameSize < size) {
                            if (groupName != NULL) {
                                SLFree(groupName);
                            }
                            groupName = SLAlloc(size);
                            groupNameSize = size;
                            if (groupName == NULL) {
                                break;
                            }
                        }
                        if (SLBlobGroupString(blob, (const uint8_t *)productName, productLength, group, groupName, groupNameSize) == 0 || SLLicenseTypeCode(groupName) == type.value0) {
                            break;
                        }
                        group++;
                    }
                    if (groupName != NULL) {
                        SLFree(groupName);
                    }
                    if (blob->groupCount != group) {
                        result = 7;
                        if (!SLBlobRecordHasValue(blob, (const uint8_t *)productName, productLength, encoded, value)) {
                            if (out != NULL) {
                                info->value = value;
                                info->typeCode = type.value0;
                                info->nameIndex = type.value1;
                                info->count = count == -1 ? 1 : count;
                                info->extraLength = type.value2;
                                info->extra = type.data;
                                info->encoded = encoded;
                                memmove(payload, rest, restLength + 1);
                                *out = info;
                                return 0;
                            }
                            result = 0;
                        }
                        SLFree(info);
                        return result;
                    }
                }
            }
        }
    }
    SLFree(info);
    return 1;
}

typedef struct SLVerifyContext {
    SLApplication *application;
    const SLBlob *blob;
    int flag;
} SLVerifyContext;

typedef struct SLVerifier {
    SLVerifyContext *context;
    double time0;
    double time1;
    double time2;
} SLVerifier;

/* FUN_002ae6f6 */
static int SLVerifierHasValue(SLVerifyContext *context, const char *name, uint32_t value)
{
    if (name == NULL) {
        return 1;
    }
    const char *productName = context->application->productName;
    return SLBlobRecordHasValue(context->blob, (const uint8_t *)productName, strlen(productName), name, value);
}

/* FUN_002ae744 */
static int SLVerifierMatches(SLVerifyContext *context, uint32_t typeCode, const char *name, const char *text)
{
    if (name == NULL || typeCode == 0) {
        return 0;
    }
    SLApplication *application = context->application;
    const SLBlob *blob = context->blob;
    size_t productLength = strlen(application->productName);
    size_t textLength = strlen(text);
    uint32_t size = (uint32_t)textLength + 1;
    uint32_t secondary = 0xffffffff;
    uint32_t index;
    SLTypeInfo type = { 0, 0, 0, NULL };
    int lookup = 1;
    if (typeCode == SL_TYPE_LOCAL_MACHINE) {
        if (context->flag != 0) {
            secondary = blob->trialPrefixFlag;
        }
    }
    else if (typeCode == SL_TYPE_LOCAL_MACHINE_TRIAL) {
        if (strcmp(name, application->trialPrefix) != 0) {
            return 0;
        }
        index = blob->trialPrefixFlag;
        secondary = 0xffffffff;
        lookup = 0;
    }
    if (lookup) {
        if (SLBlobFindType(blob, name, (const uint8_t *)application->productName, productLength, &type) == 0 || typeCode != type.value0) {
            return 0;
        }
        index = type.value1;
        if (secondary == type.value1) {
            index = secondary;
            secondary = 0xffffffff;
        }
    }
    if (index == 0xffffffff) {
        return 0;
    }
    char *buffer = SLAlloc(size);
    if (buffer == NULL) {
        return 0;
    }
    int ok = size == SLBlobNameString(blob, (const uint8_t *)application->productName, productLength, index, buffer, size);
    if (secondary != 0xffffffff && !ok) {
        ok = size == SLBlobNameString(blob, (const uint8_t *)application->productName, productLength, secondary, buffer, size);
    }
    int result = 0;
    if (ok) {
        if (buffer[textLength] == '\0') {
            result = strcmp(buffer, text) == 0;
        }
    }
    SLFree(buffer);
    return result;
}

/* FUN_002b2568: creates a license out of the data of a host file */
static int SLLicenseCreateFromHostData(const char *bundleIdentifier, const char *minor, const char *major, const char *trialPrefix, SLVerifier *verifier, const void *data, size_t dataSize, void *releaseContext, SLReleaseCallback release, SLLicense **out)
{
    SLLicense *license = SLAlloc(sizeof *license);
    if (license == NULL) {
        return 1;
    }
    memset(license, 0, sizeof *license);
    char *scratch = NULL;
    int result;
    SLLicenseBody *b = &license->body;
    if (SLLicenseParse(data, (uint32_t)dataSize, bundleIdentifier, b) != 0) {
        result = 1;
        goto fail;
    }
    b->w94 |= SL_LICENSE_ENCRYPTED_FLAG;
    if ((verifier->time0 < b->d10) || (verifier->time1 < b->d18) || (verifier->time2 < b->d20)) {
        result = 1;
        goto fail;
    }
    uint32_t maxLength = b->w50;
    if (maxLength < b->w48) {
        maxLength = b->w48;
    }
    if (maxLength < b->w58) {
        maxLength = b->w58;
    }
    if (maxLength < b->w34) {
        maxLength = b->w34;
    }
    if (maxLength < b->w64) {
        maxLength = b->w64;
    }
    if (maxLength < b->w74) {
        maxLength = b->w74;
    }
    if (maxLength < b->w6c) {
        maxLength = b->w6c;
    }
    uint32_t encodedLength = (b->w58 * 8 + 5) / 6;
    scratch = SLAlloc(maxLength + 2 + encodedLength + 0x10);
    result = 1;
    if (scratch != NULL
        && SLLicenseRead(b, b->p68, b->w64 + 1, scratch) != 0
        && strcmp(scratch, bundleIdentifier) == 0
        && (b->p78 == NULL || (SLLicenseRead(b, b->p78, b->w74 + 1, scratch) != 0 && strcmp(scratch, minor) == 0))
        && (b->p70 == NULL || (SLLicenseRead(b, b->p70, b->w6c + 1, scratch) != 0 && strcmp(scratch, major) == 0))
        && SLLicenseRead(b, b->p38, b->w34 + 1, scratch) != 0
        && SLValidateRegistrationInfo(scratch, b->h3c) == 0
        && SLLicenseRead(b, b->p4c, b->w48 + 1, scratch) != 0) {
        uint32_t typeCode = SLLicenseTypeCode(scratch);
        if (typeCode != 0) {
            const uint8_t *nameSource = NULL;
            uint32_t nameLength = 0;
            int proceed = 0;
            if (b->w30 == 0) {
                if (trialPrefix != NULL && typeCode == SL_TYPE_LOCAL_MACHINE_TRIAL && SLLicenseRead(b, b->p5c, b->w58 + 1, scratch) != 0 && strcmp(trialPrefix, scratch) == 0) {
                    nameLength = b->w50;
                    nameSource = b->p54;
                    proceed = 1;
                }
            }
            else if (typeCode != SL_TYPE_LOCAL_MACHINE_TRIAL && b->w60 != 0 && (typeCode != SL_TYPE_LOCAL_MACHINE || b->w60 < 2) && SLLicenseRead(b, b->p5c, b->w58 + 1, scratch) != 0 && scratch[b->w58] == '\0') {
                int users = 0;
                if (typeCode != SL_TYPE_LIMITED_NETWORK || (SLParseUserCount(scratch, b->w58, &users) == 0 && b->w60 == (uint32_t)users)) {
                    char *encoded = scratch + b->w58 + 1;
                    if (SLEncodeBase64((const uint8_t *)scratch, b->w58, encoded, encodedLength) == 0) {
                        scratch[encodedLength + b->w58 + 1] = '\0';
                        if (SLVerifierHasValue(verifier->context, encoded, b->w30)) {
                            result = 7;
                            goto fail;
                        }
                        memmove(scratch, encoded, encodedLength + 1);
                        nameLength = b->w50;
                        nameSource = b->p54;
                        proceed = 1;
                    }
                }
            }
            if (proceed && SLLicenseRead(b, nameSource, nameLength + 1, scratch + encodedLength + 1) != 0
                && SLVerifierMatches(verifier->context, typeCode, scratch, scratch + encodedLength + 1)) {
                if (out != NULL) {
                    license->data = data;
                    license->dataSize = dataSize;
                    license->releaseContext = releaseContext;
                    license->release = release;
                    *out = license;
                    SLFree(scratch);
                    return 0;
                }
                result = 0;
                goto fail;
            }
        }
    }
    result = 1;
fail:
    SLFree(license);
    if (scratch != NULL) {
        SLFree(scratch);
    }
    return result;
}

/* ---- building a license out of a serial number ---- */

typedef struct SLBuildContext {
    SLLibrary *library;
    SLApplication *application;
    SLSerialInfo *info;
    uint32_t nameIndex;
    uint32_t extraLength;
    const uint8_t *extra;
} SLBuildContext;

typedef struct SLBuildParams {
    SLBuildContext *context;
    double time0;
    double time1;
    double time2;
    uint32_t typeNameLength;
    uint32_t nameLength;
    uint32_t extraLength;
    uint32_t valueLength;
    size_t (*typeName)(SLBuildContext *, char *, size_t);     /* FUN_002af0cb */
    size_t (*name)(SLBuildContext *, char *, size_t);         /* FUN_002af0e0 */
    size_t (*extra)(SLBuildContext *, char *, size_t);        /* FUN_002af12f */
    size_t (*value)(SLBuildContext *, char *, size_t);        /* FUN_002af1a1 */
} SLBuildParams;

static size_t SLBuildTypeName(SLBuildContext *context, char *buffer, size_t size)
{
    return SLLicenseTypeName(context->info->typeCode, buffer, size);
}

static size_t SLBuildName(SLBuildContext *context, char *buffer, size_t size)
{
    const char *key = context->application->productName;
    return SLBlobNameString(&context->library->blob, (const uint8_t *)key, strlen(key), context->nameIndex, buffer, (uint32_t)size);
}

static size_t SLBuildExtra(SLBuildContext *context, char *buffer, size_t size)
{
    const uint8_t *data = context->extra;
    uint32_t length = context->extraLength;
    if (data == NULL || length == 0 || size < length) {
        return 0;
    }
    const char *key = context->application->productName;
    SLXorAt(data, length, data - context->library->blob.stringsKey, (const uint8_t *)key, strlen(key), (uint8_t *)buffer);
    return length;
}

static size_t SLBuildValue(SLBuildContext *context, char *buffer, size_t size)
{
    const uint8_t *data = context->info->extra;
    uint32_t length = context->info->extraLength;
    if (data == NULL || length == 0 || size < length) {
        return 0;
    }
    const char *key = context->application->productName;
    SLXorAt(data, length, data - context->library->blob.heapKey, (const uint8_t *)key, strlen(key), (uint8_t *)buffer);
    return context->info->extraLength;
}

/* FUN_002b08aa */
static int SLLicenseBuild(const char *digits, const char *text, uint32_t flagValue, uint32_t count, const char *bundleIdentifier, const char *minor, const char *major, SLBuildParams *params, SLLicense **out)
{
    size_t digitsLength = strlen(digits);
    uint32_t infoSize;
    if (digitsLength == 0 || (infoSize = SLEncodeRegistrationInfo(digits, NULL, 0, NULL)) == 0 || params->nameLength == 0 || params->typeNameLength == 0) {
        return 1;
    }
    SLLicense *current = SLCurrentLicense();
    uint32_t listSize = 0;
    if (current != NULL) {
        int status = SLLicenseAppendSerial(current, digits, NULL, &listSize);
        if (status != 0) {
            return status;
        }
    }
    size_t bundleLength = strlen(bundleIdentifier);
    size_t textLength = strlen(text);
    size_t majorLength = 0;
    size_t minorLength = 0;
    size_t total = bundleLength + 3 + digitsLength + infoSize + params->typeNameLength + params->nameLength + textLength;
    if (major != NULL) {
        majorLength = strlen(major);
        total += 1 + majorLength;
    }
    if (minor != NULL) {
        minorLength = strlen(minor);
        total += 1 + minorLength;
    }
    uint32_t dataSize = (uint32_t)(total + params->extraLength + params->valueLength + listSize);
    SLLicense *license = SLAlloc(sizeof *license + dataSize);
    *out = license;
    if (license == NULL) {
        return 1;
    }
    memset(license, 0, sizeof *license);
    uint8_t *base = (uint8_t *)(license + 1);
    SLLicenseBody b;
    memset(&b, 0, sizeof b);
    b.d08 = CFAbsoluteTimeGetCurrent();
    b.d10 = params->time0;
    b.d18 = params->time1;
    b.d20 = params->time2;
    b.w28 = dataSize;
    b.w30 = flagValue;
    b.w60 = count;
    b.p98 = base;
    int status = 1;
    uint16_t checksum = 0;
    uint32_t infoLength = SLEncodeRegistrationInfo(digits, (char *)base, infoSize, &checksum);
    if (infoLength != 0) {
        b.w34 = infoLength;
        b.p38 = base;
        b.h3c = checksum;
        char *cursor = (char *)base + 1 + infoLength;
        uint32_t unused = (infoSize - infoLength) - 1;
        b.w28 = dataSize - unused;
        if (flagValue == 0) {
            strcpy(cursor, digits);
        }
        else {
            SLObfuscateSerial(digits, cursor);
        }
        b.w40 = (uint32_t)digitsLength;
        b.p44 = (const uint8_t *)cursor;
        char *next = cursor + digitsLength + 1;
        size_t length = params->typeName(params->context, next, params->typeNameLength);
        if (length == params->typeNameLength) {
            b.w48 = (uint32_t)length - 1;
            b.p4c = (const uint8_t *)next;
            cursor = next + length;
            length = params->name(params->context, cursor, params->nameLength);
            if (length == params->nameLength) {
                b.w50 = (uint32_t)length - 1;
                b.p54 = (const uint8_t *)cursor;
                next = cursor + length;
                strcpy(next, text);
                b.w58 = (uint32_t)textLength;
                b.p5c = (const uint8_t *)next;
                cursor = next + textLength + 1;
                strcpy(cursor, bundleIdentifier);
                b.w64 = (uint32_t)bundleLength;
                b.p68 = (const uint8_t *)cursor;
                next = cursor + bundleLength + 1;
                if (major != NULL) {
                    strcpy(next, major);
                    b.w6c = (uint32_t)majorLength;
                    b.p70 = (const uint8_t *)next;
                    next += majorLength + 1;
                }
                if (minor != NULL) {
                    strcpy(next, minor);
                    b.w74 = (uint32_t)minorLength;
                    b.p78 = (const uint8_t *)next;
                    next += minorLength + 1;
                }
                int failed = 0;
                if (params->extraLength != 0 && params->extra != NULL) {
                    length = params->extra(params->context, next, params->extraLength);
                    if (length != params->extraLength) {
                        failed = 1;
                    }
                    else {
                        b.w7c = (uint32_t)length;
                        b.p80 = (const uint8_t *)next;
                        next += length;
                    }
                }
                if (!failed && params->valueLength != 0 && params->value != NULL) {
                    length = params->value(params->context, next, params->valueLength);
                    if (length != params->valueLength) {
                        failed = 1;
                    }
                    else {
                        b.w84 = (uint32_t)length;
                        b.p88 = (const uint8_t *)next;
                        next += length;
                    }
                }
                if (!failed) {
                    b.w8c = listSize;
                    if (listSize != 0) {
                        status = SLLicenseAppendSerial(current, digits, (uint8_t *)next, &listSize);
                        b.p90 = (const uint8_t *)next;
                    }
                    else {
                        status = 0;
                    }
                    if (status == 0) {
                        license->body = b;
                        license->data = base;
                        license->dataSize = dataSize - unused;
                        license->releaseContext = NULL;
                        license->release = NULL;
                        return 0;
                    }
                }
            }
        }
    }
    SLFree(license);
    *out = NULL;
    return status;
}

/* FUN_002af6e3: true when the trial serial number can not be built */
static int SLApplicationPrepareTrialSerial(SLApplication *application, SLLibrary *library)
{
    if (application->trialPrefix[0] != '\0') {
        if (application->trialSerial[0] == '\0') {
            return SLBuildTrialSerial(library->serialLength, library->groupSize, library->groupCount, application->productName, application->trialPrefix, application->trialSerial, (library->serialLength - library->groupCount) + 2) != 0;
        }
        return 0;
    }
    return 1;
}

/* FUN_002ae526: validates the serial number and decodes it */
static int SLParseSerial(const char *serial, SLLibrary *library, SLApplication *application, char *digits, uint32_t digitsSize, SLSerialInfo **out)
{
    size_t length = strlen(serial);
    if (length != library->serialLength || SLUnformatSerial((int)length, library->groupSize, library->groupCount, serial, digits, digitsSize) != 0) {
        return 1;
    }
    SLLicense *current = SLCurrentLicense();
    if (current != NULL) {
        if (SLLicenseMatchesSerial(current, digits)) {
            return 10;
        }
        if (SLLicenseCheckList(current, digits) == 7) {
            return 7;
        }
    }
    const char *trialSerial = application->trialSerial;
    if (trialSerial != NULL && *trialSerial != '\0' && strcmp(trialSerial, digits) == 0) {
        if (out != NULL) {
            SLSerialInfo *info = SLAlloc(sizeof *info + library->blob.trialPrefixLength + 0x1e);
            *out = info;
            if (info != NULL) {
                info->value = 0;
                info->typeCode = SL_TYPE_LOCAL_MACHINE_TRIAL;
                info->nameIndex = library->blob.trialPrefixFlag;
                info->count = 0xffffffff;
                info->extraLength = 0;
                info->extra = NULL;
                info->payload[0] = '\0';
                info->encoded = info->payload + 1;
                SLBlobTrialPrefix(&library->blob, (const uint8_t *)application->productName, strlen(application->productName), info->encoded, library->blob.trialPrefixLength + 1);
            }
        }
        return 0;
    }
    return SLParseSerialDigits(&library->blob, application->productName, digits, out);
}

/* FUN_002af840 */
static int SLLicenseCreate(const char *serial, SLLicense **out)
{
    if (serial == NULL || *serial == '\0' || out == NULL) {
        return 8;
    }
    SLLibrary *library = SLCurrentLibrary();
    if (library == NULL) {
        return 3;
    }
    SLApplication *application = SLCurrentApplication();
    if (application == NULL) {
        return 4;
    }
    SLSerialInfo *info = NULL;
    int status = 1;
    SLBuildContext context = { library, application, NULL, 0xffffffff, 0, NULL };
    if (application->trialPrefix == NULL || !SLApplicationPrepareTrialSerial(application, library)) {
        status = SLParseSerial(serial, library, application, application->serialBuffer, library->serialLength - library->groupCount + 2, &info);
        if (status == 0) {
            if (info == NULL) {
                return 0;
            }
            context.info = info;
            const char *text;
            if (info->typeCode == SL_TYPE_LOCAL_MACHINE_TRIAL || info->value == 0) {
                context.nameIndex = library->blob.trialPrefixFlag;
                text = application->trialPrefix;
            }
            else {
                context.nameIndex = info->nameIndex;
                text = info->payload;
            }
            size_t productLength = strlen(application->productName);
            SLBuildParams params;
            memset(&params, 0, sizeof params);
            params.context = &context;
            params.time0 = library->blob.creationTime;
            params.time1 = library->blob.timeB;
            params.time2 = library->blob.timeC;
            params.typeName = SLBuildTypeName;
            params.name = SLBuildName;
            params.extra = SLBuildExtra;
            params.value = SLBuildValue;
            params.typeNameLength = (uint32_t)SLLicenseTypeName(info->typeCode, NULL, 0);
            if (params.typeNameLength == 0 || (params.nameLength = SLBlobNameString(&library->blob, (const uint8_t *)application->productName, productLength, context.nameIndex, NULL, 0)) == 0) {
                status = 1;
            }
            else {
                const uint8_t *found = NULL;
                uint32_t foundLength = 0;
                params.extraLength = SLBlobFindString(&library->blob, info->encoded, info->value, (const uint8_t *)application->productName, productLength, &found, &foundLength);
                context.extra = found;
                context.extraLength = foundLength;
                params.valueLength = info->extraLength;
                status = SLLicenseBuild(application->serialBuffer, text, info->value, info->count, application->bundleIdentifier, application->minorVersion, application->majorVersion, &params, out);
            }
        }
    }
    if (info != NULL) {
        SLFree(info);
    }
    return status;
}

/* ---- host files and preferences holding the stored license ---- */

#define SL_HOST_PREFERENCES_ID ".com.mackiev.licensor.host"

/* FUN_002b30a0: a path of the data of the license, relative to the application support folder or the application */
static int SLResolvePath(const char *path, const char *installPath, char *out, size_t outSize)
{
    static const char *const macros[2] = { "$(LOCAL_APP_SUPPORT)", "$(APP_INSTALL_PATH)" };
    for (int i = 0; i < 2; i++) {
        size_t macroLength = strlen(macros[i]);
        if (strlen(path) >= macroLength && strncmp(path, macros[i], macroLength) == 0) {
            const char *rest = path + macroLength + 1;
            if (i == 0) {
                snprintf(out, outSize, "/Library/Application Support/%s", rest);
                return 0;
            }
            if (installPath == NULL || strlen(path) <= macroLength) {
                return 1;
            }
            snprintf(out, outSize, "%s/%s", installPath, rest);
            return 0;
        }
    }
    snprintf(out, outSize, "%s", path);
    return 0;
}

/* FUN_002b31ee: the content of a file */
static void *SLReadFile(const char *path, const char *installPath, size_t *sizeOut)
{
    char resolved[1025];
    if (SLResolvePath(path, installPath, resolved, sizeof resolved) != 0) {
        return NULL;
    }
    int fd = open(resolved, O_RDONLY);
    void *buffer = NULL;
    if (fd >= 0) {
        struct stat st;
        if (fstat(fd, &st) == 0) {
            off_t length = lseek(fd, 0, SEEK_END);
            if (length > 0 && lseek(fd, 0, SEEK_SET) == 0) {
                buffer = SLAlloc((size_t)length);
                if (buffer != NULL) {
                    if ((off_t)read(fd, buffer, (size_t)length) == length) {
                        if (sizeOut != NULL) {
                            *sizeOut = (size_t)length;
                        }
                    }
                    else {
                        SLFree(buffer);
                        buffer = NULL;
                    }
                }
            }
        }
        close(fd);
    }
    return buffer;
}

/* FUN_002b3376: makes the directory and the directories above it */
static int SLMakeDirectory(const char *path)
{
    struct stat st;
    if (stat(path, &st) == 0) {
        return 0;
    }
    if (errno == EACCES) {
        return 9;
    }
    char parent[1025];
    snprintf(parent, sizeof parent, "%s", path);
    char *slash = strrchr(parent, '/');
    if (slash == NULL || slash == parent) {
        return 1;
    }
    *slash = '\0';
    int status = SLMakeDirectory(parent);
    if (status != 0) {
        return status;
    }
    if (mkdir(path, 0775) != 0) {
        if (errno == EACCES) {
            return 9;
        }
        if (errno != EEXIST) {
            return 1;
        }
    }
    if (chmod(path, 0775) != 0) {
        return 9;
    }
    return 0;
}

/* FUN_002b3475 and FUN_002b3513: removes a file */
static int SLRemoveFile(const char *path, const char *installPath)
{
    char resolved[1025];
    if (SLResolvePath(path, installPath, resolved, sizeof resolved) != 0) {
        return 1;
    }
    if (unlink(resolved) == 0) {
        return 0;
    }
    if (errno == ENOENT || errno == ENOTDIR) {
        return 0;
    }
    if (errno == EACCES || errno == EPERM) {
        return 9;
    }
    return 1;
}

/* FUN_002b3fb6 and FUN_002b4207: writes a file, making its directory when needed */
static int SLWriteFile(const char *path, const char *installPath, const void *data, size_t size)
{
    char resolved[1025];
    if (SLResolvePath(path, installPath, resolved, sizeof resolved) != 0) {
        return 1;
    }
    FILE *file = fopen(resolved, "wb");
    if (file != NULL) {
        size_t written = fwrite(data, 1, size, file);
        fclose(file);
        if (written == size) {
            if (chmod(resolved, 0775) != 0) {
                return errno == EACCES ? 9 : (errno == EPERM ? 1 : 9);
            }
            return 0;
        }
    }
    else if (errno == EACCES) {
        return 9;
    }
    struct stat st;
    if (stat(resolved, &st) == 0 || errno == EACCES) {
        return 9;
    }
    char directory[1025];
    snprintf(directory, sizeof directory, "%s", resolved);
    char *slash = strrchr(directory, '/');
    if (slash == NULL || slash == directory) {
        return 1;
    }
    *slash = '\0';
    int status = SLMakeDirectory(directory);
    if (status != 0) {
        return status;
    }
    file = fopen(resolved, "wb");
    if (file == NULL) {
        return errno == EACCES ? 9 : 1;
    }
    size_t written = fwrite(data, 1, size, file);
    fclose(file);
    if (size != written) {
        return 1;
    }
    if (chmod(resolved, 0775) != 0) {
        return errno == EPERM ? 1 : 9;
    }
    return 0;
}

/* FUN_002b3558: the stored form of license data: a property list with a header and the data */
static CFDataRef SLCreateStoredLicense(uint32_t version, const void *data, uint32_t size)
{
    uint8_t header[12];
    put_be32(header, 0x534c4c64);
    put_be32(header + 4, version);
    put_be32(header + 8, size);
    CFDataRef headerData = CFDataCreateWithBytesNoCopy(NULL, header, sizeof header, kCFAllocatorNull);
    if (headerData == NULL) {
        return NULL;
    }
    CFDataRef licenseData = CFDataCreateWithBytesNoCopy(NULL, data, size, kCFAllocatorNull);
    if (licenseData == NULL) {
        CFRelease(headerData);
        return NULL;
    }
    const void *keys[2] = { CFSTR("SLUtilityLicenseDataHeader"), CFSTR("SLUtilityLicenseData") };
    const void *values[2] = { headerData, licenseData };
    CFDictionaryRef dictionary = CFDictionaryCreate(NULL, keys, values, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFRelease(headerData);
    CFRelease(licenseData);
    if (dictionary == NULL) {
        return NULL;
    }
    CFDataRef result = CFPropertyListCreateData(NULL, dictionary, kCFPropertyListBinaryFormat_v1_0, 0, NULL);
    CFRelease(dictionary);
    return result;
}

/* FUN_002b36f4: reads the stored form; returns 0 on success */
static int SLParseStoredLicense(CFTypeRef value, uint32_t *versionOut, CFDataRef *dataOut)
{
    if (CFGetTypeID(value) != CFDataGetTypeID()) {
        return 1;
    }
    CFPropertyListRef plist = CFPropertyListCreateWithData(NULL, value, kCFPropertyListImmutable, NULL, NULL);
    if (plist == NULL) {
        return 1;
    }
    int status = 1;
    if (CFGetTypeID(plist) == CFDictionaryGetTypeID()) {
        CFDataRef header = CFDictionaryGetValue(plist, CFSTR("SLUtilityLicenseDataHeader"));
        if (header != NULL && CFGetTypeID(header) == CFDataGetTypeID() && CFDataGetLength(header) == 12) {
            const uint8_t *bytes = CFDataGetBytePtr(header);
            uint32_t version = be32(bytes + 4);
            uint32_t size = be32(bytes + 8);
            if (be32(bytes) == 0x534c4c64) {
                CFDataRef data = CFDictionaryGetValue(plist, CFSTR("SLUtilityLicenseData"));
                if (data != NULL && CFGetTypeID(data) == CFDataGetTypeID() && size == (uint32_t)CFDataGetLength(data)) {
                    if (versionOut != NULL) {
                        *versionOut = version;
                    }
                    if (dataOut != NULL) {
                        *dataOut = CFRetain(data);
                    }
                    status = 0;
                }
            }
        }
    }
    CFRelease(plist);
    return status;
}

static CFStringRef SLCreatePreferencesKey(const char *minor, const char *major, const char *bundleIdentifier)
{
    const char *first = minor != NULL ? minor : "SLGeneric";
    const char *second = major != NULL ? major : "SLGeneric";
    return CFStringCreateWithFormat(NULL, NULL, CFSTR("%s-%s-%s"), first, second, bundleIdentifier);
}

/* FUN_002b3915: the license data stored in the preferences */
static void *SLReadPreferences(const char *applicationId, uint32_t version, const char *bundleIdentifier, const char *minor, const char *major, size_t *sizeOut)
{
    void *result = NULL;
    CFStringRef application = CFStringCreateWithCString(NULL, applicationId, kCFStringEncodingUTF8);
    if (application == NULL) {
        return NULL;
    }
    CFStringRef versionKey = CFStringCreateWithFormat(NULL, NULL, CFSTR("%u"), version);
    if (versionKey != NULL) {
        CFArrayRef keys = CFArrayCreate(NULL, (const void **)&versionKey, 1, &kCFTypeArrayCallBacks);
        if (keys != NULL) {
            CFPreferencesSynchronize(application, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
            CFDictionaryRef values = CFPreferencesCopyMultiple(keys, application, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
            CFRelease(keys);
            if (values != NULL) {
                CFDictionaryRef entries = CFDictionaryGetValue(values, versionKey);
                if (entries != NULL && CFGetTypeID(entries) == CFDictionaryGetTypeID()) {
                    CFStringRef key = SLCreatePreferencesKey(minor, major, bundleIdentifier);
                    if (key != NULL) {
                        CFTypeRef stored = CFDictionaryGetValue(entries, key);
                        CFRelease(key);
                        if (stored != NULL) {
                            uint32_t storedVersion = 0;
                            CFDataRef data = NULL;
                            if (SLParseStoredLicense(stored, &storedVersion, &data) == 0) {
                                if (storedVersion == version) {
                                    size_t length = CFDataGetLength(data);
                                    result = SLAlloc(length);
                                    if (result != NULL) {
                                        memcpy(result, CFDataGetBytePtr(data), length);
                                        if (sizeOut != NULL) {
                                            *sizeOut = length;
                                        }
                                    }
                                }
                                CFRelease(data);
                            }
                        }
                    }
                }
                CFRelease(values);
            }
        }
        CFRelease(versionKey);
    }
    CFRelease(application);
    return result;
}

/* FUN_002b3bc7: stores license data in the preferences (or removes it when data is NULL); true on failure */
static int SLWritePreferences(const char *applicationId, uint32_t version, const char *bundleIdentifier, const char *minor, const char *major, const void *data, uint32_t size)
{
    int failed = 1;
    CFStringRef application = CFStringCreateWithCString(NULL, applicationId, kCFStringEncodingUTF8);
    CFStringRef versionKey = NULL;
    CFMutableDictionaryRef entries = NULL;
    if (application != NULL && (versionKey = CFStringCreateWithFormat(NULL, NULL, CFSTR("%u"), version)) != NULL) {
        CFArrayRef keys = CFArrayCreate(NULL, (const void **)&versionKey, 1, &kCFTypeArrayCallBacks);
        if (keys != NULL) {
            CFPreferencesSynchronize(application, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
            CFDictionaryRef values = CFPreferencesCopyMultiple(keys, application, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
            CFRelease(keys);
            if (values != NULL) {
                int removing = size == 0;
                CFTypeRef existing = CFDictionaryGetValue(values, versionKey);
                int ok = 1;
                if (existing == NULL) {
                    if (!removing) {
                        entries = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                    }
                    else {
                        ok = 0;
                    }
                }
                else if (CFGetTypeID(existing) == CFDictionaryGetTypeID()) {
                    entries = CFDictionaryCreateMutableCopy(NULL, 0, existing);
                }
                else if (!removing) {
                    entries = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                }
                if (ok && entries != NULL) {
                    CFStringRef key = SLCreatePreferencesKey(minor, major, bundleIdentifier);
                    if (key != NULL) {
                        uint32_t storedVersion = 0;
                        CFTypeRef stored = CFDictionaryGetValue(entries, key);
                        if (stored == NULL || SLParseStoredLicense(stored, &storedVersion, NULL) != 0 || storedVersion <= version) {
                            if (removing) {
                                CFDictionaryRemoveValue(entries, key);
                                failed = 0;
                            }
                            else {
                                CFDataRef storedData = SLCreateStoredLicense(version, data, size);
                                if (storedData != NULL) {
                                    CFDictionarySetValue(entries, key, storedData);
                                    CFRelease(storedData);
                                    failed = 0;
                                }
                            }
                        }
                        CFRelease(key);
                    }
                }
                else if (!ok) {
                    failed = 0;
                }
                CFRelease(values);
                if (entries != NULL) {
                    if (!failed) {
                        CFDictionaryRef update = CFDictionaryCreate(NULL, (const void **)&versionKey, (const void **)&entries, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                        if (update != NULL) {
                            CFPreferencesSetMultiple(update, NULL, application, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
                            failed = !CFPreferencesSynchronize(application, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
                            CFRelease(update);
                        }
                    }
                    CFRelease(entries);
                }
            }
        }
    }
    if (versionKey != NULL) {
        CFRelease(versionKey);
    }
    if (application != NULL) {
        CFRelease(application);
    }
    return failed;
}

/* ---- loading and storing ---- */

static void SLFreeCallback(void *context, const void *data, size_t size)   /* FUN_002af43b */
{
    (void)context;
    (void)size;
    SLFree((void *)data);
}

/* FUN_002ae93c */
static int SLLicenseFromHostData(void *data, size_t size, void *context, SLReleaseCallback release, SLApplication *application, SLBlob *blob, int flag)
{
    if (data == NULL || size == 0) {
        return 1;
    }
    SLVerifyContext verifyContext = { application, blob, flag };
    SLVerifier verifier = { &verifyContext, blob->creationTime, blob->timeB, blob->timeC };
    SLLicense *license = NULL;
    int status = SLLicenseCreateFromHostData(application->bundleIdentifier, application->minorVersion, application->majorVersion, application->trialPrefix, &verifier, data, size, context, release, &license);
    if (license != NULL) {
        SLSlotSet(&sLicenseSlot, license, 0, NULL, SLLicenseSlotDestroy);
    }
    return status;
}

/* FUN_002aea49 */
int SLLicenseLoadHostFile(const char *bundlePath)
{
    if (bundlePath == NULL || *bundlePath == '\0') {
        return 8;
    }
    SLLibrary *library = SLCurrentLibrary();
    if (library == NULL) {
        return 3;
    }
    SLApplication *application = SLCurrentApplication();
    if (application == NULL) {
        return 4;
    }
    SLBlob *blob = &library->blob;
    const uint8_t *key = (const uint8_t *)application->productName;
    size_t keyLength = strlen(application->productName);
    size_t size = 0;
    void *data = NULL;
    char *name = NULL;
    uint32_t nameSize = 0;
    for (uint32_t index = 0;; index++) {
        uint32_t length = SLBlobNameString(blob, key, keyLength, index, NULL, 0);
        if (length == 0) {
            break;
        }
        if (nameSize < length) {
            if (name != NULL) {
                SLFree(name);
            }
            name = SLAlloc(length);
            nameSize = length;
            if (name == NULL) {
                data = NULL;
                goto searchPreferences;
            }
        }
        if (SLBlobNameString(blob, key, keyLength, index, name, nameSize) != length) {
            break;
        }
        data = SLReadFile(name, bundlePath, &size);
        if (data != NULL) {
            break;
        }
    }
    if (name != NULL) {
        SLFree(name);
    }
searchPreferences:;
    int status = 1;
    for (int fromPreferences = 0;; fromPreferences = 1) {
        if (data != NULL) {
            status = SLLicenseFromHostData(data, size, NULL, SLFreeCallback, application, blob, fromPreferences);
            if (status == 0) {
                return 0;
            }
            SLFree(data);
            data = NULL;
        }
        if (fromPreferences) {
            break;
        }
        data = SLReadPreferences(SL_HOST_PREFERENCES_ID, 6, application->bundleIdentifier, application->minorVersion, application->majorVersion, &size);
        if (data == NULL) {
            data = SLReadPreferences(SL_HOST_PREFERENCES_ID, 4, application->bundleIdentifier, application->minorVersion, application->majorVersion, &size);
        }
    }
    return status;
}

/* FUN_002aedc2: removes the files of the license in the places that are not the one in use */
static void SLRemoveOtherHostFiles(SLLibrary *library, const char *bundlePath, const char *keepName)
{
    const SLBlob *blob = &library->blob;
    SLApplication *application = SLCurrentApplication();
    const uint8_t *key = (const uint8_t *)application->productName;
    size_t keyLength = strlen(application->productName);
    char *name = NULL;
    uint32_t nameSize = 0;
    for (uint32_t index = 0; index < blob->nameCount; index++) {
        uint32_t length = SLBlobNameString(blob, key, keyLength, index, NULL, 0);
        if (length == 0) {
            break;
        }
        if (nameSize < length) {
            if (name != NULL) {
                SLFree(name);
            }
            name = SLAlloc(length);
            nameSize = length;
            if (name == NULL) {
                return;
            }
        }
        if (SLBlobNameString(blob, key, keyLength, index, name, nameSize) != nameSize) {
            break;
        }
        if (strcmp(keepName, name) != 0 && SLRemoveFile(name, bundlePath) != 0) {
            break;
        }
    }
    if (name != NULL) {
        SLFree(name);
    }
}

/* FUN_002aeef1 */
int SLLicenseStoreToHostFile(const char *bundlePath)
{
    if (bundlePath == NULL) {
        return 8;
    }
    SLLibrary *library = SLCurrentLibrary();
    if (library == NULL) {
        return 3;
    }
    SLApplication *application = SLCurrentApplication();
    if (application == NULL) {
        return 4;
    }
    SLLicense *license = SLCurrentLicense();
    if (license == NULL) {
        return 1;
    }
    uint32_t licenseSize = 0;
    if (SLLicenseSerialize(license, NULL, &licenseSize) != 0 || licenseSize == 0) {
        return 1;
    }
    uint32_t nameSize = 0;
    if (SLLicenseCopyName(NULL, &nameSize) != 0) {
        return 1;
    }
    uint8_t *buffer = SLAlloc(licenseSize + nameSize);
    if (buffer == NULL) {
        return 1;
    }
    int status = 1;
    if (SLLicenseCopyName(buffer, &nameSize) == 0) {
        uint8_t *serialized = buffer + nameSize;
        if (SLLicenseSerialize(license, serialized, &licenseSize) == 0) {
            status = SLWriteFile((const char *)buffer, bundlePath, serialized, licenseSize);
            if (status == 0) {
                SLRemoveOtherHostFiles(library, bundlePath, (const char *)buffer);
                SLWritePreferences(SL_HOST_PREFERENCES_ID, 6, application->bundleIdentifier, application->minorVersion, application->majorVersion, serialized, licenseSize);
            }
        }
    }
    SLFree(buffer);
    return status;
}

/* FUN_002aed55 */
int SLLicenseCopyData(SLLicense *license, void *buffer, uint32_t *size)
{
    if (size == NULL) {
        return 8;
    }
    if (SLCurrentLibrary() == NULL) {
        return 3;
    }
    if (SLCurrentApplication() == NULL) {
        return 4;
    }
    if (license == NULL && (license = SLCurrentLicense()) == NULL) {
        return 1;
    }
    return SLLicenseSerialize(license, buffer, size);
}

/* FUN_002b429d: the environment of the host file: the names of the places and which one is in use */
static int SLCopyEnvironmentData(SLLibrary *library, const char *hostId, uint32_t version, const char *productName, const char *bundleIdentifier, const char *currentName, uint8_t *out, uint32_t *size)
{
    if (size == NULL) {
        return 8;
    }
    const uint8_t *key = (const uint8_t *)productName;
    size_t keyLength = strlen(productName);
    size_t hostLength = strlen(hostId);
    uint32_t total = (uint32_t)hostLength + 0xd;
    const SLBlob *blob = &library->blob;
    for (uint32_t i = 0; i < blob->nameCount; i++) {
        total += SLBlobNameString(blob, key, keyLength, i, NULL, 0);
    }
    if (total == 0) {
        return 1;
    }
    if (out != NULL) {
        if (*size < total) {
            return 1;
        }
        uint8_t *names = out + 12;
        strcpy((char *)names, hostId);
        uint32_t selected = 0xffffffff;
        uint32_t used = (uint32_t)hostLength + 1;
        char *cursor = (char *)names + used;
        for (uint32_t i = 0; i < blob->nameCount; i++) {
            uint32_t length = SLBlobNameString(blob, key, keyLength, i, cursor, total - used);
            if (length == 0) {
                return 1;
            }
            if (selected == 0xffffffff && currentName != NULL && strcmp(cursor, currentName) == 0) {
                selected = i;
            }
            used += length;
            cursor += length;
        }
        put_be32(out, version);
        put_be32(out + 4, blob->nameCount);
        put_be32(out + 8, selected);
        SLXorReflected(names, used, (const uint8_t *)bundleIdentifier, strlen(bundleIdentifier), 0, NULL);
    }
    *size = total;
    return 0;
}

/* FUN_002af392 */
int SLLicenseCopyEnvironment(void *buffer, uint32_t *size)
{
    if (size == NULL) {
        return 8;
    }
    SLLibrary *library = SLCurrentLibrary();
    if (library == NULL) {
        return 3;
    }
    SLApplication *application = SLCurrentApplication();
    if (application == NULL) {
        return 4;
    }
    SLLicense *license = SLCurrentLicense();
    const char *currentName = license != NULL ? (const char *)license->body.p54 : NULL;
    return SLCopyEnvironmentData(library, SL_HOST_PREFERENCES_ID, 6, application->productName, application->bundleIdentifier, currentName, buffer, size);
}

/* FUN_002b4ecb: encodes the identifier of the machine */
static int SLEncodeIdentifier(const uint8_t *bytes, uint8_t length, const char *first, const char *second, const char *third, const char *fourth, void *out, uint32_t *size)
{
    if (size == NULL || first == NULL || second == NULL) {
        return 3;
    }
    size_t firstLength = strlen(first);
    size_t secondLength = strlen(second);
    if (firstLength == 0 || secondLength == 0) {
        return 3;
    }
    size_t thirdLength = third != NULL ? strlen(third) : 0;
    size_t fourthLength = fourth != NULL ? strlen(fourth) : 0;
    uint32_t n = length;
    int keyLength = (int)(firstLength + secondLength + thirdLength + fourthLength);
    uint32_t padded = n + 2;
    padded = padded + ((keyLength - 3U) / padded) * padded;
    int rawLength = padded + 9;
    uint32_t digits = (rawLength * 8 + 5U) / 6;
    uint32_t needed = digits + 1;
    if (out == NULL) {
        *size = needed;
        return 0;
    }
    if (*size < needed) {
        return 6;
    }
    uint8_t *raw = malloc(keyLength + rawLength);
    if (raw == NULL) {
        return 1;
    }
    memcpy(raw, "UD.I", 4);
    raw[4] = 0;
    raw[5] = 1;
    raw[6] = length;
    uint8_t *region = raw + 7;
    put_be16(region, SLCRC16(bytes, length));
    uint8_t *cursor = region + 2;
    int remaining = padded - 2;
    do {
        remaining -= n;
        memcpy(cursor, bytes, n);
        cursor += n;
    } while (remaining > 0);
    uint8_t *keyArea = cursor + 2;
    uint8_t *keyCursor = keyArea;
    const char *parts[4] = { first, second, third, fourth };
    size_t lengths[4] = { firstLength, secondLength, thirdLength, fourthLength };
    for (int i = 0; i < 4; i++) {
        memcpy(keyCursor, parts[i], lengths[i]);
        keyCursor += lengths[i];
    }
    SLXorReflected(region, padded, keyArea, keyLength, 0, NULL);
    put_be16(cursor, SLCRC16(region, (uint16_t)padded));
    int status = SLEncodeBase64(raw, rawLength, out, digits);
    if (status == 0) {
        ((char *)out)[needed - 1] = '\0';
    }
    free(raw);
    return status != 0;
}

/* FUN_002af2e3 */
int SLEncodeHardwareIdentifier(const void *bytes, uint32_t length, void *buffer, uint32_t *size)
{
    if (size == NULL) {
        return 8;
    }
    SLLibrary *library = SLCurrentLibrary();
    if (library == NULL) {
        return 3;
    }
    SLApplication *application = SLCurrentApplication();
    if (application == NULL) {
        return 4;
    }
    uint32_t outSize = *size;
    int status = SLEncodeIdentifier(bytes, (uint8_t)length, application->productName, application->bundleIdentifier, NULL, NULL, buffer, &outSize);
    if (status == 0) {
        *size = outSize;
        return 0;
    }
    return status != 3 ? 1 : 8;
}

/* FUN_002af75b */
int SLLicenseCopyPendingSerial(void *buffer, uint32_t *size)
{
    if (size == NULL) {
        return 8;
    }
    SLLibrary *library = SLCurrentLibrary();
    if (library == NULL) {
        return 3;
    }
    SLApplication *application = SLCurrentApplication();
    if (application == NULL) {
        return 4;
    }
    uint32_t needed = library->serialLength + 1;
    if (buffer == NULL) {
        *size = needed;
        return 0;
    }
    if (application->trialPrefix != NULL && needed <= *size) {
        int status = SLApplicationPrepareTrialSerial(application, library);
        if (status != 0) {
            return status;
        }
        if (SLFormatSerial(library->serialLength, library->groupSize, library->groupCount, application->trialSerial, buffer, *size) == 0) {
            *size = needed;
            return 0;
        }
    }
    return 1;
}

/* FUN_002afb5d */
int SLLicenseHasPendingSerial(void)
{
    SLLibrary *library = SLCurrentLibrary();
    if (library == NULL) {
        return 3;
    }
    SLApplication *application = SLCurrentApplication();
    if (application == NULL) {
        return 4;
    }
    if (application->trialPrefix == NULL) {
        return 1;
    }
    int status = SLApplicationPrepareTrialSerial(application, library);
    if (status == 0) {
        SLLicense *license = SLCurrentLicense();
        if (license != NULL) {
            status = SLLicenseCheckList(license, application->trialSerial);
        }
    }
    return status;
}

/* FUN_002afb3b */
int SLLicenseCreateFromSerial(const char *serial, SLLicense **license)
{
    return SLLicenseCreate(serial, license);
}

/* FUN_002af216 */
int SLLicenseRelease(SLLicense *license)
{
    if (license != NULL && license != SLCurrentLicense()) {
        SLLicenseDestroy(license);
    }
    return 0;
}

/* FUN_002af240 */
int SLLicenseActivate(SLLicense *license)
{
    if (license == NULL) {
        return 8;
    }
    if (SLCurrentLibrary() == NULL) {
        return 3;
    }
    if (SLCurrentApplication() == NULL) {
        return 4;
    }
    SLSlotSet(&sLicenseSlot, license, 0, NULL, SLLicenseSlotDestroy);
    return 0;
}

/* ---- information about a license (NULL stands for the current license) ---- */

static SLLicense *SLLicenseOrCurrent(SLLicense *license)
{
    return license != NULL ? license : SLCurrentLicense();
}

/* FUN_002b48a2 */
int SLLicenseGetType(SLLicense *license)
{
    license = SLLicenseOrCurrent(license);
    if (license == NULL || license->body.w48 == 0) {
        return 0;
    }
    char *name = SLAlloc(license->body.w48 + 1);
    if (name == NULL) {
        return 0;
    }
    int type = 0;
    if (SLLicenseRead(&license->body, license->body.p4c, license->body.w48 + 1, name) != 0) {
        if (strcmp(name, "LOCAL_MACHINE") == 0) {
            type = 1;
        }
        else if (strcmp(name, "LIMITED_NETWORK") == 0) {
            type = 2;
        }
        else if (strcmp(name, "LOCAL_MACHINE_TRIAL") == 0) {
            type = 3;
        }
    }
    SLFree(name);
    return type;
}

/* FUN_002b49d8 */
double SLLicenseGetExpirationTime(SLLicense *license)
{
    license = SLLicenseOrCurrent(license);
    return license != NULL ? license->body.d08 : 0.0;
}

/* FUN_002b49fc */
int SLLicenseCopyRegistrationInfo(SLLicense *license, void *buffer, uint32_t *size)
{
    if (size == NULL) {
        return 8;
    }
    license = SLLicenseOrCurrent(license);
    if (license != NULL && license->body.w34 != 0) {
        uint32_t needed = license->body.w34 + 1;
        if (buffer == NULL) {
            *size = needed;
            return 0;
        }
        if (needed <= *size && SLLicenseRead(&license->body, license->body.p38, needed, buffer) != 0) {
            return SLValidateRegistrationInfo(buffer, license->body.h3c) != 0;
        }
    }
    return 1;
}

/* FUN_002b4a8b */
int SLLicenseGetUsageTimeFlags(SLLicense *license)
{
    license = SLLicenseOrCurrent(license);
    return license != NULL ? (int)license->body.w30 : -1;
}

/* FUN_002b4aad */
int SLLicenseGetAllowedCount(SLLicense *license)
{
    license = SLLicenseOrCurrent(license);
    return license != NULL ? (int)license->body.w60 : 0;
}

/* FUN_002b4acc */
int SLLicenseCopyNetworkIdentifier(SLLicense *license, void *buffer, uint32_t *size)
{
    if (size == NULL) {
        return 8;
    }
    license = SLLicenseOrCurrent(license);
    if (license != NULL && license->body.w40 != 0) {
        uint32_t needed = license->body.w40 + 1;
        if (buffer == NULL) {
            *size = needed;
            return 0;
        }
        if (needed <= *size) {
            return SLLicenseRead(&license->body, license->body.p44, needed, buffer) == 0;
        }
    }
    return 1;
}

/* FUN_002b4cc8 and FUN_002b4d44 */
int SLLicenseCopyUserData(SLLicense *license, int which, void *buffer, uint32_t *size)
{
    if (size == NULL) {
        return 8;
    }
    license = SLLicenseOrCurrent(license);
    if (license != NULL) {
        const uint8_t *data = which == 0 ? license->body.p80 : license->body.p88;
        uint32_t length = which == 0 ? license->body.w7c : license->body.w84;
        if (data == NULL) {
            *size = 0;
            return 0;
        }
        if (length != 0) {
            if (buffer == NULL) {
                *size = length;
                return 0;
            }
            if (length <= *size) {
                return SLLicenseRead(&license->body, data, length, buffer) == 0;
            }
        }
    }
    return 1;
}

/* FUN_002b4b3d: the identifiers that block the license: a count followed by that many C strings pointers, then the strings */
int SLLicenseCopyBlockingIdentifiers(SLLicense *license, void *buffer, uint32_t *size)
{
    if (size == NULL) {
        return 8;
    }
    license = SLLicenseOrCurrent(license);
    if (license == NULL) {
        return 1;
    }
    const SLLicenseBody *body = &license->body;
    uint32_t count = 0;
    uint32_t bytes = 0;
    int status = SLLicenseListItems(body, 0, NULL, &count, &bytes);
    if (status != 0) {
        return status;
    }
    if (count == 0) {
        *size = 0;
        return 0;
    }
    if (bytes == 0) {
        return 1;
    }
    uint32_t needed = (uint32_t)(sizeof(uintptr_t) * (count + 1)) + bytes;
    if (buffer == NULL) {
        *size = needed;
        return 0;
    }
    if (needed > *size) {
        return 1;
    }
    SLListItem *items = SLAlloc(count * sizeof *items);
    if (items == NULL) {
        return 1;
    }
    uint32_t found = count;
    status = SLLicenseListItems(body, 0, items, &found, NULL);
    if (status == 0) {
        uintptr_t *table = buffer;
        char *strings = (char *)(table + count + 1);
        uint32_t i;
        for (i = 0; i < found; i++) {
            if (SLLicenseRead(body, items[i].data, items[i].length + 1, strings) == 0) {
                break;
            }
            table[i + 1] = (uintptr_t)strings;
            strings += items[i].length + 1;
        }
        if (i == found) {
            table[0] = found;
            status = 0;
        }
        else {
            status = 1;
        }
    }
    SLFree(items);
    return status;
}
