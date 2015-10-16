//
// Created by James Whitfield on 10/16/15.
// Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (sqlRepresentation)
- (NSString *)toSql ;
+ (id)fromSql:(NSString *)sqlData;
@end