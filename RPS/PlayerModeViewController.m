//
//  PlayerModeViewController.m
//  RPS
//
//  Created by Ganesh, Ashwin on 8/31/16.
//  Copyright © 2016 Ashwin. All rights reserved.
//

#import "PlayerModeViewController.h"
#import <CoreData/CoreData.h>
#import "ViewController.h"
#import "CBPeripheralController.h"
#import "CBCentralManagerController.h"
#import "Utility.h"

@interface PlayerModeViewController () {
    NSNumber *numberOfWins, *numberOfLosses, *numberOfDraws;
    CBCentralManagerController *manager;
    CBPeripheralController *peripheral;
    NSString *userMode, *gameMode;
    Utility *utility;
}
@property (nonatomic, retain) NSMutableArray *users;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end

@implementation PlayerModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    utility = [Utility sharedManager];
    utility.isReceiver = true;
    utility.isBaseSender = false;
    // Do any additional setup after loading the view.
    // Fetch the devices from persistent data store
    self.managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    self.users = [[[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy] lastObject];
    numberOfWins = [self.users valueForKey:@"wins"];
    numberOfLosses = [self.users valueForKey:@"losses"];
    numberOfDraws = [self.users valueForKey:@"draws"];
    [self.winLabel setText:[NSString stringWithFormat:@"%@",numberOfWins]];
    [self.drawLabel setText:[NSString stringWithFormat:@"%@",numberOfDraws]];
    [self.lossLabel setText:[NSString stringWithFormat:@"%@",numberOfLosses]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageReceived:)
                                                 name:@"UserConnectionReceivedNotification"
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    manager = [CBCentralManagerController sharedManager];
    [manager setDelegate:self];
    [manager setSecondDelegate:nil];
    [manager initCBCentralManager];
    userMode = @"manager";
    gameMode = @"single";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)messageReceived:(NSNotification *) notification {
    gameMode = @"multi";
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self performSegueWithIdentifier: @"singlePayer" sender: self];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"singlePayer"]) {
        // Get reference to the destination view controller
        ViewController *vc = [segue destinationViewController];
        vc.userName = self.userName;
        vc.userMode = @"";
        if([gameMode caseInsensitiveCompare:@"single"] == NSOrderedSame) {
            vc.gameMode = @"singlePlayer";
        } else {
            vc.userMode = userMode;
            vc.gameMode = @"multiPlayer";
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)singlePlayerClicked:(id)sender {
    [self performSegueWithIdentifier: @"singlePayer" sender: self];
}

- (IBAction)multiPlayerClicked:(id)sender {
    gameMode = @"multi";
//    [self performSegueWithIdentifier: @"multiPlayer" sender: self];
    [manager stopScan];
    utility.isSender = true;
    utility.isReceiver = false;
    utility.isBaseSender = true;
    peripheral = [CBPeripheralController sharedManager];
    peripheral.stringToSend = [NSString stringWithFormat:@"opp:%@",self.userName];
    [peripheral initCBPeripheral];
    userMode = @"peripheral";
    [self performSegueWithIdentifier: @"singlePayer" sender: self];
}

- (IBAction)signOffClicked:(id)sender {
    [manager stopScan];
    [peripheral stopAdvertisingPeripheral];
    [self performSegueWithIdentifier:@"UnWindSegue2" sender:self];

}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    NSLog(@"Back");
}
@end
