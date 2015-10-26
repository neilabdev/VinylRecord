//
//  VRValidationSpec.m
//  iActiveRecord
//
//  Created by ghost on 6/4/15.
//  Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import <Foundation/Foundation.h>


//
//  ValidationSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "User.h"
#import "ARDatabaseManager.h"
#import "Animal.h"
#import <Specta/Specta.h>
#define EXP_SHORTHAND
#import "Expecta.h"
#import "VRSpecHelper.h"
SpecBegin(ValidationSpecs)
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
        expect(result).notTo.beTruthy();
        //        result should_not be_truthy;
    });
    it(@"Should save User with some name", ^{
        User *user = [User record];
        user.name = @"John";
        BOOL result = [user save];
        expect(result).to.beTruthy();
        //        result should be_truthy;
    });
});

describe(@"Uniqueness", ^{
    it(@"Should not save User with same name", ^{
        User *john = [User record];
        john.name = @"John";
        BOOL result = [john save];
        
        expect(result).to.beTruthy();;
        User *john2 = [User record];
        john2.name = @"John";
        result = [john2 save];
        expect(result).notTo.beTruthy();;
        //Updates should not validate uniqueness
        
        john.name = @"Johns";
        john.name = @"John";
        john.birthDate = [NSDate date];
        result = [john save];
        expect(result).to.beTruthy();
        
    });
    it(@"Should save User with some name", ^{
        User *john = [User record];
        john.name = @"John";
        BOOL result = [john save];
        expect(result).to.beTruthy();
        User *peter = [User record];
        peter.name = @"Peter";
        result = [peter save];
        expect(result).to.beTruthy();
    });
    it(@"Should update fetched User", ^{
        User *john = [User record];
        john.name = @"John";
        BOOL result = [john save];
        expect(result).to.beTruthy();
        User *user = [[[[User query] limit:1] fetchRecords] objectAtIndex:0];
        user.updatedAt = [NSDate dateWithTimeIntervalSinceNow:0];
        expect(result).to.beTruthy();;
    });
});

describe(@"Custom validator", ^{
    it(@"Animal name should be valid", ^{
        Animal *animal = [Animal record];
        animal.name = @"animal";
        expect([animal save]).to.beTruthy();;
    });
    it(@"Animal name should not be valid", ^{
        Animal *animal = [Animal record];
        animal.name = @"bear";
        expect([animal save]).notTo.beTruthy();;
    });
});

SpecEnd
