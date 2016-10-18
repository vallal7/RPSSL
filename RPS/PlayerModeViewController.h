//
//  PlayerModeViewController.h
//  RPS
//
//  Created by Ganesh, Ashwin on 8/31/16.
//  Copyright © 2016 Ashwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerModeViewController : UIViewController
@property (strong, nonatomic) NSString *userName;
@property (weak, nonatomic) IBOutlet UILabel *winLabel;
@property (weak, nonatomic) IBOutlet UILabel *drawLabel;
@property (weak, nonatomic) IBOutlet UILabel *lossLabel;
- (IBAction)singlePlayerClicked:(id)sender;
- (IBAction)multiPlayerClicked:(id)sender;
- (IBAction)signOffClicked:(id)sender;

@end
