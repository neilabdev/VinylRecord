//
//  UserProjectRelationship.h
//  iActiveRecord
//
//  Created by Alex Denisov on 22.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "VinylRecord.h"

@interface CustomUserProjectRelationship : VinylRecord

@property (nonatomic, retain) NSNumber *aDifferentUserForeignKey;
@property (nonatomic, retain) NSNumber *projectId;

@end
