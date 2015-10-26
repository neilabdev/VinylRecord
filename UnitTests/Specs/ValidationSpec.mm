//
//  ValidationSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "SpecHelper.h"
#import "User.h"
#import "ARDatabaseManager.h"
#import "Animal.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(ValidationSpecs)

beforeEach(^{
    prepareDatabaseManager();
    [[ARDatabaseManager sharedManager] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedManager] clearDatabase];
});

describe(@"Presence", ^{
    it(@"Should not save User with empty name", ^{
        User *user = [User record];
        user.name = @"";
        BOOL result = [user save];
        result should_not be_truthy;
//        result should_not be_truthy;
    });
    it(@"Should save User with some name", ^{
        User *user = [User record];
        user.name = @"John";
        BOOL result = [user save];
        result should be_truthy;
//        result should be_truthy;
    });
});

describe(@"Uniqueness", ^{
    it(@"Should not save User with same name", ^{
        User *john = [User record];
        john.name = @"John";
        BOOL result = [john save];

        result should be_truthy;
        User *john2 = [User record];
        john2.name = @"John";
        result = [john2 save];
        result should_not be_truthy;
        //Updates should not validate uniqueness

        john.name = @"Johns";
        john.name = @"John";
        john.birthDate = [NSDate date];
        result = [john save];
        result should be_truthy;

    });
    it(@"Should save User with some name", ^{
        User *john = [User record];
        john.name = @"John";
        BOOL result = [john save];
        result should be_truthy;
        User *peter = [User record];
        peter.name = @"Peter";
        result = [peter save];
        result should be_truthy;
    });
    it(@"Should update fetched User", ^{
        User *john = [User record];
        john.name = @"John";
        BOOL result = [john save];
        result should be_truthy;
        User *user = [[[[User query] limit:1] fetchRecords] objectAtIndex:0];
        user.updatedAt = [NSDate dateWithTimeIntervalSinceNow:0];
        user.save should be_truthy;
    });
});

describe(@"Custom validator", ^{
    it(@"Animal name should be valid", ^{
        Animal *animal = [Animal record];
        animal.name = @"animal";
        [animal save] should be_truthy;
    });
    it(@"Animal name should not be valid", ^{
        Animal *animal = [Animal record];
        animal.name = @"bear";
        [animal save] should_not be_truthy;
    });
});

SPEC_END
