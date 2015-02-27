//
// Created by James Whitfield on 2/27/15.
// Copyright (c) 2015 NEiLAB, INC. All rights reserved.
//

#import <Foundation/Foundation.h>


#define AR_ROLLBACK_TO(status)   do { [status rollback] ; return; } while(0)
#define ar_rollback_to(status)   do { [status rollback] ; return; } while(0)


@class ARTransactionState;

typedef void (^ARSavePointTransactionBlock)(ARTransactionState *state);

@interface ARTransactionState : NSObject {}
- (void) rollback;
@property (nonatomic, readonly) BOOL isRolledBack;
@property (nonatomic, readonly) NSString *name;
- (instancetype)initWithName:(NSString *)aName;
+ (instancetype)stateWithName:(NSString *)aName;
@end

@interface NSString (ARAdditions)
- (NSString *) asSetterMethodName;
@end
