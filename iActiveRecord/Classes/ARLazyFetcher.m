//
//  ARLazyFetcher.m
//  iActiveRecord
//
//  Created by Alex Denisov on 21.03.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ARLazyFetcher.h"
#import "ARDatabaseManager.h"
#import "NSString+lowercaseFirst.h"
#import "ARColumn.h"
#import "ActiveRecord.h"
#import "ActiveRecord_Private.h"
#import "ARLazyFetcher_Private.h"
#import "ActiveRecord_Private.h"
#import "NSString+sqlRepresentation.h"

@implementation ARLazyFetcher

@synthesize whereStatement;

- (instancetype)init {
    self = [super init];
    if (self) {
        limit = nil;
        offset = nil;
        sqlRequest = nil;
        row = nil;
        orderByConditions = nil;
        useJoin = NO;
        useRandomOrder = NO;
        relationType = ARRelationTypeNone;
    }
    return self;
}
    - (instancetype)initWithRecord:(ActiveRecord *)entityRow thatHasMany:(NSString *)aClassName through:(NSString *)aRelationsipClassName {
        self = [self init];
        row = entityRow;
        recordClass = NSClassFromString(aClassName);//[entityRow class];
        hasManyClass = [aClassName copy];
        hasManyThroughClass = [aRelationsipClassName copy];

        if(hasManyClass && hasManyThroughClass) {
            relationType = ARRelationTypeHasManyThrough;
        } else if(hasManyClass) {
            relationType = ARRelationTypeHasMany;
        }

        return self;
    }
- (instancetype)initWithRecord:(Class)aRecord {
    self = [self init];
    recordClass = aRecord;
    return self;
}

- (instancetype)initWithRecord:(Class)aRecord withInitialSql:(NSString *)anInitialSql {
    self = [self initWithRecord:aRecord];
    if (self) {
        sqlRequest = [anInitialSql copy];
    }
    return self;
}

#pragma mark - Building SQL request

- (NSSet *)fieldsOfRecord:(ActiveRecord *)aRecord {
    NSMutableSet *fields = [NSMutableSet set];
    if (onlyFields) {
        [fields addObjectsFromArray:[onlyFields allObjects]];
    } else {
        NSArray *columns = [aRecord columns];
        for (ARColumn *column in columns) {
            [fields addObject:column.columnName];
        }
    }
    if (exceptFields) {
        for (NSString *field in exceptFields) {
            [fields removeObject:field];
        }
    }
    return fields;
}

- (NSSet *)recordFields {
    return [self fieldsOfRecord:recordClass];
}

- (void)buildSql {
    NSMutableString *sql = [NSMutableString string];

    NSString *select = [self createSelectStatement];
    NSString *limitOffset = [self createLimitOffsetStatement];
    NSString *orderBy = [self createOrderbyStatement];
    NSString *where = [self createWhereStatement];
    NSString *join = [self createJoinStatement];

    [sql appendString:select];
    [sql appendString:join];
    [sql appendString:where];
    [sql appendString:orderBy];
    [sql appendString:limitOffset];
    sqlRequest = [sql copy];
}


- (void)createRecordHasManyThrough {
    NSString *relId = [row foreignKeyName];
    Class relClass = NSClassFromString(hasManyThroughClass);
    [self join:relClass];
    [self where:@"%@.%@ = %@", [[relClass performSelector:@selector(recordName)] stringAsColumnName], relId, row.id, nil];
}

- (void)createRecordHasMany {
    NSString *selfId = [[row foreignKeyName] description];
    [self where:@"%@ = %@", [selfId stringAsColumnName], row.id, nil];
}



- (NSString *)createWhereStatement {
    NSMutableString *statement = [NSMutableString string];
    if(!whereStatement && row) {
        if(relationType==ARRelationTypeHasMany) {
           [self createRecordHasMany];
        } else if(relationType==ARRelationTypeHasManyThrough) {
            [self createRecordHasManyThrough];
        }
    }

    if (whereStatement) {
        [statement appendFormat:@" WHERE (%@) ", self.whereStatement];
    }

    return statement;
}

- (NSString *)createOrderbyStatement {
    NSMutableString *statement = [NSMutableString string];
    if (useRandomOrder) {
        [statement appendFormat:@" ORDER BY RANDOM() "];
    } else if (!orderByConditions) {
        return statement;
    }
    [statement appendFormat:@" ORDER BY "];
    for (NSString *key in [orderByConditions allKeys]) {
        NSString *order = [[orderByConditions valueForKey:key] boolValue] ? @"ASC" : @"DESC";
        [statement appendFormat:
         @" \"%@\".\"%@\" %@ ,",
         [recordClass performSelector:@selector(recordName)], key, order];
    }
    [statement replaceCharactersInRange:NSMakeRange(statement.length - 1, 1) withString:@""];
    return statement;
}

