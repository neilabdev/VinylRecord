//
// Created by James Whitfield on 10/16/15.
// Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import "NSDictionary+sqlRepresentation.h"


@implementation NSDictionary (sqlRepresentation)
- (NSString *)toSql {

    NSError *error = nil;
    NSData* jsonData =
                [NSJSONSerialization dataWithJSONObject:self
                                                options:NSJSONWritingPrettyPrinted
                                                  error:&error];
    NSString *text =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

   return [text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];;
}

+ (id)fromSql:(NSString *)sqlData {

    NSError *error = nil;
    NSMutableDictionary *jsonDictionary = sqlData ?
            [NSJSONSerialization JSONObjectWithData:[sqlData dataUsingEncoding:NSUTF8StringEncoding]
                                            options:NSJSONReadingMutableContainers
                                              error:&error] : nil;
    return jsonDictionary;
}

+ (NSString *)sqlType {
    return @"text";
}
@end