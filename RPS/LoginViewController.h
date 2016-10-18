//
//  LoginViewController.h
//  RPS
//
//  Created by Ganesh, Ashwin on 3/28/16.
//  Copyright © 2016 Ashwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;
-(IBAction)textfieldEdited:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *rememberUser;
- (IBAction)valueChanged:(UISwitch *)sender;

@end