- (NSString *)createLimitOffsetStatement {
    NSMutableString *statement = [NSMutableString string];
    NSInteger limitNum = -1;
    if (limit) {
        limitNum = limit.integerValue;
    }
    [statement appendFormat:@" LIMIT %d ", limitNum];
    if (offset) {
        [statement appendFormat:@" OFFSET %d ", offset.integerValue];
    }
    return statement;
}

- (NSString *)createJoinedSelectStatement {
    NSMutableString *statement = [NSMutableString stringWithString:@"SELECT "];
    NSMutableArray *fields = [NSMutableArray array];
    NSString *fieldname = nil;
    for (NSString *field in [self fieldsOfRecord : recordClass]) {
        fieldname = [NSString stringWithFormat:
                     @"\"%@\".\"%@\" AS '%@#%@'",
                     [recordClass performSelector:@selector(recordName)],
                     field,
                     [recordClass.class description], // use the class name here, since the class is looked up when records are loaded
                     field];
        [fields addObject:fieldname];
    }

    for (NSString *field in [self fieldsOfRecord : joinClass]) {
        fieldname = [NSString stringWithFormat:
                     @"\"%@\".\"%@\" AS '%@#%@'",
                     [joinClass performSelector:@selector(recordName)],
                     field,
                     [joinClass.class description],  // use the class name here, since the class is looked up when records are loaded

                     field];
        [fields addObject:fieldname];
    }

    [statement appendFormat:@"%@ FROM \"%@\" ",
     [fields componentsJoinedByString:@","],
     [recordClass performSelector:@selector(recordName)]];
    return statement;
}

- (NSString *)createSelectStatement {
    NSMutableString *statement = [NSMutableString stringWithString:@"SELECT "];
    NSMutableArray *fields = [NSMutableArray array];
    NSString *fieldname = nil;
    for (NSString *field in [self recordFields]) {
        NSString* recordName = [recordClass performSelector:@selector(recordName)];
        fieldname = [NSString stringWithFormat:
                     @"\"%@\".\"%@\" AS \"%@\"",
                     recordName,
                     field,
                     field];
        [fields addObject:fieldname];
    }
    [statement appendFormat:@"%@ FROM \"%@\" ",
     [fields componentsJoinedByString:@","],
     [recordClass performSelector:@selector(recordName)]];
    return statement;
}

- (NSString *)createJoinStatement {
    NSMutableString *statement = [NSMutableString string];
    if (!useJoin) {
        return statement;
    }
    NSString *join = joinString(joinType);
    NSString *joinTable = [joinClass performSelector:@selector(recordName)];
    NSString *selfTable = [recordClass performSelector:@selector(recordName)];
    [statement appendFormat:
     @" %@ JOIN \"%@\" ON \"%@\".\"%@\" = \"%@\".\"%@\" ",
     join,
     joinTable,
     selfTable, recordField,
     joinTable, joinField];
    return statement;
}

#pragma mark - Helpers

- (ARLazyFetcher *)offset:(NSInteger)anOffset {
    offset =  @(anOffset);
    return self;
}

- (ARLazyFetcher *)limit:(NSInteger)aLimit {
    limit = @(aLimit);
    return self;
}

#pragma mark - OrderBy

- (ARLazyFetcher *)orderBy:(NSString *)aField ascending:(BOOL)isAscending {
    if (orderByConditions == nil) {
        orderByConditions = [NSMutableDictionary new];
    }
    NSNumber *ascending = [NSNumber numberWithBool:isAscending];
    [orderByConditions setValue:ascending forKey:aField];
    return self;
}

- (ARLazyFetcher *)orderBy:(NSString *)aField {
    return [self orderBy:aField ascending:YES];
}

- (ARLazyFetcher *)orderByRandom {
    useRandomOrder = YES;
    return self;
}

#pragma mark - Select

- (ARLazyFetcher *)only:(NSString *)aFirstParam, ... {
    if (!onlyFields) {
        onlyFields = [NSMutableSet new];
    }
    [onlyFields addObject:aFirstParam];
    va_list args;
    va_start(args, aFirstParam);
    NSString *field = nil;
    while ( (field = va_arg(args, NSString *)) ) {
        [onlyFields addObject:field];
    }
    va_end(args);
    return self;
}

