//
//  Utility.h
//  RPS
//
//  Created by Ganesh, Ashwin on 10/13/16.
//  Copyright © 2016 Ashwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

@property (nonatomic) BOOL isSender;
@property (nonatomic) BOOL isReceiver;
@property (nonatomic) BOOL isBaseSender;
@property (nonatomic) dispatch_semaphore_t semaphore;

+ (id)sharedManager;

@end
