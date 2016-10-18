//
//  CBPeripheralViewController.h
//  RPS
//
//  Created by Ganesh, Ashwin on 8/31/16.
//  Copyright © 2016 Ashwin. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "Services.h"
#import "ViewController.h"

@interface CBPeripheralController : NSObject <CBPeripheralManagerDelegate>
+ (id)sharedManager;
-(void)initCBPeripheral;
-(void)stopAdvertisingPeripheral;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteristic;
@property (strong, nonatomic) NSData *dataToSend;
@property (nonatomic, readwrite) NSInteger sendDataIndex;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *stringToSend;
@property (weak, nonatomic) ViewController *delegate;

@end
