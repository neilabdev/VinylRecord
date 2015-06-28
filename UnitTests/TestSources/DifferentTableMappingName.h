//
// Created by ghost on 6/28/15.
// Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VinylRecord.h"
@interface DifferentTableMappingName  : VinylRecord
belongs_to_dec(User, user, ARDependencyDestroy)
column_dec(string,title)
@end
