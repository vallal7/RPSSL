//
//  CBCentralManagerViewController.h
//  RPS
//
//  Created by Ganesh, Ashwin on 8/31/16.
//  Copyright © 2016 Ashwin. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "Services.h"
#import <UIKit/UIKit.h>
#import "PlayerModeViewController.h"
#import "ViewController.h"

@interface CBCentralManagerController : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
+ (id)sharedManager;
-(void)initCBCentralManager;
-(void) stopScan;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData *data;
@property (weak, nonatomic) PlayerModeViewController *delegate;
@property (weak, nonatomic) ViewController *secondDelegate;

@end
