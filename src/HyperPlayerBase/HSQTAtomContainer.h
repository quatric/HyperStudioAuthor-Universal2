#import "HyperPlayerBasePrefix.h"

// QuickTime atom containers without QuickTime: the same big-endian layout
// (a 12-byte header, then a 'sean' root atom whose children are atoms of
// size/type/ID/child count, leaves carrying their data) kept in a Handle,
// so stored effect descriptions and .qfx files read and write unchanged.
// An atom is its byte offset in the handle; 0 names the root.

typedef SInt32 HSQTAtom;
typedef Handle HSQTAtomContainer;

enum {
    kHSQTParentAtomIsContainer = 0,
    kHSQTAtomNotFoundErr = -2101
};

OSErr HSQTNewAtomContainer(HSQTAtomContainer *aContainer);
OSErr HSQTDisposeAtomContainer(HSQTAtomContainer aContainer);
// An ID of 0 matches any ID. aIndex, when given, receives the 1-based index
// among the children of that type.
HSQTAtom HSQTFindChildByID(HSQTAtomContainer aContainer, HSQTAtom aParent, OSType aType, SInt32 aID, short *aIndex);
// Appends the child (aIndex is ignored: new atoms always go last). A nil
// aData with a non-zero size makes an atom of zeroed data.
OSErr HSQTInsertChild(HSQTAtomContainer aContainer, HSQTAtom aParent, OSType aType, SInt32 aID, short aIndex, SInt32 aSize, const void *aData, HSQTAtom *aNewAtom);
OSErr HSQTRemoveAtom(HSQTAtomContainer aContainer, HSQTAtom aAtom);
// Copies the atom's data: with aSizeOrLessOK the data may be shorter than
// aSize, otherwise it must hold at least aSize bytes.
OSErr HSQTCopyAtomDataToPtr(HSQTAtomContainer aContainer, HSQTAtom aAtom, Boolean aSizeOrLessOK, SInt32 aSize, void *aPtr, SInt32 *aActualSize);
// The leaf data of an atom (inside the handle, so valid until it changes).
const UInt8 *HSQTGetAtomDataPtr(HSQTAtomContainer aContainer, HSQTAtom aAtom, SInt32 *aSize);
