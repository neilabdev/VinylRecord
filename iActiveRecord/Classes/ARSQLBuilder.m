//
//  ARSQLBuilder.m
//  iActiveRecord
//
//  Created by Alex Denisov on 17.06.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ARSQLBuilder.h"
#import "ActiveRecord_Private.h"
#import "ARColumn.h"
#import "NSString+sqlRepresentation.h"


@implementation ARSQLBuilder

+ (const char *)sqlOnUpdateRecord:(ActiveRecord *)aRecord {
    NSSet *changedColumns = [NSSet setWithSet: [aRecord changedColumns]];
    NSInteger columnsCount = changedColumns.count;
    if (columnsCount == 0) {
        return NULL;
    }
    NSMutableArray *columnValues = [NSMutableArray arrayWithCapacity:columnsCount];
    NSEnumerator *columnsIterator = [changedColumns objectEnumerator];
    for (int index = 0; index < columnsCount; index++) {
        ARColumn *column = [columnsIterator nextObject];   //FIXME: NSFastEnumerationMutationHandler
        NSString *value = [column sqlValueForRecord:aRecord];
        NSString *updater = [NSString stringWithFormat:
                             @"\"%@\"='%@'",
                             column.mappingName,
                             TO_SQL_VALUE(value)];
        [columnValues addObject:updater];
    }
    NSString *sqlString = [NSString stringWithFormat:@"UPDATE \"%@\" SET %@ WHERE id = %@",
                           [aRecord tableName],
                           [columnValues componentsJoinedByString:@","],
                           aRecord.id];
    return [sqlString UTF8String];
}

+ (const char *)sqlOnDropRecord:(ActiveRecord *)aRecord {
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM \"%@\" WHERE id = %@",
                           [aRecord tableName], aRecord.id];
    return [sqlString UTF8String];
}

+ (const char *)sqlOnCreateTableForRecord:(Class <ActiveRecord>)aRecord {
    NSMutableString *sqlString = [NSMutableString stringWithFormat:
                                  @"CREATE TABLE \"%@\"(id integer primary key unique",
                                  [aRecord tableName]];
    for (ARColumn *column in [aRecord columns]) {
        if (![column.columnName isEqualToString:@"id"]) {
            [sqlString appendFormat:@",\"%@\" %s",
             column.mappingName, [column sqlType]];
        }
    }
    [sqlString appendFormat:@")"];
    return [sqlString UTF8String];
}

+ (const char *)sqlOnAddColumn:(NSString *)aColumnName toRecord:(Class <ActiveRecord>)aRecord {
    NSMutableString *sqlString = [NSMutableString stringWithFormat:
                                  @"ALTER TABLE \"%@\" ADD COLUMN ",
                                  [aRecord tableName]];
    ARColumn *column = [aRecord performSelector:@selector(columnNamed:) withObject:aColumnName];
    [sqlString appendFormat:@"\"%@\" %s",
     column.mappingName, [column sqlType]];
    return [sqlString UTF8String];
}

+ (const char *)sqlOnCreateIndex:(NSString *)aColumnName forRecord:(Class <ActiveRecord>)aRecord {
    ARColumn *column = [aRecord performSelector:@selector(columnNamed:) withObject:aColumnName];
    NSString *sqlString = [NSString stringWithFormat:
                           @"CREATE INDEX IF NOT EXISTS index_%@ ON \"%@\" (\"%@\")",
                                    column.mappingName,
                           [aRecord tableName],
                           column.mappingName];
    return [sqlString UTF8String];
}

@end
