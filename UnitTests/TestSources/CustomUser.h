//
//  CustomUser.h
//  iActiveRecord
//
//  Created by Simon Völcker on 20.04.15.
//  Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import "User.h"

@interface CustomUser : User

#pragma mark - Foreign Key Name
+ (NSString *)foreignKeyName;
- (NSString *)foreignKeyName;

@end
