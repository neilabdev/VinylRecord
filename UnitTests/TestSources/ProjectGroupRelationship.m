//
//  ProjectGroupRelationship.m
//  iActiveRecord
//
//  Created by Alex Denisov on 27.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ProjectGroupRelationship.h"

@implementation ProjectGroupRelationship

@dynamic projectId;
@dynamic groupId;
mapping_do(
        table_name(random_table_name)
        column_name(projectId,different_project_id)
        column_map(groupId, (@{
                @"name": @"different_group_id"
        }))
)
@end
