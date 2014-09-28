//
//  ARColumnManager.h
//  iActiveRecord
//
//  Created by Alex Denisov on 01.05.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ARColumn;
@interface ARSchemaManager : NSObject

@property (nonatomic, retain) NSMutableDictionary *schemes;
@property (nonatomic, retain) NSMutableDictionary *indices;
@property (nonatomic, retain) NSMutableDictionary *columns;
+ (instancetype)sharedInstance;

- (void)registerSchemeForRecord:(Class)aRecordClass;
- (NSArray *)columnsForRecord:(Class)aRecordClass;

- (void)addIndexOnColumn:(NSString *)aColumn ofRecord:(Class)aRecordClass;
- (NSArray *)indicesForRecord:(Class)aRecordClass;
- (ARColumn *) columnForRecord: (Class)aRecordClass named:(NSString *) columnName;
- (void) addColumn:(ARColumn *) column forRecord:(Class) aRecordClass named:(NSString *) columnName;

@end
