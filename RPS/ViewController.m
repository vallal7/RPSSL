//
//  ViewController.m
//  RPS
//
//  Created by Ganesh, Ashwin on 1/16/16.
//  Copyright © 2016 Ashwin. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomUnwindSegue.h"
#import <CoreData/CoreData.h>
#import "CBPeripheralController.h"
#import "CBCentralManagerController.h"
#import "Utility.h"

@interface ViewController () {
    BOOL blinkStatus;
    NSNumber *numberOfWins, *numberOfLosses, *numberOfDraws;
    CBPeripheralController *peripheral;
    CBCentralManagerController *manager;
    NSInteger selectedButtonTagIndex;
    NSInteger receivedButtonTagIndex;
    BOOL selectedOptionFlag, gotOpponentOptionFlag;
    Utility *utility;
    // userSelectedNewOption - for receiver to send option before receiving
    // messageReceived - when receiver receieves messgae
    BOOL userSelectedNewOption, messageReceived;
}
@property (nonatomic, retain, readonly) NSArray *imagesArray;
@property (nonatomic, retain, readonly) NSArray *dataArray;
@property (nonatomic, retain, readonly) NSArray *imageRandomizerArray;
@property (nonatomic, retain, readonly) NSArray *buttonsArray;
@property (nonatomic, retain) NSMutableArray *users;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _imagesArray = [NSArray arrayWithObjects:@"scissors",@"paper",@"rock",@"lizard",@"spock", nil];
    utility = [Utility sharedManager];
    peripheral = [CBPeripheralController sharedManager];
    [peripheral setDelegate:self];
    manager = [CBCentralManagerController sharedManager];
    _imageRandomizerArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"scissors.png"], [UIImage imageNamed:@"paper.png"], [UIImage imageNamed:@"rock.png"], [UIImage imageNamed:@"lizard.png"], [UIImage imageNamed:@"spock.png"], nil];
    _buttonsArray = [NSArray arrayWithObjects:self.button1, self.button2, self.button3, self.button4, self.button5, nil];
    _dataArray = @[@[@"D", @"W",@"L",@"W",@"L"],
                   @[@"L", @"D",@"W",@"L",@"W"],
                   @[@"W", @"L",@"D",@"W",@"L"],
                   @[@"L", @"W",@"L",@"D",@"W"],
                   @[@"W", @"L",@"W",@"L",@"D"]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor grayColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    [self.userNameLabel setText:self.userName];
    [self.userWinsLabel setText:[NSString stringWithFormat:@"You win"]];
    
    self.selectSignLabel.alpha = 0;
    [UIView animateWithDuration:1.5 delay:0.5 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        self.selectSignLabel.alpha = 1;
    } completion:nil];
    
    // Fetch the devices from persistent data store
    self.managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    self.users = [[[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy] lastObject];
    numberOfWins = [self.users valueForKey:@"wins"];
    numberOfLosses = [self.users valueForKey:@"losses"];
    numberOfDraws = [self.users valueForKey:@"draws"];
    if([self.gameMode caseInsensitiveCompare:@"multiPlayer"] == NSOrderedSame) {
        [self.opponentName setText:@"Opponent"];
        [self.systemWinsLabel setText:@"Opponent wins"];
    }
    [manager setSecondDelegate:self];
    [manager setDelegate:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userConnection:)
                                                 name:@"UserConnectionReceivedNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedSelection:)
                                                 name:@"OpponentOptionReceivedNotification"
                                               object:nil];
    messageReceived = false;
    userSelectedNewOption = false;
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UserConnectionReceivedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OpponentOptionReceivedNotification" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonSelected:(UIButton *)sender {
    [self disableButtonsDuringAnimation];
    self.selectSignLabel.alpha = 0;

    [self.selectedImage setImage:sender.currentBackgroundImage];
    [self.selectedImage setTag:sender.tag];
    selectedButtonTagIndex = sender.tag;
    selectedOptionFlag = true;
    
    [self hideAll];
    if([self.gameMode caseInsensitiveCompare:@"multiPlayer"] != NSOrderedSame) {
        self.randomImage.animationImages = _imageRandomizerArray;
        self.randomImage.animationDuration = 1;
        [self.randomImage startAnimating];
        
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(timerRanOut)
                                       userInfo:nil
                                        repeats:NO];
    } else {
        if(utility.isSender){
            peripheral.stringToSend = [NSString stringWithFormat:@"%ld",(long)selectedButtonTagIndex];
            [peripheral initCBPeripheral];
            
//            [peripheral stopAdvertisingPeripheral];
//            utility.isReceiver = true;
//            [manager initCBCentralManager];
        } else {
            userSelectedNewOption = true;
            [self sendNewOption];
            [self multiPlayerGamePlay];
        }
    }
}

-(void)delegateReturned{
    [peripheral stopAdvertisingPeripheral];
    utility.isReceiver = true;
    [manager initCBCentralManager];
    [self multiPlayerGamePlay];
}

-(void)receivedSelection:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *receivedIndex = [userInfo objectForKey:@"msg"];
    receivedButtonTagIndex = receivedIndex.integerValue;
    gotOpponentOptionFlag = true;
    [self multiPlayerGamePlay];
    if(utility.isReceiver){
        // if receiver, send the selected option
        messageReceived = true;
        [self sendNewOption];
    } else {
        // if sender, switch back to sender moder

    }
}

