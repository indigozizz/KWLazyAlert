//
//  UIViewController+KWLazyPresent.m
//  KWLazyPresent
//
//  Created by Kawa on 2020/10/13.
//

/*
 [Show AlertController in NEW Windows]
 Reference: https://stackoverflow.com/questions/26554894/how-to-present-uialertcontroller-when-not-in-a-view-controller
*/

#import "UIViewController+KWLazyPresent.h"

#import "KWWindow.h"
#import <objc/runtime.h>

#define KWWindowLevelNotification (UIWindowLevelAlert - 1)

@interface UIViewController (Private)

@property (nonatomic, strong) KWWindow *alertWindow;

@end

@implementation UIViewController (Private)

@dynamic alertWindow;

- (void)setAlertWindow:(UIWindow *)alertWindow {
    objc_setAssociatedObject(self, @selector(alertWindow), alertWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)alertWindow {
    return objc_getAssociatedObject(self, @selector(alertWindow));
}

@end

@implementation UIViewController (KWLazyPresent)

//MARK: - Lazy Present
- (void)lazyPresent {
    [self lazyPresentAnimated:YES];
}

- (void)lazyPresentAnimated:(BOOL)animated {
    [self lazyPresentAnimated:animated
                   completion:nil];
}

- (void)lazyPresentAnimated:(BOOL)animated
                 completion:(void (^ __nullable)(void))completion {
    [self lazyPresentAnimated:animated
                    alertType:KWLazyAlertDefault
                   completion:completion];
}

- (void)lazyPresentAnimated:(BOOL)animated
                  alertType:(KWLazyAlertType)alertType
                 completion:(void (^ __nullable)(void))completion {
    
    self.alertWindow = [[KWWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
    self.alertWindow.rootViewController = [[UIViewController alloc] init];

    id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
    // Applications that does not load with UIMainStoryboardFile might not have a window property:
    if ([delegate respondsToSelector:@selector(window)]) {
        // We inherit the main window's tintColor
        self.alertWindow.tintColor = delegate.window.tintColor;
    }

    switch (alertType) {
        case KWLazyAlertInAppNotification:
            self.alertWindow.windowLevel = KWWindowLevelNotification;
            break;
            
        default:
            self.alertWindow.windowLevel = [self kwGetSuitableWindowLevel];
            break;
    }

    [self.alertWindow makeKeyAndVisible];
    [self.alertWindow.rootViewController presentViewController:self animated:animated completion:completion];
}

//MARK: - Lazy Dismiss
- (void)lazyDismiss {
    [self lazyDismissAnimated:YES completion:nil];
}

- (void)lazyDismissAnimated:(BOOL)animated {
    [self lazyDismissAnimated:animated completion:nil];
}

- (void)lazyDismissAnimated:(BOOL)animated
                 completion:(void (^ __nullable)(void))completion {
    
    [self dismissViewControllerAnimated:animated completion:^{
        self.alertWindow.hidden = YES;
        self.alertWindow = nil;
        
        if (completion != nil) {
            completion();
        }
    }];
}

//TODO: Create a InApp Notification Template with KWPassthroughView


//MARK: - kw Utils
- (long)kwGetSuitableWindowLevel {
    // Default Max Window Level
    long windowLevel = KWWindowLevelNotification - 1;
    
    for (UIWindow *window in [[UIApplication sharedApplication].windows reverseObjectEnumerator])
    {
        // Max Window Level should not over  UIWindowLevelAlert
        if (window.windowLevel >= KWWindowLevelNotification - 1) {
            continue;
        }
        windowLevel = window.windowLevel + 1;
    }
    
    return windowLevel;
}

@end
