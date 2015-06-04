//
//  ARSQLBuilder.h
//  iActiveRecord
//
//  Created by Alex Denisov on 17.06.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <sqlite3.h>
#import "ActiveRecordProtocol.h"
@class ActiveRecord;

@interface ARSQLBuilder : NSObject

+ (const char *)sqlOnCreateTableForRecord:(Class<ActiveRecord>)aRecord;
+ (const char *)sqlOnAddColumn:(NSString *)aColumnName toRecord:(Class<ActiveRecord>)aRecord;
+ (const char *)sqlOnCreateIndex:(NSString *)aColumnName forRecord:(Class <ActiveRecord>)aRecord;
+ (const char *)sqlOnUpdateRecord:(ActiveRecord *)aRecord;
+ (const char *)sqlOnDropRecord:(ActiveRecord *)aRecord;

@end
