//
//  Issue.m
//  iActiveRecord
//
//  Created by Alex Denisov on 27.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.po
//

#import "Issue.h"

@implementation Issue
@dynamic title;
belongs_to_imp(Project, project, ARDependencyNullify)

mapping_do(
        column_name(projectId,different_project_id)
        column_map(title, (@{
                @"name": @"different_title",
                @"length": @(255) // FYI, this one doesn't do anything, but demonstrates how mapping can be expanding for ALL DB constraints.
        }))
)
@end
