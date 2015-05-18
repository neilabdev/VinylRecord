//
// Created by James Whitfield on 4/1/14.
// Copyright (c) 2014 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VinylRecord.h"


@interface UserAnimalRelationship : VinylRecord
@property (nonatomic,retain) NSNumber *animalId;
@property (nonatomic,retain) NSNumber *customUserForeignKey;

@end