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
    return [self stringByReplacingOccurrencesOfString:@"'" withString:@"''"]; //SQL values should be enclosed in (') and excapted with (''). Standard SQL.
}

- (NSString *)toColumnName {
    objc_setAssociatedObject(self, &FIELD_KEY, [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN);
    return self;
}

- (NSString *)stringAsColumnName {
    NSString *columnString = [NSString stringWithString:self];
    return [columnString toColumnName];
}

- (BOOL) isColumnName {
    NSNumber *truth = objc_getAssociatedObject(self, &FIELD_KEY);
    return [truth boolValue];
}

//+ (NSString *)sqlType {
//    return @"text";
//}

@end
