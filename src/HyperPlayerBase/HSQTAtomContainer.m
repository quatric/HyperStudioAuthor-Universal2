#import "HSQTAtomContainer.h"

#define HSQT_HEADER_SIZE 12
#define HSQT_ATOM_HEADER_SIZE 20
#define HSQT_MAX_DEPTH 32

// Atom header: size, type, ID (4 bytes each), 2 reserved, child count (2), 4 reserved.

static UInt32 HSQTRead32(const UInt8 *aBytes)
{
    return ((UInt32)aBytes[0] << 24) | ((UInt32)aBytes[1] << 16) | ((UInt32)aBytes[2] << 8) | aBytes[3];
}

static void HSQTWrite32(UInt8 *aBytes, UInt32 aValue)
{
    aBytes[0] = aValue >> 24;
    aBytes[1] = aValue >> 16;
    aBytes[2] = aValue >> 8;
    aBytes[3] = aValue;
}

static UInt16 HSQTRead16(const UInt8 *aBytes)
{
    return (UInt16)((aBytes[0] << 8) | aBytes[1]);
}

static void HSQTWrite16(UInt8 *aBytes, UInt16 aValue)
{
    aBytes[0] = aValue >> 8;
    aBytes[1] = aValue;
}

static Boolean HSQTIsValidAtom(HSQTAtomContainer aContainer, SInt32 aOffset)
{
    SInt32 length = GetHandleSize(aContainer);
    if (aOffset < HSQT_HEADER_SIZE || aOffset + HSQT_ATOM_HEADER_SIZE > length)
        return false;
    UInt32 size = HSQTRead32((UInt8 *)*aContainer + aOffset);
    return size >= HSQT_ATOM_HEADER_SIZE && aOffset + (SInt64)size <= length;
}

static SInt32 HSQTResolve(HSQTAtomContainer aContainer, HSQTAtom aAtom)
{
    return aAtom == kHSQTParentAtomIsContainer ? HSQT_HEADER_SIZE : aAtom;
}

// Collects the chain of atoms from the root down to aTarget (inclusive).
static Boolean HSQTFindPath(HSQTAtomContainer aContainer, SInt32 aFrom, SInt32 aTarget, SInt32 *aPath, int *aDepth)
{
    if (*aDepth >= HSQT_MAX_DEPTH || !HSQTIsValidAtom(aContainer, aFrom))
        return false;
    aPath[(*aDepth)++] = aFrom;
    if (aFrom == aTarget)
        return true;
    const UInt8 *atom = (UInt8 *)*aContainer + aFrom;
    if (HSQTRead16(atom + 14) != 0) {
        SInt32 end = aFrom + HSQTRead32(atom);
        SInt32 child = aFrom + HSQT_ATOM_HEADER_SIZE;
        while (child < end && HSQTIsValidAtom(aContainer, child)) {
            if (aTarget >= child && aTarget < child + (SInt32)HSQTRead32((UInt8 *)*aContainer + child))
                return HSQTFindPath(aContainer, child, aTarget, aPath, aDepth);
            child += HSQTRead32((UInt8 *)*aContainer + child);
        }
    }
    (*aDepth)--;
    return false;
}

OSErr HSQTNewAtomContainer(HSQTAtomContainer *aContainer)
{
    Handle handle = NewHandleClear(HSQT_HEADER_SIZE + HSQT_ATOM_HEADER_SIZE);
    if (handle == NULL) {
        *aContainer = NULL;
        return memFullErr;
    }
    UInt8 *root = (UInt8 *)*handle + HSQT_HEADER_SIZE;
    HSQTWrite32(root, HSQT_ATOM_HEADER_SIZE);
    HSQTWrite32(root + 4, 'sean');
    HSQTWrite32(root + 8, 1);
    *aContainer = handle;
    return noErr;
}

OSErr HSQTDisposeAtomContainer(HSQTAtomContainer aContainer)
{
    if (aContainer != NULL)
        DisposeHandle(aContainer);
    return noErr;
}

HSQTAtom HSQTFindChildByID(HSQTAtomContainer aContainer, HSQTAtom aParent, OSType aType, SInt32 aID, short *aIndex)
{
    if (aContainer == NULL)
        return 0;
    SInt32 parent = HSQTResolve(aContainer, aParent);
    if (!HSQTIsValidAtom(aContainer, parent))
        return 0;
    const UInt8 *bytes = (UInt8 *)*aContainer;
    if (HSQTRead16(bytes + parent + 14) == 0)
        return 0;
    SInt32 end = parent + HSQTRead32(bytes + parent);
    SInt32 child = parent + HSQT_ATOM_HEADER_SIZE;
    short index = 0;
    while (child < end && HSQTIsValidAtom(aContainer, child)) {
        if (HSQTRead32(bytes + child + 4) == aType) {
            index++;
            if (aID == 0 || (SInt32)HSQTRead32(bytes + child + 8) == aID) {
                if (aIndex)
                    *aIndex = index;
                return child;
            }
        }
        child += HSQTRead32(bytes + child);
    }
    return 0;
}

