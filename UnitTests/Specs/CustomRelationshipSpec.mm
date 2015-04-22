//
//  CustomRelationshipSpec.mm
//  iActiveRecord
//
//  Created by Simon Völcker on 20.04.15.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "SpecHelper.h"

#import "CustomUser.h"
#import "CustomGroup.h"
#import "Project.h"
#import "ARDatabaseManager.h"
#import "CustomUserProjectRelationship.h"
#import "Animal.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(CustomRelationshipsSpecs)

beforeEach(^{
    prepareDatabaseManager();
    [[ARDatabaseManager sharedManager] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedManager] clearDatabase];
});

describe(@"HasMany", ^{
    it(@"Group should have two custom users", ^{
        CustomUser *john = [CustomUser new];
        john.name = @"John";
        BOOL result = [john save];
        result should BeTruthy();
        CustomUser *peter = [CustomUser new];
        peter.name = @"Peter";
        result = [peter save];
        result should BeTruthy();
        CustomGroup *students = [CustomGroup new];
        students.title = @"students";
        [students save] should BeTruthy();
        [students addCustomUser:john];
        [students addCustomUser:peter];
        NSInteger count = [[students users] count];
        count should equal(2);
    });
    it(@"Group should not add two equal custom users", ^{
        CustomUser *alex = [CustomUser new];
        alex.name = @"Alex";
        [alex save] should BeTruthy();
        Project *project = [Project new];
        project.name = @"students";
        project.save should BeTruthy();
        [project addCustomUser: alex];
        [project addCustomUser:alex];
        NSInteger count = project.custom_users.count;
        count should equal(1);
    });
    it(@"Should remove relationship record even with custom users", ^{
        [[ARDatabaseManager sharedManager] clearDatabase];
        CustomUser *alex = [CustomUser new];
        alex.name = @"Alex";
        [alex save] should BeTruthy();
        Project *project = [Project new];
        project.name = @"students";
        project.save should BeTruthy();
        [project addCustomUser:alex];
        [project removeCustomUser:alex];
        NSInteger count = [CustomUserProjectRelationship count];
        count should equal(0);
    });
    it(@"When I remove custom user, custom user should not have group", ^{
        CustomGroup *group = [CustomGroup new];
        group.title = @"PSV 1-16";
        [group save];
        CustomUser *user = [CustomUser new];
        user.name = @"Alex";
        [user save];
        [user setCustomGroup: group];
        [group removeCustomUser: user];
        user.group should BeNil();
    });
});

describe(@"BelongsTo", ^{
    it(@"Custom user should have one group", ^{
        CustomUser *john = [CustomUser new];
        john.name = @"John";
        BOOL result = [john save];
        result should BeTruthy();
        CustomUser *peter = [CustomUser new];
        peter.name = @"Peter";
        result = [peter save];
        result should BeTruthy();
        CustomGroup *students = [CustomGroup new];
        students.title = @"students";
        [students save];
        [students addCustomUser:john];
        [students addCustomUser:peter];
        CustomGroup *group = [john group];
        [group title] should equal([students title]);
    });
    it(@"when i set belongsTo group, group should contain this custom user", ^{
        CustomGroup *group = [CustomGroup new];
        group.title = @"PSV 1-16";
        [group save];
        CustomUser *user = [CustomUser new];
        user.name = @"Alex";
        [user save];
        [user setCustomGroup:group];
        CustomUser *foundedUser = [[[group users] fetchRecords] objectAtIndex:0];
        foundedUser.name should equal(user.name);
    });
    it(@"when i set belongsTo nil, i should remove relation", ^{
        CustomGroup *group = [CustomGroup new];
        group.title = @"PSV 1-16";
        [group save];
        CustomUser *user = [CustomUser new];
        user.name = @"Alex";
        [user save];
        [user setCustomGroup:group];
        [user setCustomGroup:nil];
        group.users.count should equal(0);
    });
});

describe(@"HasManyThrough", ^{
    it(@"Custom user should have many projects", ^{
        CustomUser *john = [CustomUser new];
        john.name = @"John";
        [john save];
        CustomUser *peter = [CustomUser new];
        peter.name = @"Peter";
        [peter save];
        CustomUser *vova = [CustomUser new];
        vova.name = @"Vladimir";
        [vova save];
        
        Project *worldConquest = [Project new];
        worldConquest.name = @"Conquest of the World";
        [worldConquest save];
        
        Project *makeTea = [Project new];
        makeTea.name = @"Make tea";
        [makeTea save];
        
        [worldConquest addUser:john];
        [worldConquest addUser:peter];
        
        [makeTea addUser:john];
        [makeTea addUser:vova];
        
        NSArray *projects = [[john projects] fetchRecords];
        projects.count should equal(2);
    });
    it(@"Project should have many custom users", ^{
        CustomUser *john = [CustomUser new];
        john.name = @"John";
        [john save];
        CustomUser *peter = [CustomUser new];
        peter.name = @"Peter";
        [peter save];
        CustomUser *vova = [CustomUser new];
        vova.name = @"Vladimir";
        [vova save];
        
        Project *worldConquest = [Project new];
        worldConquest.name = @"Conquest of the World";
        [worldConquest save];
        
        Project *makeTea = [Project new];
        makeTea.name = @"Make tea";
        [makeTea save];
        
        [worldConquest addUser:john];
        [worldConquest addUser:peter];
        
        [makeTea addUser:john];
        [makeTea addUser:vova];
        NSArray *users = [[worldConquest users] fetchRecords];
        users.count should equal(2);
    });



    it(@"when I remove custom user, group should not contain this custom user", ^{
        CustomUser *alex = [CustomUser new];
        alex.name = @"Alex";
        [alex save];
        Project *makeTea = [Project new];
        makeTea.name = @"Make tea";
        [makeTea save];
        
        [makeTea addUser:alex];
        NSInteger beforeCount = [[alex projects] count];
        [alex removeProject:makeTea];
        NSInteger afterCount = [[alex projects] count];
        beforeCount should_not equal(afterCount);
    });
});

