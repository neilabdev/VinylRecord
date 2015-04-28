//
//  DependencySpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "SpecHelper.h"
#import "ARDatabaseManager.h"
#import "User.h"
#import "Project.h"
#import "Group.h"
#import "Issue.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(DependencySpecs)

beforeEach(^{
    prepareDatabaseManager();
    [[ARDatabaseManager sharedManager] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedManager] clearDatabase];
});

describe(@"Destroy", ^{
    it(@"HasMany", ^{
        User *john = [User record];
        john.name = @"John";
    //    [john save];
        
        User *alex = [User record];
        alex.name = @"Alex";
     //   [alex save];
        
        Group *students = [Group record];
        students.title = @"Students";
        [students addUser:john];
        [students addUser:alex];
        [students.users count] should equal(2); //cached count

        [students save];
        [students.users count] should equal(2); //persisted count
        [students dropRecord];
      //  [alex release];
      //  [john release];
      //  [students release];
        
        [User count] should equal(0);
    });
    it(@"BelongsTo", ^{
        User *john = [User record];
        john.name = @"John";
        [john save];
        User *peter = [User record];
        peter.name = @"Peter";
        [peter save];
        
        Group *students = [Group record];
        students.title = @"Students";
        [students save];
        
        [students addUser:john];
        [students addUser:peter];
        [john dropRecord];
        [Group count] should equal(0);
        [User count] should equal(0);
    });
    it(@"HasManyThrough", ^{
        User *john = [User record];
        john.name = @"John";
        [john save];
        
        Project *makeTea = [Project record];
        makeTea.name = @"Make tea";
        [makeTea addUser:john];
        [makeTea save];
        [makeTea.users count] should equal(1);

        [john dropRecord];
        
        [User count] should equal(0);
        [Project count] should equal(0);
    });
});

describe(@"Destroy/Nulify", ^{
    describe(@"HasMany - destroy, BelongsTo - nullify", ^{
        it(@"when i drop project it should drop all issues", ^{
            Issue *issue = [Issue record];
            issue.title = @"new issue";
            [issue save];
            Project *project = [Project record];
            project.name = @"Make tea";
            [project save];
            [project addIssue:issue];
            Issue *emptyIssue = [Issue record];
            emptyIssue.title = @"empty";
            [emptyIssue save];
            [project dropRecord];
            [Issue count] should equal(1);
        });
        it(@"when i drop issue it should not drop project issues", ^{
            Issue *issue = [Issue record];
            issue.title = @"new issue";
            [issue save];
            Project *project = [Project record];
            project.name = @"Make tea";
            [project save];
            [project addIssue:issue];
            Issue *emptyIssue = [Issue record];
            emptyIssue.title = @"empty";
            [emptyIssue save];
            
            NSInteger count = [Project count];
            
            [issue dropRecord];
            [Project count] should equal(count);
        });
    });
});

describe(@"Nulify", ^{
    it(@"when i drop project it should not drop group", ^{
        Group *students = [Group record];
        students.title = @"Students";
        [students save];
        
        Project *project = [Project record];
        project.name = @"Make tea";
        [project save];
        [project addGroup:students];
        
        [project dropRecord];
        [Group count] should equal(1);
    });
});

// Same test above testing lazy persistence.

describe(@"Queued Destroy", ^{
    it(@"HasMany", ^{
        User *john = [User record];
        john.name = @"John";

        User *alex = [User record];
        alex.name = @"Alex";

        Group *students = [Group record];
        students.title = @"Students";

        [students addUser:john];
        [students addUser:alex];

        [students dropRecord];
       // [alex release];
      //  [john release];
      //  [students release];

        [User count] should equal(0);
    });
    it(@"Queued BelongsTo", ^{
        User *john = [User record];
        john.name = @"John";

        User *peter = [User record];
        peter.name = @"Peter";

        Group *students = [Group record];
        students.title = @"Students";

        [students addUser:john];
        [students addUser:peter];
        [students save];

        [john dropRecord];
        [Group count] should equal(0);
        [User count] should equal(0);
    });
    it(@"Queued HasManyThrough", ^{
        User *john = [User record];
        john.name = @"John";

        Project *makeTea = [Project record];
        makeTea.name = @"Make tea";

        [makeTea addUser:john];
        [makeTea save];

        [john.projects count] should equal(1);
        [john dropRecord];

        [User count] should equal(0);
        [Project count] should equal(0);
    });
});

describe(@"Queued Destroy/Nulify", ^{
    describe(@"HasMany - destroy, BelongsTo - nullify", ^{
        it(@"when i drop  queued project it should drop all issues", ^{
            Issue *issue = [Issue record];
            issue.title = @"new issue";

            Project *project = [Project record];
            project.name = @"Make tea";

            [project addIssue:issue];
            Issue *emptyIssue = [Issue record];
            emptyIssue.title = @"empty";
            [emptyIssue save];
            [project dropRecord];
            [Issue count] should equal(1);
        });
        it(@"when i drop issue it should not drop  queued project issues", ^{
            Issue *issue = [Issue record];
            issue.title = @"new issue";

            Project *project = [Project record];
            project.name = @"Make tea";

            [project addIssue:issue];
            [project save];

            Issue *emptyIssue = [Issue record];
            emptyIssue.title = @"empty";
            [emptyIssue save];

            NSInteger count = [Project count];

            [issue dropRecord];
            [Project count] should equal(count);
        });
    });
});

describe(@"Queued Nulify", ^{
    it(@"when i drop queued project it should not drop group", ^{
        Group *students = [Group record];
        students.title = @"Students";

        Project *project = [Project record];
        project.name = @"Make tea";

        [project addGroup:students];
        [project dropRecord];
        [Group count] should equal(1);
    });
});
SPEC_END
