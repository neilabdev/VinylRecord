//
//  ARRelationships.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 okolodev.org. All rights reserved.
//

#import "NSString+lowercaseFirst.h"

#import <objc/runtime.h>

#define belongs_to_imp(class, getter, dependency) \
    + (ARDependency)_ar_registerBelongsTo ## class { \
        return dependency; \
    } \
    -(id)getter { \
        NSString *class_name = @ ""#class ""; \
        return [self performSelector : @selector(belongsTo:) withObject : class_name]; \
    } \
    -(void)set ## class : (ActiveRecord *)aRecord { \
        NSString *aClassName = @ ""#class ""; \
        objc_msgSend(self, sel_getUid("setRecord:belongsTo:"), aRecord, aClassName); \
    }

#define belongs_to_dec(class, getter, dependency) \
    - (id)getter; \
    -(void)set ## class : (ActiveRecord *)aRecord;


#define has_many_dec(relative_class, accessor, dependency) \
    - (ARLazyFetcher *)accessor; \
    -(void)add ## relative_class : (ActiveRecord *)aRecord; \
    -(void)remove ## relative_class : (ActiveRecord *)aRecord;

#define has_many_imp(relative_class, accessor, dependency) \
    + (ARDependency)_ar_registerHasMany ## relative_class { \
        return dependency; \
    } \
    -(ARLazyFetcher *)accessor { \
        NSString *class_name = @ ""#relative_class ""; \
        return objc_msgSend(self, sel_getUid("hasManyRecords:"), class_name); \
    } \
    -(void)add ## relative_class : (ActiveRecord *)aRecord { \
        objc_msgSend(self, sel_getUid("addRecord:"), aRecord); \
    } \
    -(void)remove ## relative_class : (ActiveRecord *)aRecord { \
        objc_msgSend(self, sel_getUid("removeRecord:"), aRecord); \
    }

#define has_many_through_dec(relative_class, relationship, accessor, dependency) \
    - (ARLazyFetcher *)accessor; \
    -(void)add ## relative_class : (ActiveRecord *)aRecord; \
    -(void)remove ## relative_class : (ActiveRecord *)aRecord;

#define has_many_through_imp(relative_class, relationship, accessor, dependency) \
    + (ARDependency)_ar_registerHasManyThrough ## relative_class ## _ar_ ## relationship { \
        return dependency; \
    } \
    -(ARLazyFetcher *)accessor \
    { \
        NSString *className = @ ""#relative_class ""; \
        NSString *relativeClassName = @ ""#relationship ""; \
        return objc_msgSend(self, sel_getUid("hasMany:through:"), className, relativeClassName); \
    } \
    -(void)add ## relative_class : (ActiveRecord *)aRecord { \
        NSString *className = @ ""#relative_class ""; \
        NSString *relativeClassName = @ ""#relationship ""; \
        objc_msgSend(self, sel_getUid("addRecord:ofClass:through:"), aRecord, className, relativeClassName); \
    } \
    -(void)remove ## relative_class : (ActiveRecord *)aRecord { \
        NSString *className = @ ""#relationship ""; \
        objc_msgSend(self, sel_getUid("removeRecord:through:"), aRecord, className); \
    }


#pragma mark - Imported form ActiveRecord+Extentions


#define add_search_on(aField) \
    [self performSelector: @selector(addSearchOn:) withObject: @ ""#aField ""];

#define indexes_do(indices) \
    + (void)initializeIndices { \
        [super initializeIndices]; \
        indices \
    }

#define mapping_do(mapping) \
    (void) initializeMapping { \
        return; \
    }

#define belonging_to_imp(class, getter, dependency) \
    + (ARDependency)_ar_registerBelongsTo ## class { \
        return dependency; \
    } \
    -(class *)getter { \
        NSString *class_name = @ ""#class ""; \
        return [self performSelector : @selector(belongsTo:) withObject : class_name]; \
    } \
    -(void)set ## class : (ActiveRecord *)aRecord { \
        NSString *aClassName = @ ""#class ""; \
        objc_msgSend(self, sel_getUid("setRecord:belongsTo:"), aRecord, aClassName); \
    }

#define belonging_to_dec(class, getter, dependency) \
    -(class *)getter; \
    -(void)set ## class : (ActiveRecord *)aRecord;


