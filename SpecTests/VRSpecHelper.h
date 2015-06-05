//
//  VRSpecHelper.h
//  iActiveRecord
//
//  Created by ghost on 6/4/15.
//  Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#ifndef iActiveRecord_VRSpecHelper_h
#define iActiveRecord_VRSpecHelper_h

#import "ARConfiguration.h"
#import "ActiveRecord.h"

static void prepareDatabaseManager() {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [ActiveRecord applyConfiguration:^(ARConfiguration *config) {
            config.databasePath = ARCachesDatabasePath(nil);
        }];
    });
}
#endif
