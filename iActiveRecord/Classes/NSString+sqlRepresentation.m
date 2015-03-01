//
//  NSString+sqlRepresentation.m
//  iActiveRecord
//
//  Created by Alex Denisov on 17.01.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <objc/runtime.h>
#import "NSString+sqlRepresentation.h"

@implementation NSString (sqlRepresentation)
static char FIELD_KEY;
+ (id)fromSql:(NSString *)sqlData {
    return sqlData;
}

- (NSString *)toSql {
    return self;
}

- (NSString *)stringAsColumnName { //toColumnName // isColumnName
    NSString *columnString = [NSString stringWithString:self];
    objc_setAssociatedObject(columnString, &FIELD_KEY, [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN);
    return columnString; /// [@"foo" toField]
}

- (BOOL) isColumnName {
    NSNumber *truth = objc_getAssociatedObject(self, &FIELD_KEY);
    return [truth boolValue];
}

//+ (NSString *)sqlType {
//    return @"text";
//}

@end
