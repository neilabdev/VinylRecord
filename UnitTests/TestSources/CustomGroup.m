//
//  Group.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "CustomGroup.h"

@implementation CustomGroup
has_many_imp(CustomUser, users, ARDependencyDestroy)
has_many_through_imp(Project, ProjectGroupRelationship, groups, ARDependencyNullify)
column_imp(string,title)

validation_do(
              validate_uniqueness_of(title)
              )

@end
