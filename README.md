# VinylRecord
VinylRecord is an ActiveRecord ORM for iOS using SQLite without CoreData. It was fork of a discontinued project, iActiveRecord by Alex Denisov which was a great start for an ORM when they were few others in site. Desiring rapid fixes and new features for an application in dire need of a persistence layer, the API was forked with new name as to avoid confusion with its predecessor, for which it maintains compatibility, and other ORM's with the ActiveRecord name.

# Features
* Belongs-To, Has-Many and Has-Many-Through relationships    
* Nested SavePointTransactions (NEW)
* Transactions
* Thread Safety (NEW)
* Save, Update, and Syncing of Models
* Traditional and Custom Validations
* Save/Update Callbacks (NEW)


# Installation  

    git clone https://github.com/valerius/VinylRecord.git

Open with XCode and build Build_Framework target.  
The ActiveRecord.framework will be located in ~/Products/, this path can be changed in the shell-script in the Settings tab of target.  
Open your project Settings and add ActiveRecord.framework and sqlite3.0.dylib to Link Binary With Libraries section.  

Or if you use [CocoaPods](http://cocoapods.org/)

    # Podfile
    pod 'VinylRecord', '1.0.3'

# Usage

To create the model you should inherit your model class from VinylRecord class.  
Framework will automatically create a database table using the classes inherited from VinylRecord when you run app first time.

So based on this code

    #import <ActiveRecord/VinylRecord.h>
    @interface User : VinylRecord
        column_dec(string,name)  // or  @property (nonatomic, retain) NSString *name;
        column_dec(boolean,active)
    @end
    
    @implementation User
        column_imp(string,name) // or @dynamic 
        column_imp(boolean,active) // user.is_active = YES or user.has_active not available using @dynamic
    @end
    

table 'user' will be created. It will contain 'name' field.  

After describing the model you can start using the framework:

    User *user = [User new];
    user.name = @"Alex";
    [user save];

    NSArray *users = [User allRecords];
    User *userForRemove = [users first];
    [userForRemove dropRecord];

This code creates, retrieves a list and deletes the model.

**Note**: If you are using CocoaPods, you must include the headers so

    #import "VinylRecord.h"

instead

    #import <ActiveRecord/VinylRecord.h>

# Data types
NSDecimalNumber - real  
NSNumber - integer  
NSString - text  
NSData - blob  
NSDate - date (real)

## Store custom types as fields

All custom property types should implement ARRepresentationProtocol:

    @protocol ARRepresentationProtocol

    @required
    + (const char *)sqlType;
    - (NSString *)toSql;
    + (id)fromSql:(NSString *)sqlData;

    @end

This is a simple example:

    @implementation NSString (sqlRepresentation)

    + (ActiveRecord *)fromSql:(NSString *)sqlData{
        return sqlData;
    }

    - (NSString *)toSql {
        return self;
    }

    + (const char *)sqlType {
        return "text";
    }

    @end



# Ignoring some fields

What about the properties that should not be stored in a database?  
Just ignore them:

    @implementation User
    ...
    @synthesize ignoredProperty;
    ...
    ignore_fields_do(
        ignore_field(ignoredProperty)
    )
    ...
    @end

All these properties will be ignored during the database table creation.

# Validation

Validations are described in the implementation.  
We do not need to initiate the validation process for all models, so models which use the validation must implement the protocol. 
    
    // User.h
    @interface User : ActiveRecord
        <ARValidatableProtocol>
    ...
    @property (nonatomic, copy) NSString *name;
    ...
    @end
    // User.m
    @implementation User
    ...
    validation_do(
        validate_uniqueness_of(name)
        validate_presence_of(name)
    )
    ...
    @end

At the moment there are two types of validations: presence and uniqueness, but you can use your own validators.  
Just describe new class and implement ARValidatorProtocol

    // ARValidatorProtocol
    @protocol ARValidatorProtocol <NSObject>
    @optional
    - (NSString *)errorMessage;
    @required
    - (BOOL)validateField:(NSString *)aField ofRecord:(id)aRecord;
    @end
    
    //  Custom validator
    //  PrefixValidator.h
    @interface PrefixValidator : NSObject
        <ARValidatorProtocol>
    @end
    //  PrefixValidator.m
    @implementation PrefixValidator
    - (NSString *)errorMessage {
        return @"Invalid prefix";
    }
    - (BOOL)validateField:(NSString *)aField ofRecord:(id)aRecord {
        NSString *aValue = [aRecord valueForKey:aField];
        BOOL valid = [aValue hasPrefix:@"LOL"];
        return valid;
    }
    @end

then add validator to your ActiveRecord implementation

    @implementation User
    @synthesize name;
    ...
    validation_do(
        validate_field_with_validator(name, PrefixValidator)
    )
    ...
    @end

Validation errors

    User *user = [User newRecord];
    if(![user isValid]){
        NSArray *errors = [user errorMessages];
        //  do something
    }

or

    User *user = [User newRecord];
    if(![user save]){
        NSArray *errors = [user errorMessages];
        //  do something
    }

# Migrations  

ActiveRecord supports simple migrations: you can add new record or new property. 
Framework will create new table or add new column to already existing table, without loss of data.
If you don't need migrations, you should disable them at start of application

    - (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        [ActiveRecord disableMigrations];
        ...
    }

# Transactions

Simple syntax for transactions
    
    [ActiveRecord transaction:^{
        User *alex = [User newRecord];
        alex.name = @"Alex";
        [alex save];
    }];

    [ActiveRecord transaction:^{
        User *alex = [User newRecord];
        alex.name = @"Alex";
        [alex save];
        rollback
    }];

# Relationships

Relationships support "ON DELETE" dependencies: ARDependencyDestroy and ARDependencyNullify

## HasMany <-> BelongsTo
    
    // User.h
    @interface User : ActiveRecord
    ...
    @property (nonatomic, retain) NSNumber *groupId;
    ...
    belongs_to_dec(Group, group, ARDependencyDestroy)
    ...
    @end
    // User.m
    @implementation User
    ...
    @synthesize groupId;
    ...
    belongs_to_imp(Group, group, ARDependencyDestroy)
    ...
    @end

belongs_to_dec and belongs_to_imp take two parameters: the model name and accessor's name.  

The main thing to remember when describe the field of relationship, it must match the name of the model and begin with lowercased letters.

Group      <->     groupId  
User       <->     userId  
ContentManager <->  contentManagerId  

## Describe reverse relationship

    // Group.h
    @interface Group : ActiveRecord
    ...
    has_many_dec(User, users, ARDependencyDestroy)
    ...
    @end
    // Group.m
    @implementation Group
    ...
    has_many_imp(User, users, ARDependencyDestroy)
    ...
    @end

The same as above: model name and accessor.  

In order to add or remove model you can use methods that match this pattern:  

    add##ModelName:(ActiveRecord *)aRecord;
    remove##ModelName:(ActiveRecord *)aRecord;

At the moment it works correctly only if both models are saved, otherwise they have no id and relationship is not possible.

## HasManyThrough

To describe this relationship, you need to create another model
    
    // User.h
    @interface User : ActiveRecord
    ...
    has_many_through_dec(Project, UserProjectRelationship, projects, ARDependencyNullify)
    ...
    @end
    // User.m
    @implementation User
    ...
    has_many_through_imp(Project, UserProjectRelationship, projects, ARDependencyNullify)
    ...
    @end
    
    // Project.h
    @interface Project : ActiveRecord
    ...
    has_many_through_dec(User, UserProjectRelationship, users, ARDependencyDestroy)
    ...
    @end
    // Project.m
    @implementation Project
    ...
    has_many_through_imp(User, UserProjectRelationship, users, ARDependencyDestroy)
    ...
    @end

Relationship model

    // UserProjectRelationship.h
    @interface UserProjectRelationship : ActiveRecord
    @property (nonatomic, retain) NSNumber *userId;
    @property (nonatomic, retain) NSNumber *projectId;
    @end
    // UserProjectRelationship.m
    @implementation UserProjectRelationship
    @synthesize userId;
    @synthesize projectId;
    @end

HasManyThrough has the same gaps as HasMany.

# Requests and filters

The framework allows to obtain a list of records using different filters, all requests are lazy, i.e., being run only on demand.
A simple example of obtaining a limited number of records:  

    NSArray *users = [[[User lazyFetcher] limit:5] fetchRecords];

All filters returns an instance of ARLazyFetcher, which allows you to write queries in a single row:

    NSArray *users = [[[[User lazyFetcher] offset:5] limit:2] fetchRecords];

The fetchRecords method initiates sql-query to the database on the basis of all applied filters:

    ARLazyFetcher *fetcher = [[[User lazyFetcher] offset:2] limit:10];
    [fetcher whereField:@"name"
           equalToValue:@"Alex"];
    NSArray *users = [fetcher fetchRecords];

There are several options for 'where' methods:

    - (ARLazyFetcher *)whereField:(NSString *)aField equalToValue:(id)aValue;
    - (ARLazyFetcher *)whereField:(NSString *)aField notEqualToValue:(id)aValue;
    - (ARLazyFetcher *)whereField:(NSString *)aField in:(NSArray *)aValues;
    - (ARLazyFetcher *)whereField:(NSString *)aField notIn:(NSArray *)aValues;
    - (ARLazyFetcher *)whereField:(NSString *)aField like:(NSString *)aPattern;
    - (ARLazyFetcher *)whereField:(NSString *)aField notLike:(NSString *)aPattern;
    - (ARLazyFetcher *)whereField:(NSString *)aField between:(id)startValue and:(id)endValue;
    - (ARLazyFetcher *)where:(NSString *)aFormat, ...;

### Old syntax

In addition, you can use multiple filters at once, linking them with logical operators OR or AND
    
    NSNumber *num = [NSNumber numberWithInt:42];
    ARWhereStatement *nameStatement = [ARWhereStatement whereField:@"name" equalToValue:@"Alex"];
    ARWhereStatement *idStatement = [ARWhereStatement whereField:@"id" equalToValue:num];

    ARWhereStatement *finalStatement = [ARWhereStatement concatenateStatement:nameStatement
                                                                withStatement:idStatement
                                                          useLogicalOperation:ARLogicalOr];
    ARLazyFetcher *fetcher = [User lazyFetcher];
    [fetcher setWhereStatement:finalStatement];
    NSArray *records = [fetcher fetchRecords];

You can also concatenate with finalStatement some "complex" or a simple filter. 

Relationship HasManyThrough is already use the 'where' filter, so if you want to add more, you should use code like this:

    User *user = [[User allRecords] first];
    ARLazyFetcher *fetcher = [user projects];
    ARWhereStatement *currentStmt = [fetcher whereStatement];
    ARWhereStatement *newStatement = [ARWhereStatement whereField:@"name"
                                                         ofRecord:[user class]
                                                  notEqualToValue:@"Alex"];
    ARWhereStatement *finalStmt = [ARWhereStatement concatenateStatement:currentStmt
                                                           withStatement:newStatement
                                                     useLogicalOperation:ARLogicalAnd];
    [fetcher setWhereStatement:finalStmt];
    NSArray *projects = [fetcher fetchRecords];

### New syntax

You can use more usable style for filtering

    NSArray *ids = [NSArray arrayWithObjects:
                   [NSNumber numberWithInt:1],
                   [NSNumber numberWithInt:15], 
                   nil];
    NSString *username = @"john";
    ARLazyFetcher *fetcher = [User lazyFetcher];
    [fetcher where:@"'user'.'name' = %@ or 'user'.'id' in %@", 
                   username, ids, nil];
    [fetcher orderBy:@"id"];
    NSArray *records = [fetcher fetchRecords];

New syntax support basic comparisons:

 - =, == - equality
 - >= - left-hand operand greater or equal then right-hand operand
 - <= - right-hand operand greater or equal then left-hand operand
 - > - left-hand operand greater then right-hand operand
 - < - right-hand operand greater then left-hand operand
 - !=, <> - operands are not equal
 - LIKE, NOT LIKE - pattern matching
 - IN, NOT IN container - records which fields are in container (NSArray, NSSet etc.)
 - BETWEEN %1 AND %2 - records with fields in range(%1, %2)

# Fetch only needed fields

    - (ARLazyFetcher *)only:(NSString *)aFirstParam, ...;
    - (ARLazyFetcher *)except:(NSString *)aFirstParam, ...;

    ARLazyFetcher *fetcher = [[User lazyFetcher] only:@"name", @"id", nil];
    NSArray *users = [fetcher fetchRecords];

# Sorting

    - (ARLazyFetcher *)orderBy:(NSString *)aField ascending:(BOOL)isAscending;
    - (ARLazyFetcher *)orderBy:(NSString *)aField;// ASC by default

    ARLazyFetcher *fetcher = [[[User lazyFetcher] offset:2] limit:10];
    [[fetcher whereField:@"name"
           equalToValue:@"Alex"] orderBy:@"name"];
    NSArray *users = [fetcher fetchRecords];

# Join

The framework supports the use of joins:

    - (ARLazyFetcher *)join:(Class)aJoinRecord
                    useJoin:(ARJoinType)aJoinType
                    onField:(NSString *)aFirstField
                   andField:(NSString *)aSecondField;

aJoinRecord - a model for which we use join  
aJoinType - type of join,  may be several options  
* ARJoinLeft  
* ARJoinRight  
* ARJoinInner  
* ARJoinOuter  
aFirstField - a field on which the current model will be join  
aSecondField - a field on which the aJoinModel will be join  

Joined records can be fetched by sending

    - (NSArray *)fetchJoinedRecords;

message to ARLazyFetcher instance.

# Storage

By default database file has name 'database' and being stored in CachesDirectory, but you can change this by a call at the start of application:

    [ActiveRecord registerDatabaseName:@"some-name"
                          useDirectory:ARStorageDocuments];

# Tests

If you want another database for tests you need to add UNIT_TEST=1 to Preprocessor Macros. After that new database will be named with suffix '-test'.