- (ARLazyFetcher *)except:(NSString *)aFirstParam, ... {
    if (exceptFields == nil) {
        exceptFields = [NSMutableSet new];
    }
    [exceptFields addObject:aFirstParam];
    va_list args;
    va_start(args, aFirstParam);
    NSString *field = nil;
    while ( (field = va_arg(args, NSString *)) ) {
        [exceptFields addObject:field];
    }
    va_end(args);
    return self;
}

#pragma mark - Joins

- (ARLazyFetcher *)join:(Class)aJoinRecord {

    NSString *_recordField = @"id";
    NSString *_joinField = [recordClass foreignKeyName];
    [self join:aJoinRecord
       useJoin:ARJoinInner
       onField:_recordField
      andField:_joinField];
    return self;
}

- (ARLazyFetcher *)join:(Class)aJoinRecord
                useJoin:(ARJoinType)aJoinType
                onField:(NSString *)aFirstField
               andField:(NSString *)aSecondField
{
    joinClass = aJoinRecord;
    joinType = aJoinType;
    recordField = [aFirstField copy];
    joinField = [aSecondField copy];
    useJoin = YES;
    return self;
}

#pragma mark - Immediately fetch

- (NSArray *)cachedRecords {

    if(!row) return nil;

    NSArray *entities = nil;
    NSString *entityKey = [NSString stringWithFormat:@"%@", [[recordClass recordName] lowercaseFirst]];

    if (relationType == ARRelationTypeHasManyThrough) {
        entities = [row cachedArrayForKey:entityKey];
    } else if (relationType == ARRelationTypeHasMany) {
        entities = [row cachedEntityForKey:entityKey];
    }
    return entities;
}

- (NSArray *)fetchRecords {

    if([row isNewRecord]) {
        // NEW Records down't have an ID can't query database. Return cache if available.
        NSArray *cachedEntities = [self cachedRecords];
        return cachedEntities ? cachedEntities : [NSArray array];
    }

    arrayRows = nil; //ensure that iteration dowsn't used cached rows but the following rows in the database.

    [self buildSql];
    return [[ARDatabaseManager sharedManager] allRecordsWithName:[recordClass description]
                                                          withSql:sqlRequest];
}

- (NSArray *)fetchJoinedRecords {
    if (!useJoin) {
        [NSException raise:@"InvalidCall"
         format:@"Call this method only with JOIN"];
    }
    NSMutableString *sql = [NSMutableString string];

    NSString *select = [self createJoinedSelectStatement];
    NSString *limitOffset = [self createLimitOffsetStatement];
    NSString *orderBy = [self createOrderbyStatement];
    NSString *where = [self createWhereStatement];
    NSString *join = [self createJoinStatement];

    [sql appendString:select];
    [sql appendString:join];
    [sql appendString:where];
    [sql appendString:orderBy];
    [sql appendString:limitOffset];
    return [[ARDatabaseManager sharedManager] joinedRecordsWithSql:sql];
}

- (id)objectAtIndex: (NSUInteger)index {
    NSArray *rows = nil;
    if(!arrayRows) {
        arrayRows = [self fetchRecords];
    }
    rows = arrayRows;

    return [arrayRows objectAtIndex:index];
}

- (NSUInteger)count {

    if(arrayRows)
        return [arrayRows count];

    if([row isNewRecord]) {
       return [[self cachedRecords] count];
    }

    NSMutableString *sql = [NSMutableString string];
    NSString *select = [NSString stringWithFormat:@"SELECT count(*) FROM \"%@\" ",
                        [recordClass performSelector:@selector(recordName)]];
    NSString *where = [self createWhereStatement];
    NSString *join = [self createJoinStatement];
    NSInteger resultCount = 0;
    [sql appendString:select];
    [sql appendString:join];
    [sql appendString:where];
    resultCount =  [[ARDatabaseManager sharedManager] functionResult:sql];
    return limit ? MIN([limit intValue],resultCount) : resultCount;
}

