//
//  Animal.h
//  iActiveRecord
//
//  Created by Alex Denisov on 31.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "VinylRecord.h"
#import "ARSynchronizationProtocol.h"

@interface Animal : VinylRecord <ARSynchronizationProtocol>
column_dec(string, name)
column_dec(string, state)
column_dec(string, title)
@end
