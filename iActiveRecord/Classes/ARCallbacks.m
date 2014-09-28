//
// Created by James Whitfield on 9/10/14.
// Copyright (c) 2014 okolodev.org. All rights reserved.
//

#import "ARCallbacks.h"



#import "ActiveRecord_Private.h"


@interface ARCallbacks () {

}
+ (instancetype)sharedInstance;
@end

@implementation ARCallbacks {}



    - (instancetype)init {
        self = [super init];
        if (self) {
            //       validations = [NSMutableSet new];
        }
        return self;
    }

    + (instancetype)sharedInstance {
        static dispatch_once_t once;
        static id sharedInstance;
        dispatch_once(&once, ^{
            sharedInstance = [self new];
        });
        return sharedInstance;
    }

    + (void)registerCallback:(Class)aCallback forRecord:(NSString *)aRecord {

    }


@end