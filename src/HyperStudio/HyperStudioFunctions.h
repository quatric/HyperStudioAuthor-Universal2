// Plain C functions of the original binary shared between classes.
#import <Foundation/Foundation.h>

// FUN_0019893f: the rect a layout rule moves aRect to.
NSRect HSLayoutRuleTranslateRect(id aRule, NSRect aRect);
// FUN_00198b95: whether two layout rules affect the same sides with equal values.
BOOL HSLayoutRuleIsEqual(id aRule, id anotherRule);
// FUN_001988a8: hash of a layout rule: its first affected side in the top byte, its value below.
NSUInteger HSLayoutRuleHash(id aRule);
