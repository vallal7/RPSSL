//
//  CBPeripheralViewController.m
//  RPS
//
//  Created by Ganesh, Ashwin on 8/31/16.
//  Copyright © 2016 Ashwin. All rights reserved.
//

#import "CBPeripheralController.h"
#import "Utility.h"
@interface CBPeripheralController ()
{
    Utility *utility;
    int count;
}
@end

@implementation CBPeripheralController

+ (id)sharedManager {
    static CBPeripheralController *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

-(void)initCBPeripheral {
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    utility = [Utility sharedManager];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
        
        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] primary:YES];
        
        transferService.characteristics = @[_transferCharacteristic];
        
        [_peripheralManager addService:transferService];
        
        [_peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
        // check this count
        count = 0;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    
    _dataToSend = [self.stringToSend dataUsingEncoding:NSUTF8StringEncoding];
    
    _sendDataIndex = 0;
    
    if(count == 0) {
        [self sendData];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
    if(![self.stringToSend containsString:@"opp:"]){
//        dispatch_semaphore_signal(utility.semaphore);
        [self.delegate delegateReturned];
    }
    count++;
}

- (void)sendData {
    
    static BOOL sendingEOM = NO;
    
    // end of message?
    if (sendingEOM) {
        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        if (didSend) {
            // mark as sent
            sendingEOM = NO;
        }
        // else exit and wait for peripheralManagerIsReadyToUpdateSubscribers to restart sendData
        return;
    }
    
    // Send date till the end
    if (self.sendDataIndex >= self.dataToSend.length) {
        // No data left, end.
        return;
    }
    
    // Send remaining data till the callback fails, or we're done.
    BOOL didSend = YES;
    
    while (didSend) {
        // The size
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Maximum - 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // If end, stop and wait for the callback
        if (!didSend) {
            return;
        }
        
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        NSLog(@"Sent: %@", stringFromData);
        
        // Data sent, so update index
        self.sendDataIndex += amountToSend;
        
        if (self.sendDataIndex >= self.dataToSend.length) {
            
            // if the send fails, we'll send it next time based on this parameter
            sendingEOM = YES;
            
            BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                // End of message
                sendingEOM = NO;
                NSLog(@"Sent: EOM");
            }
            return;
        }
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    [self sendData];
}

-(void)stopAdvertisingPeripheral {
    [_peripheralManager stopAdvertising];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
