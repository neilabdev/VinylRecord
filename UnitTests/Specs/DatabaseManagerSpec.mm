//
//  DatabaseManagerSpec.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "SpecHelper.h"

#import "User.h"
#import "ARDatabaseManager.h"
#import "DifferentTableName.h"
#import "DifferentTableMappingName.h"

#import "ARConfiguration.h"

using namespace Cedar::Matchers;

CDR_EXT
Tsuga<ARDatabaseManager>::run(^{
    
    beforeEach(^{
        prepareDatabaseManager();
    });
    
    describe(@"ARDatabase", ^{
        it(@"Should clear all data", ^{
            User *user = [User record];
            user.name = @"John";
            BOOL result = [user save];
            result should be_truthy;
            [[ARDatabaseManager sharedManager] clearDatabase];
            NSInteger count = [[User all] count];
            count should equal(0);
        });
        
        it(@"should use recordName instead of class name", ^{
            ARDatabaseManager *databaseManager = [ARDatabaseManager sharedManager];
            NSArray *databaseTables = databaseManager.tables;
            databaseTables should contain([DifferentTableName tableName]);
        });
        
        it(@"save records with different table name", ^{
            NSString *title = @"Does ot works?";
            DifferentTableName *model = [DifferentTableName record];
            model.title = title;
            [model save] should be_truthy;
            
            DifferentTableName *loadedModel = [[DifferentTableName all] objectAtIndex:0];
            loadedModel.title should equal(title);
        });


        it(@"should use mapping name instead of class name", ^{
            ARDatabaseManager *databaseManager = [ARDatabaseManager sharedManager];
            NSArray *databaseTables = databaseManager.tables;
            databaseTables should contain([DifferentTableMappingName tableName]);
        });

        it(@"save records with different table name using mapping", ^{
            NSString *title = @"Does ot works?";
            DifferentTableMappingName *model = [DifferentTableMappingName record];
            model.title = title;
            [model save] should be_truthy;

            DifferentTableMappingName *loadedModel = [[DifferentTableMappingName all] objectAtIndex:0];
            loadedModel.title should equal(title);
        });
    });
});
