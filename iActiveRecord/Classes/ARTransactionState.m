//
// Created by James Whitfield on 2/27/15.
// Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import "ARTransactionState.h"



@implementation ARTransactionState {
@private
    NSString *_name;
    BOOL rolledBack;
}


@synthesize name = _name;

- (instancetype)initWithName:(NSString *)aName {
    self = [super init];
    if (self) {
        _name = [aName copy];
    }

    return self;
}

+ (instancetype)stateWithName:(NSString *)aName {
    return [[self alloc] initWithName:aName] ;
}


- (void)rollback {
    rolledBack  = YES;
}

- (BOOL) isRolledBack {
    return rolledBack;
}

@end

@implementation NSString(ARAdditions)

- (NSString *)asSetterMethodName {
    NSString *baseName = [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[self substringToIndex:1] uppercaseString]];
    return [NSString stringWithFormat:@"set%@:", baseName];
}
@end

