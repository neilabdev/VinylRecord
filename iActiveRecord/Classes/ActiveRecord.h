//
//  ActiveRecord.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "ActiveRecordProtocol.h"
#import "ARRelationshipsHelper.h"
#import "ARMappingHelper.h"
#import "ARCallbacksHelper.h"
#import "ARLazyFetcher.h"
#import "ARErrorHelper.h"
#import "ARError.h"
#import "ARRepresentationProtocol.h"
#import "AREnum.h"
#import "ARValidatorProtocol.h"
#import "ARException.h"
#import "ARIndicesMacroHelper.h"
#import "ARValidationsHelper.h"
#import "ARConfiguration.h"
#import "ARSynchronizationProtocol.h"
#import "ARTransactionState.h"

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

- (BOOL)isNewRecord;

- (BOOL)isDirty;

- (BOOL)isValid;

- (NSArray *)errors;

- (void)addError:(ARError *)anError;

- (void)addErrors:(NSArray *)errors;

+ (instancetype)newRecord __deprecated;

+ (instancetype)new:(NSDictionary *)values;

+ (instancetype)create:(NSDictionary *)values;

+ (instancetype)record;

+ (instancetype)record:(NSDictionary *)values;

- (void)copyFrom:(ActiveRecord *)copy;

- (void)copyFrom:(ActiveRecord *)copy merge:(BOOL)merge;

- (instancetype)reload;

+ (NSArray *)allRecords __deprecated;

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

+ (void)addSearchOn:(NSString *)aField;

+ (BOOL)savePointTransaction:(ARSavePointTransactionBlock)transaction NS_SWIFT_NAME(savePoint(transaction:));

+ (BOOL)savePoint:(NSString *)name transaction:(ARSavePointTransactionBlock)transaction  NS_SWIFT_NAME(savePoint(name:transaction:));

- (instancetype)recordSaved;
@end
