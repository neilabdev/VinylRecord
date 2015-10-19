//
// Created by James Whitfield on 10/16/15.
// Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import <Foundation/Foundation.h>



#pragma once

#include "ColumnInternal.h"
namespace AR {
  class NSDictionaryColumn : public ColumnInternal<NSDictionary *>
  {
  public:
      bool bind(sqlite3_stmt *statement, const int columnIndex, const id value) const override;
      const char *sqlType(void) const override;

      NSString *sqlValueFromRecord(ActiveRecord *record) const override;

      NSDictionary *__strong toColumnType(id value) const override;
      id toObjCObject(NSDictionary *value) const override;
      id toObjCDefaultObject(void) const override;

      virtual id deserializeValue(id value) const override;
      virtual BOOL nullable(void) const override;
      virtual BOOL immutable(void) const override;
  };
};
