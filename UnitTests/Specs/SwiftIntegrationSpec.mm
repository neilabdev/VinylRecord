//
// Created by ghost on 10/19/14.
// Copyright (c) 2014 NEiLAB, INC. All rights reserved.
//


#import "SpecHelper.h"

#import "ARDatabaseManager.h"
#import "Animal.h"
#import "User.h"
#import "PrimitiveModel.h"
#import "Item.h"
#import "UnitTests-Swift.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(SwiftIntegrationSpecs)

    beforeEach(^{
        prepareDatabaseManager();
        [[ARDatabaseManager sharedManager] clearDatabase];
    });
    afterEach(^{
        [[ARDatabaseManager sharedManager] clearDatabase];
    });

    describe(@"NewAndCreate", ^{
        it(@"should be successful with :new method using swift subclass ", ^{
            NSNumber *recordId = nil;
            Dog *enot = [Dog new: @{@"name":@"animal", @"title": @"dog title", @"breed":@"dog breed"}];

            enot.save should BeTruthy();
            recordId = enot.id;
            Dog *racoon = [[Dog allRecords] objectAtIndex:0];

            racoon.id should equal(recordId);
            racoon.title should equal(@"dog title");
            racoon.breed should equal(@"dog breed");
            racoon.name should equal(@"animal");
        });
    });

SPEC_END
