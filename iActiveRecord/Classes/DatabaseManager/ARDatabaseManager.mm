//
//  ARDatabaseManager.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ARDatabaseManager.h"
#import "ActiveRecord_Private.h"
#import "class_getSubclasses.h"
#import "sqlite3_unicode.h"
#import "ARColumn_Private.h"
#import "ARSQLBuilder.h"
#import "ARSchemaManager.h"
#import "VinylRecord.h"


@implementation ARDatabaseConnection {
@private
    sqlite3 *database;
    __block NSInteger recyles;
}
@synthesize database = database;

+ (dispatch_queue_t)connectionQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceTokenQueue;
    dispatch_once(&onceTokenQueue, ^{
        queue = dispatch_queue_create("com.neilab.vinylrecord", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

- (id)initWithConfiguration:(ARConfiguration *)config {
    if (self = [super init]) {
        database = NULL;
        recyles = config.recycleInterval;
        self.configuration = config;
        [self openConnection];
    }

    return self;
}

+ (instancetype)connectionWithConfiguration:(ARConfiguration *)config {
    id connection = [[ARDatabaseConnection alloc] initWithConfiguration:config];
    return connection;
}

- (void) releaseConnection {
    if (database) {
        int rc = sqlite3_close(database);
        if (rc == SQLITE_BUSY) {
            NSLog(@"SQLITE_BUSY: not all statements cleanly finalized");

            sqlite3_stmt *stmt;
            while ((stmt = sqlite3_next_stmt(database, 0x00)) != 0) {
                NSLog(@"finalizing stmt");
                sqlite3_finalize(stmt);
            }
            rc = sqlite3_close(database);
        }

        if (rc != SQLITE_OK) {
            NSLog(@"close not OK.  rc=%d", rc);
        }

        database = NULL;
    }
}

- (void)openConnection {
    dispatch_sync([ARDatabaseConnection connectionQueue], ^{
        if(database) {
            if(recyles != ARConfigurationRecycleIntervalNever && --recyles==0) {
                recyles = self.configuration.recycleInterval;
                [self releaseConnection];
                NSLog(@"recycling connection");
            }
        }

        if (!database && SQLITE_OK != sqlite3_open_v2([self.configuration.databasePath UTF8String],
                &database, self.configuration.flags |SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE , NULL)) {
            NSLog(@"Couldn't open database connection: %s", sqlite3_errmsg(database));
            database = NULL;
        }
    });
}

- (void)closeConnection {
    dispatch_sync([ARDatabaseConnection connectionQueue], ^{
        [self releaseConnection];
    });
}

- (void) recycleConnection {
    [self openConnection];
}

- (void)dealloc {
    [self closeConnection];
}
@end

@interface ARDatabaseManager ()
    @property(nonatomic, retain) NSMutableDictionary *connections;
@end

@implementation ARDatabaseManager

static NSArray *records = nil;

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (void)applyConfiguration:(ARConfiguration *)configuration {
    if(!self.configuration)
        self.configuration = configuration;
    [self createDatabase];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        sqlite3_unicode_load();
    }

    return self;
}

- (void)dealloc {
    sqlite3_unicode_free();
}


- (ARDatabaseConnection *) getCurrentConnection {
    NSThread *currentThread = self.configuration.enableThreadPool ? [NSThread currentThread] : [NSThread mainThread];
    NSMutableDictionary *threadDictionary = [currentThread threadDictionary];
    ARDatabaseConnection *currentConnection = [threadDictionary objectForKey:@"ARDatabaseConnection"];

    if(!currentConnection) {
        [threadDictionary setObject:currentConnection=[ARDatabaseConnection connectionWithConfiguration:self.configuration] forKey:@"ARDatabaseConnection"];
    } else {
        [currentConnection recycleConnection];
    }

    return currentConnection;
}


- (void)createDatabase {
    NSString *databasePath = self.configuration.databasePath;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
     //   [self openConnection];
        [self appendMigrations];
        return;
    }
    
    [[NSFileManager defaultManager] createFileAtPath:databasePath contents:nil attributes:nil];
    
   // [self openConnection];
    [self createTables];
}

- (void)clearDatabase {
    NSArray *entities =  [self records];
    for (Class Record in entities) {
        [Record performSelector:@selector(dropAllRecords)];
    }
}

- (void)createTables {
    NSArray *entities = [self records];
    for (Class Record in entities) {
        [self createTable:Record];
    }
    [self createIndices];
}

- (void)createTable:(Class)aRecord {
    const char *sqlQuery = [ARSQLBuilder sqlOnCreateTableForRecord:aRecord];
    [self executeSqlQuery:sqlQuery];
}

- (void)appendMigrations {
    if (!self.configuration.isMigrationsEnabled) {
        return;
    }
    
    NSArray *existedTables = [self tables];
    NSArray *existedViews = [self views];
    NSArray *allExisting = [existedViews arrayByAddingObjectsFromArray: existedTables];
    NSArray *describedTables = [self records];
    
    for (Class tableClass in describedTables) {
        NSString *tableName = [tableClass recordName];
        if (![allExisting containsObject:tableName] ) {
            //only create table if there is no table or view for ist
            [self createTable:tableClass];
        } else {

            NSArray *existedColumns = [self columnsForTable:tableName];
            
            NSArray *describedProperties = [tableClass performSelector:@selector(columns)];
            NSMutableArray *describedColumns = [NSMutableArray array];
            
            for (ARColumn *column in describedProperties) {
                [describedColumns addObject:column.mappingName];
            }
            
            for (NSString *column in describedColumns) {
                if ([existedColumns containsObject:column]) {
                    continue;
                }
                if([existedViews containsObject: tableName])
                {
                    NSLog(@"'%@' is a view and column '%@' is missing. Cannot auto-migrate view tables !!! You have to adapt the view manually.", tableName, column, nil);
                }

                const char *sql = [ARSQLBuilder sqlOnAddColumn:column toRecord:tableClass];
                [self executeSqlQuery:sql];
            }
        }
    }
    [self createIndices];
}

- (NSArray *)columnsForTable:(NSString *)aTableName {
    __block NSMutableArray *resultArray = nil;
    
    dispatch_sync([self activeRecordQueue], ^{
        ARDatabaseConnection *connection = [self getCurrentConnection];
        NSString *sqlString = [NSString stringWithFormat:@"PRAGMA table_info('%@')", aTableName];
        
        sqlite3_stmt *statement;
        
        const char *sqlQuery = [sqlString UTF8String];
        
        if (sqlite3_prepare_v2(connection.database, sqlQuery, -1, &statement, NULL) != SQLITE_OK) {
            NSLog( @"%s", sqlite3_errmsg(connection.database) );
            return;
        }
        
        resultArray = [NSMutableArray array];
        while (sqlite3_step(statement) == SQLITE_ROW) {
            const unsigned char *pszValue = sqlite3_column_text(statement, 1);
            if (pszValue) {
                [resultArray addObject:[NSString stringWithUTF8String:(const char *)pszValue]];
            }
        }
        
    });
    return resultArray;
}

//  select tbl_name from sqlite_master where type='table' and name not like 'sqlite_%'
- (NSArray *)tables {
    return [self sqliteItemsWithType: @"table"];
}

- (NSArray*) views {
    return [self sqliteItemsWithType: @"view"];
}

//  select tbl_name from sqlite_master where type='table' and name not like 'sqlite_%'
- (NSArray *) sqliteItemsWithType: (NSString*) type {
    __block NSMutableArray *resultArray = nil;
    
    dispatch_sync([self activeRecordQueue], ^{
        ARDatabaseConnection *connection = [self getCurrentConnection];
        char **results;
        int nRows;
        int nColumns;
        const char *pszSql = [[NSString stringWithFormat: @"select tbl_name from sqlite_master where type='%@' and name not like 'sqlite_%'", type, nil] UTF8String];
        if ( SQLITE_OK != sqlite3_get_table(connection.database,
                                            pszSql,
                                            &results,
                                            &nRows,
                                            &nColumns,
                                            NULL) )
        {
            NSLog( @"Couldn't retrieve data from database: %s", sqlite3_errmsg(connection.database) );
            return;
        }
        resultArray = [NSMutableArray arrayWithCapacity:nRows++];
        for (int i = 0; i < nRows - 1; i++) {
            for (int j = 0; j < nColumns; j++) {
                int index = (i + 1) * nColumns + j;
                [resultArray addObject:[NSString stringWithUTF8String:results[index]]];
            }
        }
        sqlite3_free_table(results);

    });
    return resultArray;
}



- (NSString *)tableName:(NSString *)modelName {
    return modelName;
}



- (BOOL)executeSqlQuery:(const char *)anSqlQuery {
    __block BOOL result = YES;
    dispatch_sync([self activeRecordQueue], ^{
        ARDatabaseConnection *connection = [self getCurrentConnection];
        if ( SQLITE_OK != sqlite3_exec(connection.database, anSqlQuery, NULL, NULL, NULL) ) {
            NSLog( @"Couldn't execute query %s : %s", anSqlQuery, sqlite3_errmsg(connection.database) );
            result = NO;
        }

    });
    return result;
}

- (NSArray *)allRecordsWithName:(NSString *)aName withSql:(NSString *)aSqlRequest {
    __block NSMutableArray *resultArray = nil;
    
    dispatch_sync([self activeRecordQueue], ^{
        ARDatabaseConnection *connection = [self getCurrentConnection];
        sqlite3_stmt *statement;
        const char *sqlQuery = [aSqlRequest UTF8String];

        if (sqlite3_prepare_v2(connection.database, sqlQuery, -1, &statement, NULL) != SQLITE_OK) {
            NSLog( @"%s", sqlite3_errmsg(connection.database) );
            return;
        }
        
        resultArray = [NSMutableArray array];
        Class <ActiveRecordPrivateMethods>  Record = NSClassFromString(aName);
        BOOL hasColumns = NO;
        NSMutableArray *columns = nil;
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int columnsCount = sqlite3_column_count(statement);
            if (columns == nil) {
                columns = [NSMutableArray arrayWithCapacity:columnsCount];
            }
            
            ActiveRecord *record = [Record persistedRecord];
            
            for (int columnIndex = 0; columnIndex < columnsCount; columnIndex++) {
                
                NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(statement, columnIndex)];
               
                if (!hasColumns) {
                    ARColumn* column = [Record performSelector:@selector(columnNamed:) withObject:columnName];
                    if(column == nil){
                        /*if working with views, sqlite3_column_name(statement, columnIndex) currently returns fully qualified column names
                        * the follwoing code dissembles the fully qualified name to have only the raw column name itself self for the lookup in the
                        * record columns. Though it returns the correct column.
                        */
                        NSArray* array = [columnName componentsSeparatedByString: @"."];
                        NSString* newColumnName = [array.lastObject stringByReplacingOccurrencesOfString: @"\"" withString: @""];
                        column = [Record performSelector:@selector(columnNamed:)
                                              withObject:newColumnName];
                    }
                    if(column == nil){
                        //our recovery operation for the column name failed
                        sqlite3_finalize(statement);
                        @throw [ARException exceptionWithName: @"ColumnNotFoundInRecord"
                                                       reason: [NSString stringWithFormat: @"Column %@ could not be found in record %@", columnName, [Record recordName],nil  ]
                                                     userInfo: nil];
                    }
                    columns[columnIndex] = column;
                }
                ARColumn *column = columns[columnIndex];
                
                id value = nil;
                
                int columnType = sqlite3_column_type(statement, columnIndex);
                
                switch (columnType) {
                    case SQLITE_INTEGER:
                        value = @( sqlite3_column_int(statement, columnIndex) );
                        break;
                    case SQLITE_FLOAT: {
                        value = @( sqlite3_column_double(statement, columnIndex) );
                    } break;
                    case SQLITE_BLOB: {
                        value = [NSData dataWithBytes:sqlite3_column_blob(statement, columnIndex)
                                               length:sqlite3_column_bytes(statement, columnIndex)];
                    } break;
                    case SQLITE3_TEXT: {
                        value = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, columnIndex)];
                        if ([column.columnClass isSubclassOfClass:[NSDecimalNumber class]]) {
                            value = [NSDecimalNumber decimalNumberWithString:value];
                        }
                    } break;
                    case SQLITE_NULL: {
                        value = nil;
                    } break;
                    default:
                        NSLog(@"UNKOWN COLUMN TYPE %d", columnType);
                        break;
                }
                [record setValue:value forColumn:column];
            }
            [record resetChanges];
            [resultArray addObject:record];
            hasColumns = YES;
        }
        sqlite3_finalize(statement);

    });
    
    return resultArray;
}

