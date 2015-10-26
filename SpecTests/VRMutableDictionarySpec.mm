//
//  VRValidationSpec.m
//  iActiveRecord
//
//  Created by ghost on 6/4/15.
//  Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "User.h"
#import "ARDatabaseManager.h"
#import "Animal.h"
#import <Specta/Specta.h>
#define EXP_SHORTHAND
#import "Expecta.h"
#import "VRSpecHelper.h"
SpecBegin(MutableDictionarySpecs)
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
            expect(result).to.beTruthy();

            User *fetchedUser = [[User all] objectAtIndex:0];

            expect(fetchedUser.attributes[@"param1"]).to.equal(@"value1");
            expect(fetchedUser.attributes[@"param2"]).to.equal(@"value2");

            fetchedUser.attributes[@"param1"] = @"value1a";
            fetchedUser.attributes[@"param2"] = @"value2a";
            fetchedUser.attributes[@"param3"] = @"value3a";
            result = [fetchedUser save];
            expect(result).to.beTruthy();

            User *fetched2User = [[User all] objectAtIndex:0];

            expect(fetched2User.attributes[@"param1"]).to.equal(@"value1a");
            expect(fetched2User.attributes[@"param2"]).to.equal(@"value2a");
            expect(fetched2User.attributes[@"param3"]).to.equal(@"value3a");
        });
    });


SpecEnd
