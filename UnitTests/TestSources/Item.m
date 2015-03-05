//
// Created by James Whitfield on 9/11/14.
// Copyright (c) 2014 okolodev.org. All rights reserved.
//

#import "Item.h"


@implementation Item {}
@dynamic name;
@dynamic text;
@dynamic title;


- (VinylRecord *)mergeExistingRecord {
    Item *existingItem = [[[[[Item lazyFetcher] where:@"name == %@", self.name, nil] limit:1] fetchRecords] firstObject];
    return existingItem;
}
@end