- (ARLazyFetcher *)where:(NSString *)aCondition, ...{
    va_list args;
    NSMutableArray *sqlArguments = [NSMutableArray array];
    NSString *argument = nil;
    
    va_start(args, aCondition);
    id value = nil;
    while ( (value = va_arg(args, id)) ) {
        BOOL isColumnName = [value respondsToSelector:@selector(isColumnName)] ? [value isColumnName] : NO;
        if(isColumnName && [value isKindOfClass:[NSString class]])  {
            argument =  [NSString stringWithFormat:@"\"%@\"", value];
        } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSSet class]]) {
            argument = [value performSelector:@selector(toSql)];
        } else {
            if ([value respondsToSelector:@selector(toSql)]) {
                value = [value performSelector:@selector(toSql)];
            }
            argument = [NSString stringWithFormat:@"'%@'", value];
        }
        [sqlArguments addObject:argument];
    }
    va_end(args);


    NSMutableString *sqlQuery = [NSMutableString stringWithCapacity:[aCondition length]];
    NSScanner *scanner = [NSScanner scannerWithString:aCondition];
    NSCharacterSet *illegalCharacterSet = nil;// [NSCharacterSet illegalCharacterSet];
    NSString *separatorString = @"%@";
    NSString *container;
    NSInteger sqlQueryIndex = 0;
    NSInteger totalSQLArguments = [sqlArguments count];
    scanner.charactersToBeSkipped = illegalCharacterSet;

    while ([scanner isAtEnd] == NO) {
        if([scanner scanUpToString:separatorString intoString:&container]) {
            if(totalSQLArguments>sqlQueryIndex) {
                id value = [sqlArguments objectAtIndex:sqlQueryIndex++];
                [sqlQuery appendString:container];
                [sqlQuery appendString: [value description]];
                //[sqlQuery appendFormat:@"%@%@",container, [sqlArguments objectAtIndex:sqlQueryIndex++]];
            } else
                [sqlQuery appendString:container];
            [scanner scanString:separatorString intoString:NULL]; // steps past seperator
        } else if([scanner scanString:separatorString intoString:NULL]) {
            [sqlQuery appendFormat:@"%@",[sqlArguments objectAtIndex:sqlQueryIndex++]];
        }
    }

    if (!self.whereStatement) {
        self.whereStatement = sqlQuery;
    } else {
        self.whereStatement = [NSMutableString stringWithFormat:@"%@ AND %@", self.whereStatement, sqlQuery];
    }
    return self;
}


#pragma mark - FindBy Filters

- (id) findById: (id) record_id {
    NSArray *results = [[[self where:@" id = %@", record_id,nil] limit:1] fetchRecords];
    return [results firstObject];
}

- (id) findByKey: (id) key value: (id) value {
    NSString *condition = [NSString stringWithFormat:@" %@ = %%%@ ",[key stringAsColumnName],@"@"];
    NSArray *results = [[[self where: condition, value,nil] limit:1] fetchRecords];
    return [results firstObject];
}

- (NSArray *) findAllByKey: (id) key value: (id) value {
    NSArray *results = [[self where: [NSString stringWithFormat:@" %@ = %%%@ ",[key stringAsColumnName],@"@"], value,nil]  fetchRecords];
    return results;
}

- (NSArray *) findByConditions: (NSDictionary*) conditions {
    NSMutableArray *results = [NSMutableArray array];
    return results;
}

- (NSArray *) findAllByConditions: (NSDictionary*) conditions {
    NSMutableArray *results = [NSMutableArray array];
    return results;
}

- (id) fetchFirstRecord {
    ActiveRecord *foundRecord = [[[self limit:1] fetchRecords] firstObject];
    return foundRecord;
}

#pragma mark - WHERE Filters

- (ARLazyFetcher *)whereField:(NSString *)aField equalToValue:(id)aValue{
    return [self where:@"%@ = %@",[aField stringAsColumnName],aValue, nil];
}
- (ARLazyFetcher *)whereField:(NSString *)aField notEqualToValue:(id)aValue{
    return [self where:@"%@ != %@",[aField stringAsColumnName],aValue, nil];
}
- (ARLazyFetcher *)whereField:(NSString *)aField in:(NSArray *)aValues{
    return [self where:@"%@ IN %@",[aField stringAsColumnName],aValues,nil];
}
- (ARLazyFetcher *)whereField:(NSString *)aField notIn:(NSArray *)aValues{
    return [self where:@"%@ NOT IN %@",[aField stringAsColumnName],aValues,nil];
}
- (ARLazyFetcher *)whereField:(NSString *)aField like:(NSString *)aPattern{
    return [self where:@"%@ LIKE %@",[aField stringAsColumnName],aPattern, nil];
}
- (ARLazyFetcher *)whereField:(NSString *)aField notLike:(NSString *)aPattern{
    return [self where:@"%@ NOT LIKE %@",[aField stringAsColumnName],aPattern, nil];
}
- (ARLazyFetcher *)whereField:(NSString *)aField between:(id)startValue and:(id)endValue{
    return [self where:@"%@ BETWEEN %@ AND %@",[aField stringAsColumnName], startValue,endValue,nil];
}

@end