- (NSArray *)joinedRecordsWithSql:(NSString *)aSqlRequest {
    __block NSMutableArray *resultArray = nil;
    
    dispatch_sync([self activeRecordQueue], ^{
        ARDatabaseConnection *connection = [self getCurrentConnection];
        sqlite3_stmt *statement;
        
        const char *sqlQuery = [aSqlRequest UTF8String];
        
        if (sqlite3_prepare_v2(connection.database, sqlQuery, -1, &statement, NULL) != SQLITE_OK) {
            NSLog( @"%s", sqlite3_errmsg(connection.database) );
            return;
        }
        
        resultArray = [NSMutableArray array];
        BOOL cachesLoaded = NO;
        
        NSMutableDictionary *recordsDictionary;
        
        NSMutableArray *columns = nil;
        Class *recordClasses = NULL;
        NSMutableArray *recordNames = nil;
        NSMutableArray *propertyNames = nil;
        NSString *propertyName = nil;
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int columnsCount = sqlite3_column_count(statement);
            if (columns == nil) {
                columns = [NSMutableArray arrayWithCapacity:columnsCount];
            }
            
            if (!recordClasses) {
                recordClasses = (Class *)malloc(sizeof(Class) * columnsCount);
            }
            
            if (!recordNames) {
                recordNames = [NSMutableArray arrayWithCapacity:columnsCount];
            }
            
            if (!propertyNames) {
                propertyNames = [NSMutableArray arrayWithCapacity:columnsCount];
            }
            
            recordsDictionary = [NSMutableDictionary dictionary];
            
            for (int columnIndex = 0; columnIndex < columnsCount; columnIndex++) {
                
                NSString *recordName = nil;
                
                NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(statement, columnIndex)];
                
                if (!cachesLoaded) {
                    NSArray *splitHeader = [columnName componentsSeparatedByString:@"#"];
                    [recordNames addObject:[splitHeader objectAtIndex:0]];
                    [propertyNames addObject:[splitHeader objectAtIndex:1]];
                    
                    recordClasses[columnIndex] = NSClassFromString([recordNames lastObject]);
                    ARColumn *column = [recordClasses[columnIndex] performSelector:@selector(columnNamed:)
                                                                        withObject:[propertyNames lastObject]];
                    [columns addObject:column];
                }
                recordName = [recordNames objectAtIndex:columnIndex];
                propertyName = [propertyNames objectAtIndex:columnIndex];
                ARColumn *column = columns[columnIndex];
                
                id value = nil;
                
                int columnType = sqlite3_column_type(statement, columnIndex);
                
                switch (columnType) {
                    case SQLITE_INTEGER:
                        value = @( sqlite3_column_int(statement, columnIndex) );
                        break;
                    case SQLITE_FLOAT: {
                        value = @( sqlite3_column_double(statement, columnIndex) );
                    } break;
                    case SQLITE_BLOB: {
                        value = [NSData dataWithBytes:sqlite3_column_blob(statement, columnIndex)
                                               length:sqlite3_column_bytes(statement, columnIndex)];
                    } break;
                    case SQLITE3_TEXT: {
                        value = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, columnIndex)];
                        if ([column.columnClass isSubclassOfClass:[NSDecimalNumber class]]) {
                            value = [NSDecimalNumber decimalNumberWithString:value];
                        }
                    } break;
                    case SQLITE_NULL: {
                        value = nil;
                    } break;
                    default:
                        NSLog(@"UNKOWN COLUMN TYPE %d", columnType);
                        break;
                }
                ActiveRecord *currentRecord = [recordsDictionary valueForKey:recordName];
                if (currentRecord == nil) {
                    Class <ActiveRecordPrivateMethods> Record = recordClasses[columnIndex];
                    currentRecord = [Record persistedRecord];
                    [recordsDictionary setValue:currentRecord
                                         forKey:recordName];
                }
                
                [currentRecord setValue:value forColumn:column];
            }
            cachesLoaded = YES;
            [resultArray addObject:recordsDictionary];
        }
        sqlite3_finalize(statement);

    });
    
    return resultArray;
}

