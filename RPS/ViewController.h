//
//  ViewController.h
//  RPS
//
//  Created by Ganesh, Ashwin on 1/16/16.
//  Copyright © 2016 Ashwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *selectedImage;
@property (weak, nonatomic) IBOutlet UIImageView *userWinner;
@property (weak, nonatomic) IBOutlet UIImageView *randomImage;
@property (weak, nonatomic) IBOutlet UIImageView *systemWinner;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIImageView *drawImage;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *button4;
@property (weak, nonatomic) IBOutlet UIButton *button5;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userMode;
@property (strong, nonatomic) NSString *gameMode;
@property (weak, nonatomic) IBOutlet UILabel *userWinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *systemWinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *drawLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectSignLabel;
@property (weak, nonatomic) IBOutlet UILabel *opponentName;

- (IBAction)buttonSelected:(UIButton *)sender;
- (IBAction)backClicked:(UIButton *)sender;
-(void)delegateReturned;
@end

