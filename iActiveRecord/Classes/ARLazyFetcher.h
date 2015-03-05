//
//  ARLazyFetcher.h
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ARJoinLeft,
    ARJoinRight,
    ARJoinInner,
    ARJoinOuter
} ARJoinType;

@class ActiveRecord;
@interface ARLazyFetcher : NSArray

- (instancetype)initWithRecord:(Class )aRecord;
- (instancetype)initWithRecord:(ActiveRecord *)entityRow
                   thatHasMany:(NSString *)aClassName through:(NSString *)aRelationsipClassName ;

    - (ARLazyFetcher *)limit:(NSInteger)aLimit;
- (ARLazyFetcher *)offset:(NSInteger)anOffset;

- (ARLazyFetcher *)only:(NSString *)aFirstParam, ... NS_REQUIRES_NIL_TERMINATION;
- (ARLazyFetcher *)except:(NSString *)aFirstParam, ... NS_REQUIRES_NIL_TERMINATION;
- (ARLazyFetcher *)join:(Class)aJoinRecord;

- (ARLazyFetcher *)join:(Class)aJoinRecord
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

- (id) findById: (id) record_id;
- (id) findByKey: (id) key value: (id) value;
- (NSArray *) findAllByKey: (id) key value: (id) value;
- (id) fetchFirstRecord;

- (NSArray *) findByConditions: (NSDictionary*) conditions;
- (NSArray *) findAllByConditions: (NSDictionary*) conditions;

#pragma mark - whereFilters

- (ARLazyFetcher *)whereField:(NSString *)aField equalToValue:(id)aValue;
- (ARLazyFetcher *)whereField:(NSString *)aField notEqualToValue:(id)aValue;
- (ARLazyFetcher *)whereField:(NSString *)aField in:(NSArray *)aValues;
- (ARLazyFetcher *)whereField:(NSString *)aField notIn:(NSArray *)aValues;
- (ARLazyFetcher *)whereField:(NSString *)aField like:(NSString *)aPattern;
- (ARLazyFetcher *)whereField:(NSString *)aField notLike:(NSString *)aPattern;
- (ARLazyFetcher *)whereField:(NSString *)aField between:(id)startValue and:(id)endValue;
@end
