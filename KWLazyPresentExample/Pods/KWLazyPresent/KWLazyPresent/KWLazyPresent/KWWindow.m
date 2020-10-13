//
//  KWWindow.m
//  KWLazyPresent
//
//  Created by Kawa on 2020/10/13.
//

#import "KWWindow.h"
#import "KWPassthroughView.h"

@implementation KWWindow

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {

  // See if the hit is anywhere in our view hierarchy
  UIView *hitTestResult = [super hitTest:point withEvent:event];

  // KWPassthroughView view covers the pass-through touch area.  It's recognized
  // by class, here, because the window doesn't have a pointer to the actual view object.
  if ([hitTestResult isKindOfClass:[KWPassthroughView class]]) {

    // Returning nil means this window's hierachy doesn't handle this event. Consequently,
    // the event will be passed to the host window.
    return nil;
  }

  return hitTestResult;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
