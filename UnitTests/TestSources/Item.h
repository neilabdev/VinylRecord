//
// Created by James Whitfield on 9/11/14.
// Copyright (c) 2014 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VinylRecord.h"
#import "ARSynchronizationProtocol.h"

@interface Item : VinylRecord     <ARSynchronizationProtocol>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *title;


@end