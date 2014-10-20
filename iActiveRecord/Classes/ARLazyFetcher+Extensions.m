//
// Created by James Whitfield on 3/18/14.
// Copyright (c) 2014 NEiLAB, Inc. All rights reserved.
//

#import "ARLazyFetcher+Extensions.h"



@implementation ARLazyFetcher (Extensions)
- (id) findById: (id) record_id {
    NSArray *results = [[[self where:@" id = %@", record_id,nil] limit:1] fetchRecords];
    return [results firstObject];
}

- (id) findByKey: (id) key value: (id) value {
    NSString *condition = [NSString stringWithFormat:@" %@ = %%%@ ",key,@"@"];
    NSArray *results = [[[self where: condition, value,nil] limit:1] fetchRecords];
    return [results firstObject];
}

- (NSArray *) findAllByKey: (id) key value: (id) value {
    NSArray *results = [[self where: [NSString stringWithFormat:@" %@ = %%%@ ",key,@"@"], value,nil]  fetchRecords];
    return results;
}

- (NSArray *) findByConditions: (NSDictionary*) conditions {
    NSMutableArray *results = [NSMutableArray array];
    return results;
}

- (NSArray *) findAllByConditions: (NSDictionary*) conditions {
    NSMutableArray *results = [NSMutableArray array];
    return results;
}

- (id) fetchFirstRecord {
    ActiveRecord *foundRecord = [[[self limit:1] fetchRecords] firstObject];
    return foundRecord;
}

@end