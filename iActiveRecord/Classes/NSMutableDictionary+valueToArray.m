//
//  NSMutableDictionary+valueToArray.m
//  iActiveRecord
//
//  Created by Alex Denisov on 22.04.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "NSMutableDictionary+valueToArray.h"

@implementation NSMutableDictionary (valueToArray)

- (void)addValue:(id)aValue toArrayNamed:(NSString *)anArrayName {
    if (aValue == nil) {
        return;
    }

    NSMutableArray *anArray = [self objectForKey:anArrayName];
    if (anArray == nil) {
        anArray = [NSMutableArray array];
        [self setValue:anArray
         forKey:anArrayName];
    }
    [anArray addObject:aValue];
}

- (void)setValue:(id)aValue forKey:(NSString *) key toMapNamed:(NSString *)anArrayName {
    if (aValue == nil) {
        return;
    }

    NSMutableDictionary *anMap = [self objectForKey:anArrayName];
    if (anMap == nil) {
        anMap = [NSMutableDictionary dictionary];
        [self setValue:anMap
                forKey:anArrayName];
    }
   // [anMap addObject:aValue];
    [anMap setValue:aValue forKey:key];
}

@end