- (NSInteger)countOfRecordsWithName:(NSString *)aName {
#warning remove
    NSString *aSqlRequest = [NSString stringWithFormat:
                             @"SELECT count(id) FROM '%@'",
                             [self tableName:aName]];
    return [self functionResult:aSqlRequest];
}

- (NSNumber *)getLastId:(NSString *)aRecordName {
#warning remove
    NSString *aSqlRequest = [NSString stringWithFormat:@"select MAX(id) from '%@'", aRecordName];
    NSInteger res = [self functionResult:aSqlRequest];
    return [NSNumber numberWithInt:res];
}

- (NSInteger)functionResult:(NSString *)anSql {
#warning remove
    __block NSInteger resId = 0;
    
    dispatch_sync([self activeRecordQueue], ^{
        ARDatabaseConnection *connection = [self getCurrentConnection];
        char **results;
        int nRows;
        int nColumns;
        const char *pszSql = [anSql UTF8String];
        if ( SQLITE_OK != sqlite3_get_table(connection.database,
                                            pszSql,
                                            &results,
                                            &nRows,
                                            &nColumns,
                                            NULL) )
        {
            NSLog(@"%@", anSql);
            NSLog( @"Couldn't retrieve data from database: %s", sqlite3_errmsg(connection.database) );
            return;
        }
        if (nRows == 0 || nColumns == 0) {
            resId = -1;
        } else {
            resId = [[NSString stringWithUTF8String:results[1]] integerValue];
        }
        
        sqlite3_free_table(results);

    });
    
    return resId;
}

