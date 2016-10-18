//
//  CustomUnwindSegue.m
//  RPS
//
//  Created by Ganesh, Ashwin on 3/28/16.
//  Copyright © 2016 Ashwin. All rights reserved.
//

#import "CustomUnwindSegue.h"

@implementation CustomUnwindSegue

- (void)perform
{
    UIView *sourceViewController = ((UIViewController *)self.sourceViewController).view;
    UIView *destinationViewController = ((UIViewController *)self.destinationViewController).view;
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    destinationViewController.center = CGPointMake(sourceViewController.center.x - sourceViewController.frame.size.width, destinationViewController.center.y);
    [window insertSubview:destinationViewController belowSubview:sourceViewController];
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         destinationViewController.center = CGPointMake(sourceViewController.center.x,
                                                 destinationViewController.center.y);
                         sourceViewController.center = CGPointMake(sourceViewController.center.x + sourceViewController.frame.size.width,
                                                 destinationViewController.center.y);
                     }
                     completion:^(BOOL finished){
                         [[self destinationViewController]
                          dismissViewControllerAnimated:NO completion:nil];
                     }];
    
}


@end