-(void)sendNewOption{
    if(userSelectedNewOption && messageReceived){
        [manager stopScan];
        if(utility.isReceiver) {
            utility.isSender = true;
        }
        peripheral.stringToSend = [NSString stringWithFormat:@"%ld",(long)selectedButtonTagIndex];
        [peripheral initCBPeripheral];
        [peripheral stopAdvertisingPeripheral];
        [manager initCBCentralManager];
        messageReceived = false;
        userSelectedNewOption = false;
    }
}

-(void)userConnection:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *receivedIndex = [userInfo objectForKey:@"msg"];
    receivedButtonTagIndex = receivedIndex.integerValue;
    gotOpponentOptionFlag = true;
    [self multiPlayerGamePlay];
    
//    [manager stopScan];
//    peripheral = [CBPeripheralController sharedManager];
//    peripheral.stringToSend = [NSString stringWithFormat:@"%ld",(long)selectedButtonTagIndex];
//    [peripheral initCBPeripheral];
}

-(void)hideAll{
    [self.userWinner setHidden:YES];
    [self.systemWinner setHidden:YES];
    [self.drawImage setHidden:YES];
    [self.userWinsLabel setHidden:YES];
    [self.systemWinsLabel setHidden:YES];
    [self.drawLabel setHidden:YES];
}

-(void)disableButtonsDuringAnimation{
    [self.buttonsArray enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        [(UIButton*)object setEnabled:NO];

    }];
}

-(void)enableButtonsAfterAnimation{
    [self.buttonsArray enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        [(UIButton*)object setEnabled:YES];
    }];}

-(void)timerRanOut {
        int randomNumber = arc4random() % 5;
        [self setSystemImage: randomNumber];
}

-(void)setSystemImage:(int)element {
    [self.randomImage stopAnimating];
    [self enableButtonsAfterAnimation];
    [self.randomImage setImage:[UIImage imageNamed:[self.imagesArray objectAtIndex:element]]];
    [self.randomImage setTag:element];
    [self decideWinner];
}

-(void)decideWinner {
    NSString *result = self.dataArray[self.selectedImage.tag][self.randomImage.tag];
    if([result caseInsensitiveCompare:@"w"] == NSOrderedSame) {
        [self.userWinner setHidden:NO];
        [self.userWinsLabel setHidden:NO];
        numberOfWins = [NSNumber numberWithInt:[numberOfWins intValue]+1];
        [self.users setValue:numberOfWins forKey:@"wins"];
    }
    else if([result caseInsensitiveCompare:@"l"] == NSOrderedSame) {
        [self.systemWinner setHidden:NO];
        [self.systemWinsLabel setHidden:NO];
        numberOfLosses = [NSNumber numberWithInt:[numberOfLosses intValue]+1];
        [self.users setValue:numberOfLosses forKey:@"losses"];
    }
    else {
        [self.drawImage setHidden:NO];
        [self.drawLabel setHidden:NO];
        numberOfDraws = [NSNumber numberWithInt:[numberOfDraws intValue]+1];
        [self.users setValue:numberOfDraws forKey:@"draws"];
    }
    NSError *error = nil;
    // Save the object to persistent store
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }

}

-(void)multiPlayerGamePlay {
    if(selectedOptionFlag && gotOpponentOptionFlag) {
        [self.randomImage setImage:[UIImage imageNamed:[self.imagesArray objectAtIndex:receivedButtonTagIndex]]];
        [self.randomImage setTag:receivedButtonTagIndex];
        [self decideWinner];
        gotOpponentOptionFlag = false;
        selectedOptionFlag = false;
        [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(resetForNewGame) userInfo:nil repeats:NO];
    }
}

-(void)resetForNewGame {
    self.selectSignLabel.alpha = 1;
    [self enableButtonsAfterAnimation];
    [self.randomImage setImage:nil];
    [self.selectedImage setImage:nil];
    messageReceived = false;
    userSelectedNewOption = false;
    receivedButtonTagIndex = 0;
    gotOpponentOptionFlag = false;
    selectedOptionFlag = false;
    utility.isReceiver = false;
    utility.isSender = false;
    [self hideAll];
    if(utility.isBaseSender){
        utility.isSender = true;
        [manager stopScan];

    } else {
        utility.isReceiver = true;
        [peripheral stopAdvertisingPeripheral];
        [manager initCBCentralManager];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)backClicked:(UIButton *)sender {
    [self performSegueWithIdentifier:@"UnWindSegue" sender:self];
}

//- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController
//                                      fromViewController:(UIViewController *)fromViewController
//                                              identifier:(NSString *)identifier {
//    
//    // Check the identifier and return the custom unwind segue if this is an
//    // unwind we're interested in
//    if ([identifier isEqualToString:@"UnWindSegue"]) {
//        CustomUnwindSegue *segue = [[CustomUnwindSegue alloc]
//                                      initWithIdentifier:identifier
//                                      source:fromViewController
//                                      destination:toViewController];
//        return segue;
//    }
//    
//    // return the default unwind segue otherwise
//    return [super segueForUnwindingToViewController:toViewController
//                                 fromViewController:fromViewController
//                                         identifier:identifier];
//}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

@end
