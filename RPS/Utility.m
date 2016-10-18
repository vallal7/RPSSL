//
//  Utility.m
//  RPS
//
//  Created by Ganesh, Ashwin on 10/13/16.
//  Copyright © 2016 Ashwin. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (id)sharedManager {
    static Utility *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return self;
}
@end
