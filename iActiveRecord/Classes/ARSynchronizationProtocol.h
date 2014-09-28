//
// Created by James Whitfield on 9/10/14.
// Copyright (c) 2014 okolodev.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ActiveRecord;

@protocol ARSynchronizationProtocol <NSObject>
@optional
- (ActiveRecord *) mergeExistingRecord;  //beforeSaveMergeExistingRecord
- (ActiveRecord *) overwriteExistingRecord; //beforeSaveOverwriteExistingRecord
@end