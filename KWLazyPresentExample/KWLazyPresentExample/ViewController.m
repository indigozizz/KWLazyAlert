//
//  ViewController.m
//  KWLazyPresentExample
//
//  Created by Kawa on 2020/10/13.
//

#import "ViewController.h"

#import "NotificationViewController.h"
#import "UIViewController+KWLazyPresent.h"

@interface ViewController () {
    
    UILabel *windowCountLabel;
    
    UIButton *notificationButton;
    
    UIButton *alertButton;
    
    UIButton *showButton;
    UIButton *dismissButton;
    
    UIButton *logButton;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self layoutInitialize];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)layoutInitialize {
    self.view.backgroundColor = [self getRamdomColor];
    
    long count = [UIApplication sharedApplication].windows.count;
    
    windowCountLabel = [UILabel new];
    windowCountLabel.frame = CGRectMake(10, 10, self.view.frame.size.width, 60);
    windowCountLabel.text = [NSString stringWithFormat:@"%02ld", count];
    windowCountLabel.font = [UIFont boldSystemFontOfSize:45];
    windowCountLabel.textColor = [self getRamdomColor];
    windowCountLabel.shadowColor = UIColor.blackColor;
    windowCountLabel.shadowOffset = CGSizeMake(-1, -1);
    
    notificationButton = [UIButton buttonWithType:UIButtonTypeSystem];
    notificationButton.frame = CGRectMake(0, 0, 180, 60);
    [notificationButton setTitle:@"Show InApp Notification" forState:UIControlStateNormal];
    [notificationButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    notificationButton.backgroundColor = [UIColor purpleColor];
    
    [notificationButton addTarget:self action:@selector(notificationButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    alertButton = [UIButton buttonWithType:UIButtonTypeSystem];
    alertButton.frame = CGRectMake(0, 0, 180, 60);
    [alertButton setTitle:@"Show Alert" forState:UIControlStateNormal];
    [alertButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    alertButton.backgroundColor = [UIColor yellowColor];
    
    [alertButton addTarget:self action:@selector(alertButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    showButton = [UIButton buttonWithType:UIButtonTypeSystem];
    showButton.frame = CGRectMake(0, 0, 180, 60);
    [showButton setTitle:@"Present ViewController" forState:UIControlStateNormal];
    [showButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    showButton.backgroundColor = [UIColor greenColor];
    
    [showButton addTarget:self action:@selector(showButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dismissButton.frame = CGRectMake(0, 0, 180, 60);
    [dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [dismissButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    dismissButton.backgroundColor = [UIColor redColor];
    
    [dismissButton addTarget:self action:@selector(dismissButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    logButton = [UIButton buttonWithType:UIButtonTypeSystem];
    logButton.frame = CGRectMake(0, 0, 180, 60);
    [logButton setTitle:@"Print Log" forState:UIControlStateNormal];
    [logButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    logButton.backgroundColor = [UIColor blackColor];
    
    [logButton addTarget:self action:@selector(logButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    notificationButton.center = CGPointMake(self.view.center.x, self.view.center.y - 140);
    
    alertButton.center = CGPointMake(self.view.center.x, self.view.center.y - 70);
    
    showButton.center = CGPointMake(self.view.center.x, self.view.center.y);
    
    dismissButton.center = CGPointMake(self.view.center.x, self.view.center.y + 70);
    
    logButton.center = CGPointMake(self.view.center.x, self.view.center.y + 140);
    
    [self.view addSubview:windowCountLabel];
    [self.view addSubview:notificationButton];
    [self.view addSubview:alertButton];
    [self.view addSubview:showButton];
    [self.view addSubview:dismissButton];
    [self.view addSubview:logButton];
}

- (void)notificationButtonClick:(UIButton *)button {
    
    NotificationViewController *viewController = [NotificationViewController new];
    
    viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [viewController lazyPresentAnimated:NO alertType:KWLazyAlertInAppNotification completion:^{
        NSLog(@"lazyPresentCompletion (Notification)");
    }];
}

- (void)alertButtonClick:(UIButton *)button {
    LazyAlert(@"Show Alert");
}

- (void)showButtonClick:(UIButton *)button {
    
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    ViewController *viewController = [ViewController new];
    
    viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    [viewController lazyPresentAnimated:YES completion:^{
        NSLog(@"lazyPresentCompletion");
    }];
    //});
}

- (void)dismissButtonClick:(UIButton *)button {
    [self lazyDismissAnimated:YES completion:^{
        NSLog(@"lazyDismissCompletion");
    }];
}

- (void)logButtonClick:(UIButton *)button {
    NSLog(@"logButtonClick");
}


//MARK: Utils
- (UIColor *) getRamdomColor {
    CGFloat comps[3];
    for (int i = 0; i < 3; i++)
    comps[i] = (CGFloat)arc4random_uniform(256)/255.f;
    
    return [UIColor colorWithRed:comps[0] green:comps[1] blue:comps[2] alpha:1.0];
}

@end
