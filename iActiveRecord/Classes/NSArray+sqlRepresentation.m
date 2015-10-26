//
// Created by James Whitfield on 10/16/15.
// Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import "NSArray+sqlRepresentation.h"


@implementation NSArray (sqlRepresentation)
- (NSString *)toSql {
    NSError *error = nil;
    NSData* jsonData =
            [NSJSONSerialization dataWithJSONObject:self
                                            options:NSJSONWritingPrettyPrinted
                                              error:&error] ;
    NSString *text =   [[NSString alloc] initWithData:jsonData
                                     encoding:NSUTF8StringEncoding];
    return text;
}

+ (id)fromSql:(NSString *)sqlData {
    NSString *jsonString =sqlData;
    NSError *error = nil;
    NSMutableArray *jsonArray = jsonString ?
            [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                            options:NSJSONReadingMutableContainers
                                              error:&error] : nil;
    return jsonArray;
}


+ (NSString *)sqlType {
    return @"text";
}
@end