- (NSInteger)saveRecord:(ActiveRecord *)aRecord {
    NSDate *originalUpdatedAt = aRecord.updatedAt;
    NSDate *originalCreatedAt = aRecord.createdAt;
    NSSet *changedColumns = [aRecord changedColumns];
    NSInteger columnsCount = changedColumns.count;
    __block int result = 0;

    if(columnsCount) { //TODO: refactor
        if(!originalUpdatedAt)
            aRecord.updatedAt = [NSDate dateWithTimeIntervalSinceNow:0];

        if(!aRecord.createdAt)
            aRecord.createdAt = [NSDate dateWithTimeIntervalSinceNow:0];

        changedColumns = [NSSet setWithSet: [aRecord changedColumns]];
        columnsCount = changedColumns.count;
    }

    if(columnsCount)
    dispatch_sync([self activeRecordQueue], ^{
        ARDatabaseConnection *connection = [self getCurrentConnection];
        sqlite3_stmt *stmt;
        const char *sql;
        
        NSString *valueMapping = [@"" stringByPaddingToLength: (columnsCount) * 2 - 1
                                                   withString: @"?,"
                                              startingAtIndex: 0];
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:columnsCount];
        NSArray *orderedColumns = [changedColumns allObjects];  //Used to prevent enumeration execeptions should columns change.

        for (ARColumn *column in orderedColumns) {
            [columns addObject:[NSString stringWithFormat:@"'%@'", column.mappingName]];
        }
        
        NSString *sqlString = [NSString stringWithFormat:
                               @"INSERT INTO '%@'(%@) VALUES(%@)",
                               [aRecord recordName],
                               [columns componentsJoinedByString:@","],  //FIXME: Sometimes query generates because no changed columns: "INSERT INTO 'Subscriber'() VALUES(?,?,?,?,?,?)"
                               valueMapping];
        
        sql = [sqlString UTF8String];

        if(SQLITE_OK != sqlite3_prepare_v2(connection.database, sql, strlen(sql), &stmt, NULL)) {
            NSLog( @"Couldn't save record to database: %s", sqlite3_errmsg(connection.database));
            return;
        }

        int columnIndex = 1;
        for (ARColumn *column in orderedColumns) {
            id value = [aRecord valueForColumn:column];
            
            switch (column.columnType) {
                case ARColumnTypeComposite:
//                    if ([value isKindOfClass:[NSDecimalNumber class]]) {
//                        sqlite3_bind_text(stmt, columnIndex, [[value toSql] UTF8String], -1, SQLITE_TRANSIENT);
                        //NOTE: NSNumber must come after NSDecimalNumber because NSDecimalNumber is a
                        //subclass of NSNumber
//                    } else
//                    if ([value isKindOfClass:[NSNumber class]]) {
//                        sqlite3_bind_int(stmt, columnIndex, [value integerValue]);
//                    } else
                    if ([value isKindOfClass:[NSData class]]) {
                        NSData *data = value;
                        sqlite3_bind_blob(stmt, columnIndex, [data bytes], [data length], NULL);
                    } else {
                        NSLog(@"UNKNOWN COLUMN !!1 %@ %@", value, column.mappingName);
                    }
                    
                    break;
                default:
                    column.internal->bind(stmt, columnIndex, value);
                    break;
            }
            columnIndex++;
        }

        if(SQLITE_DONE == sqlite3_step(stmt) &&
                SQLITE_OK == sqlite3_finalize(stmt)) {
            result = sqlite3_last_insert_rowid(connection.database);
        } else {
            int error = sqlite3_finalize(stmt);
            NSLog( @"Couldn't save record to database: %s", sqlite3_errmsg(connection.database) );

            switch(error) {
                case SQLITE_CONSTRAINT:
                    //TODO: Code should be added here to detect which column failed and added to model errors. JKW
                    break;
            }
        }

    });

    if(result == 0) {
        aRecord.createdAt = originalCreatedAt;
        aRecord.updatedAt = originalUpdatedAt;
    }

    return result;
}