// Same test above testing lazy persistence.

describe(@"HasManyThroughQueue", ^{
    it(@"Queued Custom User should have many projects ", ^{
        CustomUser *john = [CustomUser new];
        john.name = @"John";
        CustomUser *peter = [CustomUser new];
        peter.name = @"Peter";
        CustomUser *vova = [CustomUser new];
        vova.name = @"Vladimir";

        Project *worldConquest = [Project new];
        worldConquest.name = @"Conquest of the World";


        Project *makeTea = [Project new];
        makeTea.name = @"Make tea";

        [worldConquest addUser:john];
        [worldConquest addUser:peter];
        [worldConquest save];

        [makeTea addUser:john];
        [makeTea addUser:vova];
        [makeTea save];

        NSArray *projects = [[john projects] fetchRecords];
        projects.count should equal(2);
    });
    it(@"Queued Project should have many custom users", ^{
        CustomUser *john = [CustomUser new];
        john.name = @"John";

        CustomUser *peter = [CustomUser new];
        peter.name = @"Peter";

        CustomUser *vova = [CustomUser new];
        vova.name = @"Vladimir";

        Project *worldConquest = [Project new];
        worldConquest.name = @"Conquest of the World";

        Project *makeTea = [Project new];
        makeTea.name = @"Make tea";

        [worldConquest addUser:john];
        [worldConquest addUser:peter];
        [worldConquest save];

        [makeTea addUser:john];
        [makeTea addUser:vova];
        [makeTea save];

        NSArray *users = [[worldConquest users] fetchRecords];
        users.count should equal(2);
    });

    it(@"Project should create many pets through HasManyThrough relationship with existing child", ^{
        CustomUser *john = [CustomUser new: @{@"name": @"John"}];
        CustomUser *peter =  [CustomUser new: @{@"name": @"Peter"}];

        [john addAnimal:[Animal new: @{@"name":@"animal", @"state":@"good", @"title" : @"test title"}]];

        Project *worldConquest = [Project new: @{@"name": @"Conquest of the World"}];
        [worldConquest addUser:john];
        [worldConquest addUser:peter];
        [worldConquest save] should equal(TRUE);
        [worldConquest.users  count] should equal(2);
        [Animal count] should equal(1);

        CustomUser *fetched_user = [[[[CustomUser query] where:@" name = %@ ", @"John", nil  ] fetchRecords] firstObject];
        Project *fetched_project = [[[[Project query] where:@" name = %@ ", @"Conquest of the World", nil  ] fetchRecords] firstObject];
        fetched_project.name should equal(@"Conquest of the World");
        fetched_user.name should equal(@"John");

        [fetched_user addAnimal:[Animal new: @{@"name":@"animal", @"state":@"okay", @"title" : @"test title2"}] ];
        [fetched_project addUser:fetched_user];  // Normally, Animal wouldn't be persisted because the fetched_user relation already exists
        [fetched_project save] should equal(TRUE);
        [fetched_user.pets count] should equal(2);
        [Animal count] should equal(2);
    });

    it(@"Project validation errors should propagate through HasManyThrough relationship", ^{
        CustomUser *john = [CustomUser new: @{@"name": @"John"}];
        CustomUser *peter =  [CustomUser new: @{@"name": @"Peter"}];
        Animal *animal = [Animal new: @{@"name":@"animal_error", @"state":@"good", @"title" : @"test title"}];

        [john addAnimal:animal];

        Project *worldConquest = [Project new: @{@"name": @"Conquest of the World"}];
        [worldConquest addUser:john];
        [worldConquest addUser:peter];
        [worldConquest save] should equal(NO);
        [worldConquest.errors count] should equal(1);
        [Animal count] should equal(0);

        // Correction of validation error should allow save.

        animal.name = @"animal";
        [worldConquest save] should equal(YES);
        [worldConquest.errors count] should equal(0);
        [Animal count] should equal(1);


    });

    it(@"when I remove Queued custom user, group should not contain this custom user", ^{
        CustomUser *alex = [CustomUser new];
        alex.name = @"Alex";

        Project *makeTea = [Project new];
        makeTea.name = @"Make tea";
        [makeTea addUser:alex];
        [makeTea save];

        NSInteger beforeCount = [[alex projects] count];
        [alex removeProject:makeTea];
        NSInteger afterCount = [[alex projects] count];
        beforeCount should_not equal(afterCount);
    });
});



SPEC_END
