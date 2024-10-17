#import <CoreGraphics/CoreGraphics.h>
typedef int CGSConnection;

extern CGSConnection CGSMainConnectionID(void);
extern CGError CGSActuateDeviceWithPattern(const CGSConnection cid, int arg1, int arg2, int arg3);
