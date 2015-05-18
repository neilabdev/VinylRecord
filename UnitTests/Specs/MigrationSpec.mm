//
//  MigrationSpecs.mm
//  iActiveRecord
//
//  Created by Alex Denisov on 01.08.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "SpecHelper.h"

#import "ARDatabaseManager.h"
#import "Animal.h"
#import "Entity.h"

using namespace Cedar::Matchers;

#warning Reimplement this
/*
 This spec run once, when record 'Entity' doesn't exists
 */

SPEC_BEGIN(MigrationsSpecs)

beforeEach(^{
    prepareDatabaseManager();
    [[ARDatabaseManager sharedManager] clearDatabase];
});
afterEach(^{
    [[ARDatabaseManager sharedManager] clearDatabase];
});

describe(@"Add column", ^{
    it(@"animal should have new column", ^{
        Animal *animal = [Animal record];
        animal.name = @"animal";
        animal.state = @"Full";
        BOOL result = [animal save];
        result should be_truthy;
    });
});

describe(@"Create table", ^{
    it(@"new record should save successfully", ^{
        Entity *ent = [Entity record];
        ent.property = @"LooLZ";
        [ent save] should be_truthy;
    });
});

SPEC_END
