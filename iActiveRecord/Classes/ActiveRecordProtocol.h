//
// Created by James Whitfield on 6/4/15.
// Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ARLazyFetcher;


@protocol ActiveRecord <NSObject>
#pragma mark - TableName
+ (NSString *)recordName;

#pragma mark - Persistence
- (BOOL)save;

- (BOOL)update;

- (BOOL)sync;

- (void)dropRecord;

#pragma mark -
+ (NSInteger)count;

+ (NSArray *) all;
#pragma mark - Query
+ (ARLazyFetcher *) query;

+ (instancetype)findById:(id)record_id;

+ (instancetype)findByKey:(id)key value:(id)value;

+ (instancetype)findOrBuildByKey:(id)key value:(id)value;

+ (NSArray *)findAllByKey:(id)key value:(id)value;

+ (NSArray *)findAllByConditions:(NSDictionary *)conditions;

+ (NSArray*)findByConditions:(NSDictionary *)conditions;

@end