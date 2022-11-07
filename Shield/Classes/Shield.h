//
//  Shield.h
//  Shield
//
//  Created by Magic-Unique on 2021/8/12.
//

#import <Foundation/Foundation.h>
#import "SHDefine.h"

@class LAContext;

@interface Shield : NSObject

@property (nonatomic, assign, readonly) BOOL enable;

@property (nonatomic, assign, readonly) SHLocalAuthType authType;

- (instancetype)initWithConfiguration:(SHCoverConfiguration *)configuration;

- (void)enableWithCompleted:(void (^)(BOOL success, NSError *error))completion;

- (void)disable;

@end
