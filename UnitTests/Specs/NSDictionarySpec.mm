//
// Created by James Whitfield on 10/16/15.
// Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//


#import "SpecHelper.h"

#import "ARDatabaseManager.h"
#import "User.h"

using namespace Cedar::Matchers;

CDR_EXT
Tsuga<NSDictionary>::run(^{

    beforeEach(^{
        prepareDatabaseManager();
        [[ARDatabaseManager sharedManager] clearDatabase];
    });

    afterEach(^{
        [[ARDatabaseManager sharedManager] clearDatabase];
    });

    describe(@"NSDictionary", ^{
        fit(@"Should be saved successfully and return the same date", ^{
            User *alex = [User record];
            alex.name = @"Alex";
            [alex.attributes setObject:@"value1" forKey:@"param1"];
            [alex.attributes setObject:@"value2" forKey:@"param2"];

            BOOL result = [alex save];
            User *fetchedUser = [[User all] objectAtIndex:0];
            fetchedUser should_not be_nil;

            alex.attributes[@"param1"] should equal(@"value1");
            alex.attributes[@"param2"] should equal(@"value2");
        });

    });

});
