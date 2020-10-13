#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "KWLazyPresent.h"
#import "KWPassthroughView.h"
#import "KWWindow.h"
#import "UIViewController+KWLazyPresent.h"

FOUNDATION_EXPORT double KWLazyPresentVersionNumber;
FOUNDATION_EXPORT const unsigned char KWLazyPresentVersionString[];

