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

@property (nonatomic, strong) KWWindow *kwPresentWindow;
@property (nonatomic, strong) UIViewController *kwLinkedViewController;

@end

@implementation UIViewController (Private)

@dynamic kwPresentWindow;
@dynamic kwLinkedViewController;


- (void)setKwPresentWindow:(UIWindow *)window {
    objc_setAssociatedObject(self, @selector(kwPresentWindow), window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)kwPresentWindow {
    return objc_getAssociatedObject(self, @selector(kwPresentWindow));
}

- (void)setKwLinkedViewController:(UIViewController *)viewController {
    objc_setAssociatedObject(self, @selector(kwLinkedViewController), viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)kwLinkedViewController {
    return objc_getAssociatedObject(self, @selector(kwLinkedViewController));
}

@end

//MARK: -

@interface UIViewController (PrivateLifeCycle)

@end

@implementation UIViewController (PrivateLifeCycle)

+ (void)load {
    [super load];
    [self swizzle];
}

+ (void)swizzle {
    
    Method origin_viewWillAppear_method = class_getInstanceMethod([self class], @selector(viewWillAppear:));
    Method swizzle_viewWillAppear_method = class_getInstanceMethod([self class], @selector(swizzle_viewWillAppear:));
    
    Method origin_viewDidAppear_method = class_getInstanceMethod([self class], @selector(viewDidAppear:));
    Method swizzle_viewDidAppear_method = class_getInstanceMethod([self class], @selector(swizzle_viewDidAppear:));
    
    Method origin_viewWillDisappear_method = class_getInstanceMethod([self class], @selector(viewWillDisappear:));
    Method swizzle_viewWillDisappear_method = class_getInstanceMethod([self class], @selector(swizzle_viewWillDisappear:));
    
    Method origin_viewDidDisappear_method = class_getInstanceMethod([self class], @selector(viewDidDisappear:));
    Method swizzle_viewDidDisappear_method = class_getInstanceMethod([self class], @selector(swizzle_viewDidDisappear:));
    
    method_exchangeImplementations(origin_viewWillAppear_method, swizzle_viewWillAppear_method);
    method_exchangeImplementations(origin_viewDidAppear_method, swizzle_viewDidAppear_method);
    method_exchangeImplementations(origin_viewWillDisappear_method, swizzle_viewWillDisappear_method);
    method_exchangeImplementations(origin_viewDidDisappear_method, swizzle_viewDidDisappear_method);
}



- (void)swizzle_viewWillAppear:(BOOL)animated {
    //NSLog(@"swizzle_viewWillAppear: %@", self);
    
    if ([self isBeingPresented]) {
        [self checkLifeCycleLinkingStatus:^(BOOL linked, UIViewController *linkedViewController) {
            if (linked) {
                [self.kwLinkedViewController viewWillDisappear:animated];
            }
        }];
        
        [self swizzle_viewWillAppear:animated];
    }
}

- (void)swizzle_viewDidAppear:(BOOL)animated {
    //NSLog(@"swizzle_viewDidAppear: %@", self);
    
    if ([self isBeingPresented]) {
        [self checkLifeCycleLinkingStatus:^(BOOL linked, UIViewController *linkedViewController) {
            if (linked) {
                [self.kwLinkedViewController viewDidDisappear:animated];
            }
        }];
        
        [self swizzle_viewDidAppear:animated];
    }
}

- (void)swizzle_viewWillDisappear:(BOOL)animated {
    //NSLog(@"swizzle_viewWillDisappear: %@", self);
    
    if ([self isBeingDismissed]) {
        [self checkLifeCycleLinkingStatus:^(BOOL linked, UIViewController *linkedViewController) {
            if (linked) {
                [self.kwLinkedViewController viewWillAppear:animated];
            }
        }];
        
        [self swizzle_viewWillDisappear:animated];
    }
}

- (void)swizzle_viewDidDisappear:(BOOL)animated {
    //NSLog(@"swizzle_viewDidDisappear: %@", self);
    
    if ([self isBeingDismissed]) {
        [self checkLifeCycleLinkingStatus:^(BOOL linked, UIViewController *linkedViewController) {
            if (linked) {
                [self.kwLinkedViewController viewDidAppear:animated];
            }
        }];
        
        [self swizzle_viewDidDisappear:animated];
    }
//    if (self.kwAutoRemoveLazyWindow && [self isBeingDismissed]) {
//        [self lazyDismissAnimated:NO];
//    }
}

@end

//MARK: -

@implementation UIViewController (KWLazyPresent)

//- (void)setKwAutoRemoveLazyWindow:(BOOL)link {
//    NSNumber *autoRemoveLazyWindow = [NSNumber numberWithBool:link];
//    objc_setAssociatedObject(self, @"kwAutoRemoveLazyWindow", autoRemoveLazyWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (BOOL)kwAutoRemoveLazyWindow {
//    NSNumber *autoRemoveLazyWindow = objc_getAssociatedObject(self, @"kwAutoRemoveLazyWindow");
//    return [autoRemoveLazyWindow boolValue];
//}

//MARK: - Link LifeCycle
- (void)checkLifeCycleLinkingStatus:(void (^)(BOOL granted, UIViewController *linkedViewController))completion {
    
    if (self.kwLinkedViewController && completion) {
        completion(YES, self.kwLinkedViewController);
        return;
    }
    completion(NO, nil);
}

- (void)linkLifeCycleWith:(UIViewController *)viewController {
    self.kwLinkedViewController = viewController;
}

- (void)unlinkLifeCycle {
    self.kwLinkedViewController = nil;
}


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
                    alertType:KWLazyPresentDefaultStyle
                   completion:completion];
}

