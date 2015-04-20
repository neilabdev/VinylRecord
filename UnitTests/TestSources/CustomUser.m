//
//  CustomUser.m
//  iActiveRecord
//
//  Created by Simon Völcker on 20.04.15.
//  Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import "CustomUser.h"

@implementation CustomUser

+ (NSString*)foreignKeyName {
    return @"myCustomForeignKeyName";
}

- (NSString *)foreignKeyName {
    return [[self class] foreignKeyName];
}

@end