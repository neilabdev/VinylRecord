//
//  DifferentTableName.m
//  iActiveRecord
//
//  Created by Alex Denisov on 07.05.13.
//  Copyright (c) 2013 okolodev.org. All rights reserved.
//

#import "DifferentTableName.h"

@implementation DifferentTableName

belongs_to_imp(User, user, ARDependencyDestroy)
//column_imp(key,userId)
column_imp(string,title)

+ (NSString *)recordName {
    return @"different_table_name";
}

@end
