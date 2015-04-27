//
//  SaveUpdateSpec.h
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "SpecHelper.h"

#import "ARDatabaseManager.h"
#import "Animal.h"
#import "User.h"
#import "PrimitiveModel.h"
#import "Item.h"
#import "ActiveRecord_Private.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(SaveUpdateSpecs)

beforeEach(^{
    prepareDatabaseManager();
    [[ARDatabaseManager sharedManager] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedManager] clearDatabase];
});


describe(@"NewAndCreate", ^{
    it(@"should be successful with :new method ", ^{
        NSNumber *recordId = nil;
        Animal *enot = [Animal new: @{@"name":@"animal", @"title": @"Racoon"}];
        [enot isNewRecord] should be_truthy;
        enot.save should  be_truthy;
        recordId = enot.id;
        Animal *racoon = [[Animal allRecords] objectAtIndex:0];

        racoon.id should equal(recordId);
        racoon.title should equal(@"Racoon");
        racoon.name should equal(@"animal");
        [racoon isNewRecord] should_not  be_truthy;
    });



    it(@"should be successful with :create method ", ^{
        NSNumber *recordId = nil;
        Animal *enot = [Animal create: @{@"name":@"animal", @"title": @"Racoon"}] ;
        enot should_not be_nil;
        enot.id should_not be_nil;
        recordId = enot.id;

        Animal *racoon = [[Animal allRecords] objectAtIndex:0];

        racoon.id should equal(recordId);
        racoon.title should equal(@"Racoon");
        racoon.name should equal(@"animal");
    });

});


    describe(@"NewAndSync", ^{
        it(@"should synchronize with existing Item ", ^{

            Item *initialItem = [Item new:@{@"name" : @"Misc Name", @"title" : @"This is a test", @"text":@"text1"}];
            Item *syncItem = [Item new:@{@"name" : @"Misc Name", @"text":@"text2"}];
            Item *persistedItem = nil;

            initialItem.save should be_truthy;
            [syncItem sync] should be_truthy;
            persistedItem = [initialItem reload];

            syncItem.title should equal(initialItem.title);
            syncItem.id should equal(initialItem.id);
            persistedItem.text should equal(syncItem.text);


        });

    });

describe(@"Update", ^{
#warning separate this specs
    it(@"should be successful", ^{
        NSNumber *recordId = nil;
        Animal *enot = [Animal new] ;
        enot.name = @"animal";
        enot.title = @"Racoon";
        enot.save should be_truthy;
        recordId = enot.id;
        Animal *record = [[Animal allRecords] objectAtIndex:0];
        record.title = @"Enot";
        record.state = @"FuuBar";
        record.id should equal(recordId);
        [record save];
        Animal *racoon = [[Animal allRecords] objectAtIndex:0];
        racoon.id should equal(recordId);
        racoon.title should equal(@"Enot");
        racoon.state should equal(@"FuuBar");
    });
    
    it(@"should not validate properies that don't changed", ^{
        User *user = [User new];
        user.name = @"Alex";
        user.save should be_truthy;
        user.name = @"Alex";
        user.save should be_truthy;
        user.save should be_truthy;
    });
    
    it(@"should save values with quotes", ^{
        User *user = [User new];
        user.name = @"Al'ex";
        user.save should be_truthy;

        user = [User new];
        user.name = @"Bo\"b";
        user.save should be_truthy;
    });
    
    it(@"should update values with quotes", ^{
        User *user = [User new];
        user.name = @"Peter";
        user.save should be_truthy;
        User *savedUser = [[User allRecords] lastObject];
        savedUser.name = @"Pet\"er";
        savedUser.save should be_truthy;
    });
    
    it(@"should save/load record with primitive types", ^{
        PrimitiveModel *model = [PrimitiveModel new];

        char charValue = -42;
        unsigned char unsignedCharValue = 'q';

        short shortValue = -22;
        unsigned short unsignedShortValue = 23;

        NSInteger integerValue = 15;
        int intValue = 14;
        unsigned int unsignedIntValue = 223;

        long longValue = 14L;
        unsigned long unsignedLongValue = 42UL;

        long long longLongValue = 331LL;
        unsigned long long unsignedLongLongValue = 11124ULL;

        float floatValue = 17.43f;
        double doubleValue = 22.34;


        model.charProperty = charValue;
        model.unsignedCharProperty = unsignedCharValue;
        model.shortProperty = shortValue;
        model.unsignedShortProperty = unsignedShortValue;
        model.integerProperty = integerValue;
        model.intProperty = intValue;
        model.unsignedIntProperty = unsignedIntValue;
        model.longProperty = longValue;
        model.unsignedLongProperty = unsignedLongValue;
        model.longLongProperty = longLongValue;
        model.unsignedLongLongProperty = unsignedLongLongValue;
        model.floatProperty = floatValue;
        model.doubleProperty = doubleValue;

        [model save] should be_truthy;
        [model release];
        
        PrimitiveModel *loadedModel = [[PrimitiveModel allRecords] objectAtIndex:0];

        loadedModel.charProperty should equal(charValue);
        loadedModel.unsignedCharProperty should equal(unsignedCharValue);
        loadedModel.shortProperty should equal(shortValue);
        loadedModel.unsignedShortProperty should equal(unsignedShortValue);
        loadedModel.intProperty should equal(intValue);
        loadedModel.integerProperty should equal(integerValue);
        loadedModel.unsignedIntProperty should equal(unsignedIntValue);
        loadedModel.longProperty should equal(longValue);
        loadedModel.unsignedLongProperty should equal(unsignedLongValue);
        loadedModel.longLongProperty should equal(longLongValue);
        loadedModel.unsignedLongLongProperty should equal(unsignedLongLongValue);
        loadedModel.floatProperty should equal(floatValue);
        loadedModel.doubleProperty should equal(doubleValue);
    });
});

SPEC_END
