//
//  ARColumnManager.m
//  iActiveRecord
//
//  Created by Alex Denisov on 01.05.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "ARSchemaManager.h"
#import "ARColumn.h"
#import "NSMutableDictionary+valueToArray.h"
#import "ActiveRecordProtocol.h"

@implementation ARSchemaManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    self.schemes = [NSMutableDictionary new];
    self.indices = [NSMutableDictionary new];
    self.columns = [NSMutableDictionary new];
    self.mappings = [NSMutableDictionary new];
    return self;
}

- (void)registerSchemeForRecord:(Class <ActiveRecord>)aRecordClass {
    Class ActiveRecordClass = NSClassFromString(@"NSObject");
    id CurrentClass = aRecordClass;
    while (nil != CurrentClass && CurrentClass != ActiveRecordClass) {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(CurrentClass, &outCount);
        NSString *recordName = [aRecordClass performSelector:@selector(className)]; //Initially recordName returns className uness overwritten.
        NSDictionary *recordMapping = self.mappings[recordName];
        NSDictionary *tableMapping = recordMapping[@"__table__"];
        NSString *tableName = tableMapping[@"name"] ? tableMapping[@"name"] : recordName;
        [aRecordClass performSelector:@selector(setTableName:) withObject:tableName];
        if(tableMapping) {  //TODO: Remove, just debugging
            NSLog(@"found mapping %@",tableMapping); //just debugging
        }
        for (i = 0; i < outCount; i++) {
            NSString *propertyName = [[NSString alloc] initWithUTF8String: property_getName(properties[i])];
            NSDictionary *columnMapping = [recordMapping objectForKey:propertyName];
            if(columnMapping) { //TODO: Remove, just debugging
                NSLog(@"found mapping for property %@",propertyName);
            }
            ARColumn *column = [[ARColumn alloc] initWithProperty:properties[i] mapping: columnMapping ofClass:aRecordClass];
            if (!column.isDynamic) {
                continue;
            }
            [self.schemes addValue:column toArrayNamed:recordName];
            [self addColumn:column forRecord:aRecordClass named:column.setter];
            [self addColumn:column forRecord:aRecordClass named:column.getter];
            [self addColumn:column forRecord:aRecordClass named:column.columnName];
            if(![column.mappingName isEqualToString:column.columnName])
                [self addColumn:column forRecord:aRecordClass named:column.mappingName];
        }

        free(properties);
        CurrentClass = class_getSuperclass(CurrentClass);
    }
}

- (NSArray *)columnsForRecord:(Class)aRecordClass {
    return [[self.schemes valueForKey:[aRecordClass performSelector:@selector(className)]] allObjects];
}

- (ARColumn *) columnForRecord: (Class)aRecordClass named:(NSString *) columnName {
    NSString *recordName = [aRecordClass performSelector:@selector(className)];
    NSMutableDictionary *recordCache = [self.columns objectForKey:recordName];
    return recordCache ? [recordCache objectForKey:columnName] : nil;
}

- (void) addColumn:(ARColumn *) column forRecord:(Class) aRecordClass named:(NSString *) columnName {
    NSString *recordName = [aRecordClass performSelector:@selector(className)];
    NSMutableDictionary *recordCache = [self.columns objectForKey:recordName];

    if(!recordCache) { // should always be true.
        [self.columns setObject:recordCache = [NSMutableDictionary new] forKey:recordName];
        NSLog(@"Created cached for record: %@",recordName);
    }
    if(column)
        [recordCache setObject:column forKey:columnName];
    else
        [recordCache removeObjectForKey:columnName];
}

- (void)addIndexOnColumn:(NSString *)aColumn ofRecord:(Class)aRecordClass {
    [self.indices addValue:aColumn
              toArrayNamed:[aRecordClass performSelector:@selector(className)]];
}

- (void)addMappingOnProperty: (NSString *)propertyName column:(NSString *)columnName ofRecord:(Class)aRecordClass {
    [self addMappingOnProperty:propertyName mapping:@{@"name": columnName} ofRecord:aRecordClass];
}

- (void)addMappingOnProperty: (NSString *)propertyName mapping:(NSDictionary *)mapping ofRecord:(Class)aRecordClass {
    [self.mappings setValue:mapping
                    forKey:propertyName
                toMapNamed:[aRecordClass performSelector:@selector(className)]];
}




- (NSArray *)indicesForRecord:(Class)aRecordClass {
    return [self.indices valueForKey:[aRecordClass performSelector:@selector(className)]];
}
@end
