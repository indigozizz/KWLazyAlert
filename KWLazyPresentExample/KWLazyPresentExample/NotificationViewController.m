//
//  NotificationViewController.m
//  KWLazyPresentExample
//
//  Created by Kawa on 2020/10/19.
//

#import "NotificationViewController.h"

#import "KWPassthroughView.h"
#import "UIViewController+KWLazyPresent.h"

@interface NotificationViewController () {
    UIView *notificationView;
    CGRect showFrame;
    CGRect hideFrame;
}

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //MARK: Add KWPassthroughView to pass the touches between Windows
    KWPassthroughView *passthroughView = [KWPassthroughView new];
    passthroughView.frame = self.view.bounds;
    [self.view addSubview:passthroughView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showNotificationViewWithTitle:@"Notification Title" andMessage:@"Notification Message"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//MARK: - Just an Dummy Example for Notification View.
- (void)showNotificationViewWithTitle:(NSString *)title andMessage:(NSString *)message {
    
    CGFloat leftInset = 16.0f;
    CGFloat topInset = 16.0f;
    
    CGFloat topSafeAreaInset = 0;
    
    if (@available(iOS 11, *)) {
        UIEdgeInsets edgeInsets = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets;
        topSafeAreaInset = edgeInsets.top;
    }
    
    CGFloat x = leftInset;
    CGFloat y = topInset + topSafeAreaInset;
    CGFloat width = self.view.frame.size.width - leftInset * 2;
    CGFloat height = 110.0f;

    showFrame = CGRectMake(x, y, width, height);
    hideFrame = CGRectMake(x, -height, width, height);
    
    notificationView = [[UIView alloc] initWithFrame:hideFrame];
    notificationView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    notificationView.layer.cornerRadius = 13.0;
    
    notificationView.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:1.0].CGColor;
    notificationView.layer.shadowOffset = CGSizeMake(0, 2);
    notificationView.layer.shadowRadius = 4.0;
    notificationView.layer.shadowOpacity = 0.1;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = notificationView.bounds;
    [button addTarget:self action:@selector(notificationDismiss) forControlEvents:UIControlEventTouchUpInside];

    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textColor = UIColor.lightGrayColor;
    titleLabel.text = title;
    titleLabel.frame = CGRectMake(x, 0, width, height / 2);
    
    UILabel *messageLabel = [UILabel new];
    messageLabel.font = [UIFont systemFontOfSize:13];
    messageLabel.textColor = UIColor.darkGrayColor;
    messageLabel.text = message;
    messageLabel.numberOfLines = 2;
    messageLabel.frame = CGRectMake(x, height / 2, width, height / 2);

    [notificationView addSubview:titleLabel];
    [notificationView addSubview:messageLabel];
    [notificationView addSubview:button];
    

    [self.view addSubview:notificationView];

    [UIView animateWithDuration:0.75 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self->notificationView.frame = self->showFrame;
    } completion:^(BOOL finished) {
        
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self notificationDismiss];
    });
}

- (void)notificationDismiss {
    [self->notificationView.layer removeAllAnimations];
    self->notificationView.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.75 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self->notificationView.frame = self->hideFrame;
    } completion:^(BOOL finished) {
        [self->notificationView removeFromSuperview];
        [self lazyDismissAnimated:NO completion:nil];
    }];
}

@end
