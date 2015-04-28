#import "SpecHelper.h"
#import "DecimalRecord.h"
#import "ARDatabaseManager.h"

using namespace Cedar::Matchers;

CDR_EXT
Tsuga<NSDecimalNumber>::run(^{
   
    beforeEach(^{
        prepareDatabaseManager();
        [[ARDatabaseManager sharedManager] clearDatabase];
    });
    
    afterEach(^{
        [[ARDatabaseManager sharedManager] clearDatabase];
    });
    
    describe(@"NSDecimalNumberSpec", ^{
        it(@"should return the same NSDecimalNumber value after saving", ^{
            DecimalRecord *record = [DecimalRecord record];
            NSDecimalNumber *testDecimal = [NSDecimalNumber decimalNumberWithMantissa:1123563 exponent:-3 isNegative:NO];
            record.decimal = testDecimal;
            [record save];
            ARLazyFetcher *fetcher = [DecimalRecord query];
            [fetcher where:@"id = %@", record.id, nil];
            record = [[fetcher fetchRecords] objectAtIndex:0];
            record.decimal should equal(testDecimal);
        });
    });

});
