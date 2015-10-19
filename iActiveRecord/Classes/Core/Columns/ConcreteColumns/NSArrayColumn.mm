//
// Created by James Whitfield on 10/16/15.
// Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import "NSArrayColumn.h"



namespace AR {

  bool NSArrayColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
  {
      NSString * text;

      if([value isKindOfClass:[NSString class]]) {
        text = (NSString*) value;
      } else if([value isKindOfClass:[NSArray class]]) {
          NSError *error = nil;
          NSData* jsonData =
                  [NSJSONSerialization dataWithJSONObject:value
                                                  options:NSJSONWritingPrettyPrinted
                                                    error:&error];
          text =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
      } else {
          text = nil; //todo: remove, should never happen
      }

      return sqlite3_bind_text(statement, columnIndex, [text UTF8String], -1, SQLITE_TRANSIENT) == SQLITE_OK;
  }

  const char *NSArrayColumn::sqlType(void) const {
      return "text";
  }

  NSString *NSArrayColumn::sqlValueFromRecord(ActiveRecord *record) const
  {
      id value = objc_getAssociatedObject(record, this->columnKey());
      NSError *error = nil;
      NSData* jsonData = [value isKindOfClass:[NSArray class]] ?
              [NSJSONSerialization dataWithJSONObject:value
                                              options:NSJSONWritingPrettyPrinted
                                                error:&error] : nil;
      if(jsonData) {
          return [[NSString alloc] initWithData:jsonData
                                       encoding:NSUTF8StringEncoding];
      }

      return nil;
  }

  NSArray *__strong NSArrayColumn::toColumnType(id value) const
  {
      NSMutableArray *jsonArray = this->deserializeValue(value);
      return jsonArray;
  }

  id NSArrayColumn::toObjCObject(NSArray *value) const
  {
      return value;
  }

  id NSArrayColumn::toObjCDefaultObject(void) const {
      return [[NSMutableArray alloc] initWithCapacity:1];
  }


  id NSArrayColumn::deserializeValue(id value) const {
      NSMutableArray *jsonArray =  nil;
      NSError *error = nil;

      if([value isKindOfClass:[NSString class]]) {
          jsonArray = [NSJSONSerialization JSONObjectWithData:[(NSString*)value dataUsingEncoding:NSUTF8StringEncoding]
                                                           options:NSJSONReadingMutableContainers
                                                             error:&error];
      } else if([value isMemberOfClass:[NSArray class]]) {
          jsonArray =[NSMutableArray arrayWithArray:value];
      } else if([value isKindOfClass:[NSMutableArray class]]) {
          jsonArray = (NSMutableArray *)value;
      }

      return  jsonArray ? jsonArray : value;
  }
  
  BOOL NSArrayColumn::nullable(void) const
  {
      return NO;
  }

  BOOL NSArrayColumn::immutable(void) const
  {
      return NO;
  }

};
