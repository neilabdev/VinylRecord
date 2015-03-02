//
//  ActiveRecord.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

#import "ARRelationshipsHelper.h"
#import "ARValidationsHelper.h"
#import "ARCallbacksHelper.h"
#import "ARLazyFetcher.h"
#import "ARErrorHelper.h"
#import "ARError.h"
#import "ARRepresentationProtocol.h"
#import "AREnum.h"
#import "ARValidatorProtocol.h"
#import "ARException.h"
#import "ARIndicesMacroHelper.h"
#import "ARConfiguration.h"
#import "ARSynchronizationProtocol.h"
#import "ARTransactionState.h"

@protocol ActiveRecord <NSObject>
#pragma mark - TableName
+ (NSString *)recordName;
@end

@class ARConfiguration;

typedef void (^ARTransactionBlock)();

typedef void (^ARConfigurationBlock)(ARConfiguration *config);

#define ar_rollback \
    [ARException raise];

@interface ActiveRecord : NSObject <ActiveRecord>

@property(nonatomic, retain) NSNumber *id;
@property(nonatomic, retain) NSDate *updatedAt;
@property(nonatomic, retain) NSDate *createdAt;

- (void)markAsNew;

- (BOOL)isDirty;

- (BOOL)isValid;

- (NSArray *)errors;

- (void)addError:(ARError *)anError;

- (void)addErrors:(NSArray *)errors;

+ (instancetype)newRecord __deprecated;

+ (instancetype)new:(NSDictionary *)values;

+ (instancetype)create:(NSDictionary *)values;

- (void)copyFrom:(ActiveRecord *)copy;

- (void)copyFrom:(ActiveRecord *)copy merge:(BOOL)merge;

- (instancetype)reload;

- (BOOL)save;

- (BOOL)update;

- (BOOL)sync;

- (void)dropRecord;

+ (NSInteger)count;

+ (NSArray *)allRecords;

+ (ARLazyFetcher *)lazyFetcher;

+ (void)dropAllRecords;

+ (void)clearDatabase;

+ (void)transaction:(ARTransactionBlock)aTransactionBlock;

+ (void)applyConfiguration:(ARConfigurationBlock)configBlock;


#pragma mark - Callbacks

- (void)beforeSave;

- (void)afterSave;

- (void)afterUpdate;

- (void)beforeValidation;

- (void)afterValidation;

- (void)beforeCreate;

- (void)afterCreate;

- (void)beforeDestroy;

- (void)afterDestroy;

- (void)beforeSync;

- (void)afterSync;


#pragma mark - Extensions
+ (ARLazyFetcher *) query;

+ (instancetype)findById:(id)record_id;

+ (instancetype)findByKey:(id)key value:(id)value;

+ (instancetype)findOrBuildByKey:(id)key value:(id)value;

+ (NSArray *)findAllByKey:(id)key value:(id)value;

+ (NSArray *)findAllByConditions:(NSDictionary *)conditions;

+ (instancetype)findByConditions:(NSDictionary *)conditions;

+ (void)addSearchOn:(NSString *)aField;

+ (BOOL)savePointTransaction:(ARSavePointTransactionBlock)transaction;

+ (BOOL)savePoint:(NSString *)name transaction:(ARSavePointTransactionBlock)transaction;

- (instancetype)recordSaved;
@end


