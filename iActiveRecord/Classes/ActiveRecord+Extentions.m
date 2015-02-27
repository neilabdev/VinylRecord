//
// Created by James Whitfield on 3/18/14.
// Copyright (c) 2014 NEiLAB, Inc. All rights reserved.
//
#import "ActiveRecord+Extensions.h"
#import "ARDatabaseManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "ARLazyFetcher+Extensions.h"

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




@implementation ActiveRecord (Extensions)

+ (instancetype) findById: (id) record_id {
    return [[self lazyFetcher] findById:record_id];
}

+ (instancetype) findByKey: (id) key value: (id) value {
    id result =[[self lazyFetcher] findByKey:key value:value] ;
    return result;
}

+ (instancetype) findOrBuildByKey: (id) key value: (id) value {
    id instance =   [[self lazyFetcher] findByKey:key value:value];
    if(!instance)
        instance = [self new:@{key : value}];

    return instance;
}

+ (NSArray *) findAllByKey: (id) key value: (id) value {
    return [[self lazyFetcher] findAllByKey:key value:value];
}

+ (NSArray *) findAllByConditions: (NSDictionary *) conditions {
    return [[self lazyFetcher] findAllByConditions:conditions];
}

+ (instancetype) findByConditions: (NSDictionary *) conditions {
    return [[self lazyFetcher] findByConditions:conditions];
}


- (instancetype) recordSaved {

    if([self save])
        return self;

    return nil;
}


+ (BOOL) savePointTransaction: (ARSavePointTransactionBlock) transaction {
    NSString *savePointSeed = [NSString stringWithFormat:@"liberty"];
    NSString *savePointName = [self savepointMD5Hash: [NSString stringWithFormat:@"%p", savePointSeed] ];
    return [self savePoint:savePointName transaction:transaction];
}

+ (BOOL) savePoint: (NSString *)name transaction: (ARSavePointTransactionBlock) transaction {
    BOOL failure = NO;

    @try {
        [[ARDatabaseManager sharedManager] executeSqlQuery:[[NSString stringWithFormat:@"SAVEPOINT '%@'", name] UTF8String]];
        ARTransactionState *status = [ARTransactionState stateWithName:name];
        transaction(status);

        if((failure = status.isRolledBack))
            [[ARDatabaseManager sharedManager] executeSqlQuery:[[NSString stringWithFormat:@"ROLLBACK TRANSACTION TO SAVEPOINT '%@'", name] UTF8String]];

        [[ARDatabaseManager sharedManager] executeSqlQuery:[[NSString stringWithFormat:@"RELEASE SAVEPOINT '%@' ", name] UTF8String]];

    } @catch (ARException *exception) {
        failure = YES;
        [[ARDatabaseManager sharedManager] executeSqlQuery:[[NSString stringWithFormat:@"ROLLBACK TRANSACTION TO SAVEPOINT '%@'", name] UTF8String]];
        [[ARDatabaseManager sharedManager] executeSqlQuery:[[NSString stringWithFormat:@"RELEASE SAVEPOINT '%@' ", name] UTF8String]];

    }
    return !failure;
}

+ (NSString *) savepointMD5Hash:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );

    return [NSString stringWithFormat:
            @"savePoint_%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
    ];
}


@end


