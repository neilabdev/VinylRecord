//
//  ARLazyFetcher.h
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActiveRecordProtocol.h"
typedef enum {
    ARJoinLeft,
    ARJoinRight,
    ARJoinInner,
    ARJoinOuter
} ARJoinType;

@class ActiveRecord;
@interface ARLazyFetcher : NSArray

- (instancetype)initWithRecord:(Class  <ActiveRecord> )aRecord;
- (instancetype)initWithRecord:(ActiveRecord *)entityRow
                   thatHasMany:(NSString *)aClassName through:(NSString *)aRelationsipClassName ;

    - (ARLazyFetcher *)limit:(NSInteger)aLimit;
- (ARLazyFetcher *)offset:(NSInteger)anOffset;

- (ARLazyFetcher *)only:(NSString *)aFirstParam, ... NS_REQUIRES_NIL_TERMINATION;
- (ARLazyFetcher *)except:(NSString *)aFirstParam, ... NS_REQUIRES_NIL_TERMINATION;
- (ARLazyFetcher *)join:(Class <ActiveRecord> )aJoinRecord;

- (ARLazyFetcher *)join:(Class <ActiveRecord> )aJoinRecord
                useJoin:(ARJoinType)aJoinType
                onField:(NSString *)aFirstField
               andField:(NSString *)aSecondField;

- (ARLazyFetcher *)orderBy:(NSString *)aField ascending:(BOOL)isAscending;
- (ARLazyFetcher *)orderBy:(NSString *)aField;
- (ARLazyFetcher *)orderByRandom;

- (ARLazyFetcher *)where:(NSString *)aCondition, ... NS_REQUIRES_NIL_TERMINATION;

- (NSArray *)fetchRecords;
- (NSArray *)fetchJoinedRecords;
- (NSUInteger)count;


#pragma mark - findBy Helpers

- (id) findById: (id) record_id  NS_SWIFT_NAME(findBy(id:));
- (id) findByKey: (id) key value: (id) value NS_SWIFT_NAME(findBy(key:value:));
- (NSArray *) findAllByKey: (id) key value: (id) value  NS_SWIFT_NAME(findAllBy(key:value:));
- (id) fetchFirstRecord NS_SWIFT_NAME(first());

- (NSArray *) findByConditions: (NSDictionary*) conditions  NS_SWIFT_NAME(find(by:));
- (NSArray *) findAllByConditions: (NSDictionary*) conditions NS_SWIFT_NAME(findAll(by:));

#pragma mark - whereFilters

- (ARLazyFetcher *)whereField:(NSString *)aField equalToValue:(id)aValue  NS_SWIFT_NAME(where(field:equalToValue:));
- (ARLazyFetcher *)whereField:(NSString *)aField notEqualToValue:(id)aValue NS_SWIFT_NAME(where(field:notEqualToValue:));
- (ARLazyFetcher *)whereField:(NSString *)aField in:(NSArray *)aValues  NS_SWIFT_NAME(where(field:in:));
- (ARLazyFetcher *)whereField:(NSString *)aField notIn:(NSArray *)aValues NS_SWIFT_NAME(where(field:notIn:));
- (ARLazyFetcher *)whereField:(NSString *)aField like:(NSString *)aPattern NS_SWIFT_NAME(where(field:like:));
- (ARLazyFetcher *)whereField:(NSString *)aField notLike:(NSString *)aPattern NS_SWIFT_NAME(where(field:notLike:));
- (ARLazyFetcher *)whereField:(NSString *)aField between:(id)startValue and:(id)endValue NS_SWIFT_NAME(where(field:between:and:));
@end
