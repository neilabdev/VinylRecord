//
//  DifferentTableName.h
//  iActiveRecord
//
//  Created by Alex Denisov on 07.05.13.
//  Copyright (c) 2013 okolodev.org. All rights reserved.
//

#import "VinylRecord.h"

@interface DifferentTableName : VinylRecord
belongs_to_dec(User, user, ARDependencyDestroy)
column_dec(key,customUserForeignKey)
column_dec(string,title)
@end
