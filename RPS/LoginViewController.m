//
//  LoginViewController.m
//  RPS
//
//  Created by Ganesh, Ashwin on 3/28/16.
//  Copyright © 2016 Ashwin. All rights reserved.
//

#import "LoginViewController.h"
#import "PlayerModeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
@interface LoginViewController ()

@property (strong) NSMutableArray *users;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor grayColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

-(void)viewWillAppear:(BOOL)animated {
    // Fetch the devices from persistent data store
    self.managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    self.users = [[[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy] lastObject];
//    NSLog(@"User is - %@", self.users);
    
    [self.signinButton setEnabled:NO];
    self.userNameTextField.text = [self.users valueForKey:@"userName"];
    self.passwordTextField.text = @"";
    [self.userNameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loggedOff:(UIStoryboardSegue *)segue {
    NSLog(@"Logged off");
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"login"])
    {
        //Save user ID
        if(self.rememberUser.isOn) {
            if(self.users == nil) {
                // Create a new User
                NSManagedObject *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.managedObjectContext];
                [newUser setValue:self.userNameTextField.text forKey:@"userName"];
                [newUser setValue:[NSNumber numberWithInt:0] forKey:@"wins"];
                [newUser setValue:[NSNumber numberWithInt:0] forKey:@"losses"];
                [newUser setValue:[NSNumber numberWithInt:0] forKey:@"draws"];
                NSError *error = nil;
                // Save the object to persistent store
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            } else if(![[self.users valueForKey:@"userName"] isEqualToString:self.userNameTextField.text]){
                //            NSManagedObject *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.managedObjectContext];
                [self.users setValue:self.userNameTextField.text forKey:@"userName"];
                [self.users setValue:0 forKey:@"wins"];
                [self.users setValue:0 forKey:@"losses"];
                [self.users setValue:0 forKey:@"draws"];
                NSError *error = nil;
                // Save the object to persistent store
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
            
        }
        // Get reference to the destination view controller
        PlayerModeViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.userName = self.userNameTextField.text;
    }
}

-(IBAction)textfieldEdited:(id)sender {
    if (self.userNameTextField.text.length > 0 && self.passwordTextField.text.length > 0) {
        [self.signinButton setEnabled:YES];
    } else {
        [self.signinButton setEnabled:NO];
    }
}

- (IBAction)valueChanged:(UISwitch *)sender {
   
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
@end