- (NSInteger)updateRecord:(ActiveRecord *)aRecord {
    NSDate *originalUpdatedAt = aRecord.updatedAt;
    NSDate *originalCreatedAt = aRecord.createdAt;
    NSSet *changedColumns = [aRecord changedColumns];
    NSInteger columnsCount = changedColumns.count;

    if(columnsCount) {
        aRecord.updatedAt = [NSDate dateWithTimeIntervalSinceNow:0];
        changedColumns = [NSSet setWithSet: [aRecord changedColumns]];
        columnsCount = changedColumns.count;
    }


    __block int result = SQLITE_OK;

    if(columnsCount)
    dispatch_sync([self activeRecordQueue], ^{
        ARDatabaseConnection *connection = [self getCurrentConnection];
        sqlite3_stmt *stmt;
        const char *sql;

        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:columnsCount];
        NSArray *orderedColumns = [changedColumns allObjects];

        for (ARColumn *column in orderedColumns) {
            [columns addObject:[NSString stringWithFormat:@"'%@' = ?", column.mappingName]];
        }

        NSString *sqlString = [NSString stringWithFormat:
                @"UPDATE '%@' SET %@ WHERE id = %@",
                [aRecord recordName],
                [columns componentsJoinedByString:@","],aRecord.id];

        sql = [sqlString UTF8String];

        if(SQLITE_OK != sqlite3_prepare_v2(connection.database, sql, strlen(sql), &stmt, NULL)) {
            NSLog( @"Couldn't save record to database: %s", sqlite3_errmsg(connection.database));
            result = SQLITE_ERROR;
            return;
        }

        int columnIndex = 1;
        for (ARColumn *column in orderedColumns) {
            id value = [aRecord valueForColumn:column];

            switch (column.columnType) {
                case ARColumnTypeComposite:
                    if ([value isKindOfClass:[NSData class]]) {
                        NSData *data = value;
                        sqlite3_bind_blob(stmt, columnIndex, [data bytes], [data length], NULL);
                    } else {
                        NSLog(@"UNKNOWN COLUMN !!1 %@ %@", value, column.mappingName);
                    }

                    break;
                default:
                    column.internal->bind(stmt, columnIndex, value);
                    break;
            }
            columnIndex++;
        }

        if(SQLITE_DONE == sqlite3_step(stmt) &&
                SQLITE_OK == sqlite3_finalize(stmt)) {
            result = SQLITE_OK ; //sqlite3_last_insert_rowid(database);
        } else {
            int error = sqlite3_finalize(stmt);
            NSLog( @"Couldn't update record to database: %s", sqlite3_errmsg(connection.database) );
            result = SQLITE_ERROR;
            switch(error) {
                case SQLITE_CONSTRAINT:
                    //TODO: Code should be added here to detect which column failed and added to model errors. JKW
                    break;
            }
        }

    });

    if(result != SQLITE_OK) {
        aRecord.updatedAt = originalUpdatedAt;
    }

    return result != SQLITE_OK ? 0 : 1;
}

