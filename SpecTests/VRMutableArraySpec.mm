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
SpecBegin(MutableArraySpecs)
    beforeEach(^{
        prepareDatabaseManager();
        [[ARDatabaseManager sharedManager] clearDatabase];
    });
    afterEach(^{
        [[ARDatabaseManager sharedManager] clearDatabase];
    });

    describe(@"NSMutableArray", ^{
        it(@"Should be saved successfully save and update array column", ^{
            User *alex = [User record];
            alex.name = @"Alex";
            [alex.list addObjectsFromArray:@[@"value1",@"value2"]];
            BOOL result = [alex save];
            expect(result).to.beTruthy();

            User *fetchedUser = [[User all] objectAtIndex:0];


            expect(fetchedUser.list[0]).to.equal(@"value1");
            expect(fetchedUser.list[1]).to.equal(@"value2");

            [fetchedUser.list addObject:@"value3"];
            [fetchedUser.list addObject:@"value4"];

            result = [fetchedUser save];

            User *fetched2User = [[User all] objectAtIndex:0];

            expect(fetched2User.list[2]).to.equal(@"value3");
            expect(fetched2User.list[3]).to.equal(@"value4");
            expect([fetched2User.list count]).to.equal(4);

            [fetched2User.list removeObjectAtIndex:3];
            result = [fetched2User save];

            User *fetched3User = [[User all] objectAtIndex:0];
            expect([fetched3User.list containsObject:@"value4"]).to.equal(NO);
            expect([fetched3User.list count]).to.equal(3);
        });
    });


SpecEnd
