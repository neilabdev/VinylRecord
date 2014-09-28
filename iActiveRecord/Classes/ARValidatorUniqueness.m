//
//  ARValidatorUniqueness.m
//  iActiveRecord
//
//  Created by Alex Denisov on 31.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ARValidatorUniqueness.h"
#import "ARLazyFetcher.h"
#import "ARErrorHelper.h"
#import <objc/runtime.h>
#import "ActiveRecord_Private.h"
#import "ARColumn.h"

@implementation ARValidatorUniqueness

- (NSString *)errorMessage {
    return kARFieldAlreadyExists;
}

- (BOOL)validateField:(NSString *)aField ofRecord:(ActiveRecord *)record {
    
    BOOL founded = NO;
    for (ARColumn *column in record.changedColumns) {
        if ([column.columnName isEqualToString:aField]) {
            founded = YES;
            break;
        }
    }
    
    if (!founded) {
        return YES;
    }
    
    NSString *recordName = [[record class] description];
    id aValue =  [record valueForUndefinedKey: aField];
    ARLazyFetcher *fetcher = [[ARLazyFetcher alloc] initWithRecord:NSClassFromString(recordName)];
    if([record isNewRecord])
        [fetcher where:@"%@ = %@", aField, aValue, nil];
    else
        [fetcher where:@"%@ = %@ and id != %@", aField, aValue,record.id, nil];  //updates should pass
    NSInteger count = [fetcher count];
    if (count) {
        return NO;
    }
    return YES;
}

@end