- (NSInteger)updateSQLRecord:(ActiveRecord *)aRecord {   //TODO: Depricate this, prepared statement used instead.
    aRecord.updatedAt = [NSDate dateWithTimeIntervalSinceNow:0];
    const char *sqlQuery = [ARSQLBuilder sqlOnUpdateRecord:aRecord];
    if (!sqlQuery) {
        return 0;
    }
    if ([self executeSqlQuery:sqlQuery]) {
        return 1;
    }
    return 0;
}

- (void)dropRecord:(ActiveRecord *)aRecord {
    const char *sqlQuery = [ARSQLBuilder sqlOnDropRecord:aRecord];
    if (!sqlQuery) {
        return;
    }
    [self executeSqlQuery:sqlQuery];
}

- (void)createIndices {
    for (Class record in [self records]) {
        NSArray *indices = [[ARSchemaManager sharedInstance] indicesForRecord:record];
        for (NSString *indexColumn in indices) {
            const char *sqlQuery = [ARSQLBuilder sqlOnCreateIndex:indexColumn
                                                        forRecord:record];
            [self executeSqlQuery:sqlQuery];
        }
    }
}

- (NSArray *)records {
    if (records == nil) {
        NSMutableArray *clazzes = [NSMutableArray array];
        NSArray *subclasses = class_getSubclasses([ActiveRecord class]);
        for(Class clazz in subclasses) {
            //TODO: Until VinylRecord becomes the official base class and ActiveRecord compatibility is dropped. the subclass VinylRecord should not create a new table.
            if(! (clazz == [VinylRecord class]))
                [clazzes addObject:clazz];
        }
        records = clazzes; // record = class_getSubclasses([ActiveRecord class]); // originally.
    }
    return records;
}

#pragma mark - GCD support

+ (dispatch_queue_t)activeRecordQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceTokenQueue;
    dispatch_once(&onceTokenQueue, ^{
        queue = dispatch_queue_create("org.okolodev.iactiverecord", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

- (dispatch_queue_t)activeRecordQueue {
    return [[self class] activeRecordQueue];
}

@end