- (void)lazyPresentAnimated:(BOOL)animated
                  alertType:(KWLazyPresentType)alertType
                 completion:(void (^ __nullable)(void))completion {
    
    UIWindow *window;
    
    if (@available(iOS 13, *)) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"activationState == %ld", UISceneActivationStateForegroundActive];
        
        UIWindowScene *windowScene = (UIWindowScene *)[[UIApplication sharedApplication].connectedScenes filteredSetUsingPredicate:predicate].allObjects.firstObject;
        
        if (windowScene != nil) {
            window = windowScene.windows.firstObject;
            
            self.kwPresentWindow = [[KWWindow alloc] initWithWindowScene:windowScene];
            self.kwPresentWindow.frame = UIScreen.mainScreen.bounds;
        }
        
    }
    
    if (self.kwPresentWindow == nil) {
        self.kwPresentWindow = [[KWWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    
    self.kwPresentWindow.rootViewController = [[UIViewController alloc] init];

    if (window == nil) {
        NSLog(@"Window not found in SceneDelegate");
        window = [UIApplication sharedApplication].windows.firstObject;
    }
    
    if (window == nil) {
        NSLog(@"Window not found in AppDelegate");
    }
    else {
        self.kwPresentWindow.tintColor = window.tintColor;
    }
    

    switch (alertType) {
        case KWLazyPresentInAppNotification:
            self.kwPresentWindow.windowLevel = KWWindowLevelNotification;
            break;
            
        default:
            self.kwPresentWindow.windowLevel = [self kwGetSuitableWindowLevel];
            break;
    }

    [self.kwPresentWindow makeKeyAndVisible];
    [self.kwPresentWindow.rootViewController presentViewController:self animated:animated completion:completion];

}

//MARK: - Lazy Dismiss
//- (void)lazyDismiss {
//    [self lazyDismissAnimated:YES completion:nil];
//}
//
//- (void)lazyDismissAnimated:(BOOL)animated {
//    [self lazyDismissAnimated:animated completion:nil];
//}
//
//- (void)lazyDismissAnimated:(BOOL)animated
//                 completion:(void (^ __nullable)(void))completion {
//    
//    [self dismissViewControllerAnimated:animated completion:^{
//        self.kwPresentWindow.hidden = YES;
//        self.kwPresentWindow = nil;
//        
//        if (completion != nil) {
//            completion();
//        }
//    }];
//}

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