static void HSQTAdjustSizes(HSQTAtomContainer aContainer, SInt32 *aPath, int aDepth, SInt32 aDelta)
{
    UInt8 *bytes = (UInt8 *)*aContainer;
    for (int i = 0; i < aDepth; i++)
        HSQTWrite32(bytes + aPath[i], HSQTRead32(bytes + aPath[i]) + aDelta);
}

OSErr HSQTInsertChild(HSQTAtomContainer aContainer, HSQTAtom aParent, OSType aType, SInt32 aID, short aIndex, SInt32 aSize, const void *aData, HSQTAtom *aNewAtom)
{
    if (aNewAtom)
        *aNewAtom = 0;
    if (aContainer == NULL || aSize < 0)
        return paramErr;
    SInt32 parent = HSQTResolve(aContainer, aParent);
    SInt32 path[HSQT_MAX_DEPTH];
    int depth = 0;
    if (!HSQTFindPath(aContainer, HSQT_HEADER_SIZE, parent, path, &depth))
        return kHSQTAtomNotFoundErr;
    UInt8 *bytes = (UInt8 *)*aContainer;
    // A leaf that holds data can't take children.
    if (HSQTRead16(bytes + parent + 14) == 0 && HSQTRead32(bytes + parent) != HSQT_ATOM_HEADER_SIZE)
        return paramErr;
    SInt32 insertAt = parent + HSQTRead32(bytes + parent);
    SInt32 atomSize = HSQT_ATOM_HEADER_SIZE + aSize;
    SInt32 length = GetHandleSize(aContainer);
    SetHandleSize(aContainer, length + atomSize);
    if (MemError() != noErr)
        return MemError();
    bytes = (UInt8 *)*aContainer;
    memmove(bytes + insertAt + atomSize, bytes + insertAt, length - insertAt);
    UInt8 *atom = bytes + insertAt;
    memset(atom, 0, HSQT_ATOM_HEADER_SIZE);
    HSQTWrite32(atom, atomSize);
    HSQTWrite32(atom + 4, aType);
    HSQTWrite32(atom + 8, aID);
    if (aData)
        memcpy(atom + HSQT_ATOM_HEADER_SIZE, aData, aSize);
    else
        memset(atom + HSQT_ATOM_HEADER_SIZE, 0, aSize);
    HSQTAdjustSizes(aContainer, path, depth, atomSize);
    HSQTWrite16(bytes + parent + 14, HSQTRead16(bytes + parent + 14) + 1);
    if (aNewAtom)
        *aNewAtom = insertAt;
    return noErr;
}

OSErr HSQTRemoveAtom(HSQTAtomContainer aContainer, HSQTAtom aAtom)
{
    if (aContainer == NULL || aAtom <= HSQT_HEADER_SIZE)
        return paramErr;
    SInt32 path[HSQT_MAX_DEPTH];
    int depth = 0;
    if (!HSQTFindPath(aContainer, HSQT_HEADER_SIZE, aAtom, path, &depth) || depth < 2)
        return kHSQTAtomNotFoundErr;
    UInt8 *bytes = (UInt8 *)*aContainer;
    SInt32 atomSize = HSQTRead32(bytes + aAtom);
    SInt32 length = GetHandleSize(aContainer);
    SInt32 parent = path[depth - 2];
    HSQTAdjustSizes(aContainer, path, depth - 1, -atomSize);
    HSQTWrite16(bytes + parent + 14, HSQTRead16(bytes + parent + 14) - 1);
    memmove(bytes + aAtom, bytes + aAtom + atomSize, length - aAtom - atomSize);
    SetHandleSize(aContainer, length - atomSize);
    return noErr;
}

const UInt8 *HSQTGetAtomDataPtr(HSQTAtomContainer aContainer, HSQTAtom aAtom, SInt32 *aSize)
{
    if (aContainer == NULL || aAtom == 0 || !HSQTIsValidAtom(aContainer, aAtom))
        return NULL;
    const UInt8 *atom = (UInt8 *)*aContainer + aAtom;
    if (HSQTRead16(atom + 14) != 0)
        return NULL;
    if (aSize)
        *aSize = HSQTRead32(atom) - HSQT_ATOM_HEADER_SIZE;
    return atom + HSQT_ATOM_HEADER_SIZE;
}

OSErr HSQTCopyAtomDataToPtr(HSQTAtomContainer aContainer, HSQTAtom aAtom, Boolean aSizeOrLessOK, SInt32 aSize, void *aPtr, SInt32 *aActualSize)
{
    SInt32 size = 0;
    const UInt8 *data = HSQTGetAtomDataPtr(aContainer, aAtom, &size);
    if (data == NULL)
        return kHSQTAtomNotFoundErr;
    if (!aSizeOrLessOK && size < aSize)
        return paramErr;
    SInt32 count = MIN(size, aSize);
    memcpy(aPtr, data, count);
    if (aActualSize)
        *aActualSize = count;
    return noErr;
}