#define has_none_through_dec has_many_through_imp
#define has_none_through_imp(relative_class, relationship, accessor, dependency) \
    + (ARDependency)_ar_registerHasManyThrough ## relative_class ## _ar_ ## relationship { \
        return dependency; \
    } \
    -(ARLazyFetcher *)accessor \
    { \
        return nil; \
    } \
    -(void)add ## relative_class : (ActiveRecord *)aRecord { \
    } \
    -(void)remove ## relative_class : (ActiveRecord *)aRecord { \
    }




#define AR_DECIMAL_NUM(number) [NSDecimalNumber numberWithDouble: number]
#define AR_DECIMAL_STR(number_string) [NSDecimalNumber decimalNumberWithString: number_string]
#define AR_INTEGER_NUM(number) [NSNumber numberWithInt: number]
#define AR_INTEGER_STR(number_string) [number_string intValue]

#define attr_accessor_dec(ar_type,propertyName) field_##ar_type##_dec(propertyName);
#define attr_accessor_imp(ar_type,propertyName) field_##ar_type##_imp(propertyName);


/* This marco's are helpers to generate methods to allow assigning primitive types */


#define property_as_dec(PrimitiveType,PersistentClass,PropertyName) 1

#define field_key_dec field_integer_dec
#define field_key_imp field_integer_imp


#define field_string_dec( property_name ) \
    @property ( nonatomic,copy ) NSString * property_name;
#define field_string_imp( property_name ) \
    @dynamic property_name ;

#define field_date_dec( property_name ) \
    @property ( nonatomic, strong) NSDate * property_name;
#define field_date_imp( property_name ) \
    @dynamic property_name;


#define field_boolean_dec( property_name ) \
    @property ( nonatomic,strong ) NSNumber * property_name; \
    @property ( nonatomic,assign ) BOOL is_##property_name ; \
    @property ( nonatomic,assign ) BOOL has_##property_name ;

#define field_boolean_imp( property_name ) \
    @dynamic property_name ;   \
    - (BOOL) is_##property_name { \
        BOOL value =  [ [ self property_name ] boolValue ]; \
        return value; \
    }  \
    - (BOOL) has_##property_name { \
        BOOL value =  [ [ self property_name ] boolValue ]; \
        return value; \
    }  \
    - (void) setIs_##property_name: (BOOL ) value  { \
        NSString *propertyName =  @"" #property_name ; \
        NSString *propertySetter =  [propertyName asSetterMethodName]; ; \
        objc_msgSend(self,sel_getUid([propertySetter UTF8String]), [NSNumber numberWithInt: value ]) ; \
    } \
    - (void) setHas_##property_name: (BOOL ) value  { \
        NSString *propertyName =  @"" #property_name ; \
        NSString *propertySetter =  [propertyName asSetterMethodName]; ; \
        objc_msgSend(self,sel_getUid([propertySetter UTF8String]), [NSNumber numberWithInt: value ]) ; \
    }


#define field_integer_dec( property_name ) \
    @property ( nonatomic,strong ) NSNumber * property_name; \
    @property ( nonatomic,assign ) NSInteger int_##property_name ;

#define field_integer_imp( property_name ) \
    @dynamic property_name ;   \
    - (NSInteger) int_##property_name { \
        NSInteger value =  [ [ self property_name ] integerValue ]; \
        return value; \
    }  \
    - (void) setInt_##property_name: (NSInteger ) value  { \
        NSString *propertyName =  @"" #property_name ; \
        NSString *propertySetter =  [propertyName asSetterMethodName] ; \
        objc_msgSend(self,sel_getUid([propertySetter UTF8String]), [NSNumber numberWithInt: value ]) ; \
    }


#define field_decimal_dec( property_name ) \
    @property ( nonatomic,strong ) NSDecimalNumber * property_name; \
    @property ( nonatomic ) double double_##property_name ;

#define field_decimal_imp( property_name ) \
    @dynamic property_name ;   \
    - (double) double_##property_name { \
        NSInteger value =  [ [ self property_name ] integerValue ]; \
        return value; \
    }  \
    - (void) setDouble_##property_name: (double) value  { \
        NSString *propertyName =  @"" #property_name ; \
        NSString *propertySetter =  [propertyName asSetterMethodName]; \
        objc_msgSend(self,sel_getUid([propertySetter UTF8String]), [NSDecimalNumber numberWithDouble: value ]) ; \
    }
