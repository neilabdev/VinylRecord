//
//  Animal.m
//  iActiveRecord
//
//  Created by Alex Denisov on 31.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "Animal.h"
#import "AnimalValidator.h"

@implementation Animal

column_imp(string,name)
column_imp(string,state)
column_imp(string,title)

validation_do(
    validate_field_with_validator(name, AnimalValidator)
)

mapping_do(
    column_name(name,new_name)
    column_map(state,@{
            @"name": @"new_state",
            @"some_other_mapping" : @"mapping_value"
    })
)
- (VinylRecord *)mergeExistingRecord {
    return nil;
}

@end
