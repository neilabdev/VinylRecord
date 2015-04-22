//
//  CustomUser.h
//  iActiveRecord
//
//  Created by Simon Völcker on 20.04.15.
//  Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import "VinylRecord.h"

@interface CustomUser : VinylRecord

#pragma mark - Foreign Key Name
+ (NSString *)foreignKeyName;
- (NSString *)foreignKeyName;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSArray *ignoredProperty;
//  used in belongs to relationship
//@property (nonatomic, retain) NSNumber *groupId;

@property (nonatomic, retain) NSData *imageData;
@property (nonatomic, retain) NSDate *birthDate;
belongs_to_dec(Group, group, ARDependencyDestroy)
has_many_through_dec(Project, CustomUserProjectRelationship, projects, ARDependencyDestroy)
has_many_through_dec(Animal, CustomUserAnimalRelationship, pets, ARDependencyDestroy)

@end
