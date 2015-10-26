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

    describe(@"Swift subclass of ActiveRecord", ^{
        it(@"should successfully persist new NSManaged property", ^{
            NSNumber *recordId = nil;
            Dog *animal = [Dog new: @{@"name":@"animal", @"title": @"dog title", @"breed":@"dog breed"}];

            animal.save should be_truthy;
            recordId = animal.id;
            Dog *dog = [[Dog allRecords] objectAtIndex:0];
            dog.foo=@"bark";
         //   Dog.mapping should equal(1776);
         //   Dog.mapping should equal(1776);

            dog.id should equal(recordId);
            dog.title should equal(@"dog title");
            dog.breed should equal(@"dog breed");
            dog.name should equal(@"animal");
        });
    });

SPEC_END
