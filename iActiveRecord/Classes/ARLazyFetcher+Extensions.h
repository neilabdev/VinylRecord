//
// Created by James Whitfield on 3/18/14.
// Copyright (c) 2014 NEiLAB, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARLazyFetcher.h"
//TODO: Extract from category and Incorpate in ARLazyFetcher class.
@interface ARLazyFetcher (Extensions)

- (id) findById: (id) record_id;
- (id) findByKey: (id) key value: (id) value;
- (NSArray *) findAllByKey: (id) key value: (id) value;
- (id) fetchFirstRecord;

- (NSArray *) findByConditions: (NSDictionary*) conditions;
- (NSArray *) findAllByConditions: (NSDictionary*) conditions;
@end