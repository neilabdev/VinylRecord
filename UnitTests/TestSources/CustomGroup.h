//
//  Group.h
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "VinylRecord.h"

/*
 CustomGroup has many CustomUsers
 */

@interface CustomGroup : VinylRecord
has_many_dec(CustomUser, users, ARDependencyDestroy)
has_many_through_dec(Project, ProjectGroupRelationship, groups, ARDependencyNullify)
column_dec(string,title)
@end
