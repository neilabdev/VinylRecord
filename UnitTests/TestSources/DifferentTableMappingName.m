//
// Created by ghost on 6/28/15.
// Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import "DifferentTableMappingName.h"


@implementation DifferentTableMappingName
belongs_to_imp(User, user, ARDependencyDestroy)
column_imp(string,title)
mapping_do(
        table_name(different_table_name_with_mapping)
)
@end
