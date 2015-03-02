//
//  ProjectGroupRelationship.h
//  iActiveRecord
//
//  Created by Alex Denisov on 27.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "VinylRecord.h"

@interface ProjectGroupRelationship : VinylRecord

@property (nonatomic, retain) NSNumber *projectId;
@property (nonatomic, retain) NSNumber *groupId;

@end
