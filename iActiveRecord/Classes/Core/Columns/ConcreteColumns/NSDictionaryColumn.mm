//
// Created by James Whitfield on 10/16/15.
// Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import "NSDictionaryColumn.h"



namespace AR {

  bool NSDictionaryColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
  {
      NSString * text;

      if([value isKindOfClass:[NSString class]]) {
          text = (NSString*) value;
      } else if([value isKindOfClass:[NSDictionary class]]) {
          NSError *error = nil;
          NSData* jsonData =
                  [NSJSONSerialization dataWithJSONObject:value
                                                  options:NULL
                                                    error:&error];
          text =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
      } else {
          text = nil; //todo: remove, should never happen
      }

      return sqlite3_bind_text(statement, columnIndex, [text UTF8String], -1, SQLITE_TRANSIENT) == SQLITE_OK;
  }

  const char *NSDictionaryColumn::sqlType(void) const {
      return "text";
  }

  NSString *NSDictionaryColumn::sqlValueFromRecord(ActiveRecord *record) const
  {
      id value = objc_getAssociatedObject(record, this->columnKey());
      NSError *error = nil;
      NSData* jsonData = [value isKindOfClass:[NSDictionary class]] ?
              [NSJSONSerialization dataWithJSONObject:value
                                              options:NULL
                                                error:&error] : nil;
      if(jsonData) {
          return [[NSString alloc] initWithData:jsonData
                                       encoding:NSUTF8StringEncoding];
      }

      return nil;
  }

  NSDictionary *__strong NSDictionaryColumn::toColumnType(id value) const
  {
      return this->deserializeValue(value);
  }

  id NSDictionaryColumn::toObjCObject(NSDictionary *value) const
  {
      return value ? value : [NSMutableDictionary dictionaryWithCapacity:1];
  }

  id NSDictionaryColumn::toObjCDefaultObject(void) const {
      return [NSMutableDictionary dictionaryWithCapacity:1];
  }


  id NSDictionaryColumn::deserializeValue(id value) const {
      NSMutableDictionary *jsonDictionary =  nil;
      NSError *error = nil;

      if([value isKindOfClass:[NSMutableDictionary class]]) {
          jsonDictionary = (NSMutableDictionary *)value;
      } else if([value isKindOfClass:[NSString class]]) {
          jsonDictionary = [NSJSONSerialization JSONObjectWithData:[(NSString*)value dataUsingEncoding:NSUTF8StringEncoding]
                                                           options:NSJSONReadingMutableContainers
                                                             error:&error];
      } else if([value isMemberOfClass:[NSDictionary class]]) {
          jsonDictionary = [NSMutableDictionary dictionaryWithDictionary:value];
      }

      return  jsonDictionary ? jsonDictionary : value;
  }


  BOOL NSDictionaryColumn::nullable(void) const
  {
      return NO;
  }


  BOOL NSDictionaryColumn::immutable(void) const
  {
      return NO;
  }

};