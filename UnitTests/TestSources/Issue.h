//
//  Issue.h
//  iActiveRecord
//
//  Created by Alex Denisov on 27.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "VinylRecord.h"

@interface Issue : VinylRecord
belongs_to_dec(Project, project, ARDependencyNullify)
//owned_by_dec
//belonging_to_dec(Project,project,ARDependencyNullify)
//belongs_in_dec(Project,project,ARDependencyNullify)
//column_dec(key,projectId)
column_dec(string,title)
@end
