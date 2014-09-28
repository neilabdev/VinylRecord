

#import <Foundation/Foundation.h>

/*
#define validate_uniqueness_of(aField) \
    [self performSelector : @selector(validateUniquenessOfField:) withObject : @ ""#aField ""];

#define validate_presence_of(aField) \
    [self performSelector : @selector(validatePresenceOfField:) withObject : @ ""#aField ""];

#define validate_field_with_validator(aField, aValidator) \
    [self performSelector : @selector(validateField:withValidator:) \
     withObject : @ ""#aField "" \
     withObject : @ ""#aValidator ""]; \
     */



#define callbacks_do(callbacks) \
    + (void)initializeCallbacks{ \
        callbacks \
    }
