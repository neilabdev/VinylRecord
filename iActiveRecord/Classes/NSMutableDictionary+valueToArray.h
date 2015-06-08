//
//  NSMutableDictionary+valueToArray.h
//  iActiveRecord
//
//  Created by Alex Denisov on 22.04.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (valueToArray)

- (void)addValue:(id)aValue toArrayNamed:(NSString *)anArrayName;
- (void)setValue:(id)aValue forKey:(NSString *) key toMapNamed:(NSString *)anArrayName;
@end
