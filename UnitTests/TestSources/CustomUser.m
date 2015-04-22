//
//  CustomUser.m
//  iActiveRecord
//
//  Created by Simon Völcker on 20.04.15.
//  Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import "CustomUser.h"

@implementation CustomUser

+ (NSString*)foreignKeyName {
    return @"aDifferentUserForeignKey";
}

- (NSString *)foreignKeyName {
    return [[self class] foreignKeyName];
}


@dynamic name;
@synthesize ignoredProperty;
//@dynamic groupId;
@dynamic birthDate;

@dynamic imageData;

belongs_to_imp(Group, group, ARDependencyDestroy)
has_many_through_imp(Project, CustomUserProjectRelationship, projects, ARDependencyDestroy)
has_many_through_imp(Animal, CustomUserAnimalRelationship, pets, ARDependencyDestroy)

validation_do(
              validate_uniqueness_of(name)
              validate_presence_of(name)
              )

indices_do(
           add_index_on(name)
           )

@end
