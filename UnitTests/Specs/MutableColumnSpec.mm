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
        it(@"Should be saved successfully save and update dictionary column", ^{
            User *alex = [User record];
            alex.name = @"Alex";
            alex.attributes[@"param1"] = @"value1";
            alex.attributes[@"param2"] = @"value2";
            BOOL result = [alex save];

            User *fetchedUser = [[User all] objectAtIndex:0];
            fetchedUser should_not be_nil;

            fetchedUser.attributes[@"param1"] should equal(@"value1");
            fetchedUser.attributes[@"param2"] should equal(@"value2");

            fetchedUser.attributes[@"param1"] = @"value1a";
            fetchedUser.attributes[@"param2"] = @"value2a";
            fetchedUser.attributes[@"param3"] = @"value3a";

            result = [fetchedUser save];

            User *fetched2User = [[User all] objectAtIndex:0];
            fetched2User should_not be_nil;

            fetched2User.attributes[@"param1"] should equal(@"value1a");
            fetched2User.attributes[@"param2"] should equal(@"value2a");
            fetched2User.attributes[@"param3"] should equal(@"value3a");
        });
    });

    describe(@"NSMutableArray", ^{
        it(@"Should be saved successfully save and update array column", ^{
            User *alex = [User record];
            alex.name = @"Alex";
         //   alex.list = @[@"value1",@"value2"];
            [alex.list addObjectsFromArray:@[@"value1",@"value2"]];

            BOOL result = [alex save];

            User *fetchedUser = [[User all] objectAtIndex:0];
            fetchedUser should_not be_nil;

            fetchedUser.list[0]  should equal(@"value1");
            fetchedUser.list[1]  should equal(@"value2");

            [fetchedUser.list addObject:@"value3"];
            [fetchedUser.list addObject:@"value4"];

            result = [fetchedUser save];

            User *fetched2User = [[User all] objectAtIndex:0];
            fetched2User should_not be_nil;

            fetched2User.list[2]  should equal(@"value3");
            fetched2User.list[3]  should equal(@"value4");
            [fetched2User.list count] should equal(4);

            [fetched2User.list removeObjectAtIndex:3];
            result = [fetched2User save];

            User *fetched3User = [[User all] objectAtIndex:0];
            fetched3User should_not be_nil;
            [fetched3User.list containsObject:@"value4"] should equal(NO);
            [fetched3User.list count] should equal(3);
        });
    });
});
