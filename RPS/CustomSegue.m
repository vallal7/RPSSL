//
//  CustomSegue.m
//  RPS
//
//  Created by Ganesh, Ashwin on 3/28/16.
//  Copyright © 2016 Ashwin. All rights reserved.
//

#import "CustomSegue.h"

@implementation CustomSegue

- (void)perform
{
    UIView *sourceViewController = ((UIViewController *)self.sourceViewController).view;
    UIView *destinationViewController = ((UIViewController *)self.destinationViewController).view;
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    destinationViewController.center = CGPointMake(sourceViewController.center.x + sourceViewController.frame.size.width,
                            destinationViewController.center.y);
    [window insertSubview:destinationViewController aboveSubview:sourceViewController];
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         destinationViewController.center = CGPointMake(sourceViewController.center.x,
                                                 destinationViewController.center.y);
                         sourceViewController.center = CGPointMake(0 - sourceViewController.center.x,
                                                 destinationViewController.center.y);
                     }
                     completion:^(BOOL finished){
                         [[self sourceViewController] presentViewController:
                          [self destinationViewController] animated:NO completion:nil];
                     }];
    
}

@end
