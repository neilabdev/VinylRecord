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

      return sqlite3_bind_text(statement, columnIndex, [value UTF8String], -1, SQLITE_TRANSIENT) == SQLITE_OK;
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
      NSString *jsonString = [value isKindOfClass:[NSString class]] ? value : nil;
      NSError *error = nil;
      NSMutableArray *jsonArray = jsonString ?
              [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                              options:NSJSONReadingMutableContainers
                                                error:&error] : nil;
      return jsonArray;
  }

  id NSArrayColumn::toObjCObject(NSArray *value) const
  {
      return value;
  }
};

/*
 *
 * namespace AR {

    bool NSNumberColumn::bind(sqlite3_stmt *statement, const int columnIndex, const id value) const
    {
        return sqlite3_bind_int(statement, columnIndex, [value integerValue]) == SQLITE_OK;
    }

    const char *NSNumberColumn::sqlType(void) const {
        return "integer";
    }

    NSString *NSNumberColumn::sqlValueFromRecord(ActiveRecord *record) const
    {
        NSNumber *value = objc_getAssociatedObject(record, this->columnKey());

        return [NSString stringWithFormat:@"%d", [value intValue]];
    }

    NSNumber *__strong NSNumberColumn::toColumnType(id value) const
    {
        return value;
    }

    id NSNumberColumn::toObjCObject(NSNumber *value) const
    {
        return value;
    }
};
 */