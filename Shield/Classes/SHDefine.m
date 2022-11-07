//
//  SHDefine.m
//  Shield_Example
//
//  Created by Magic-Unique on 2022/11/5.
//  Copyright © 2022 Magic-Unique. All rights reserved.
//

#import "SHDefine.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation SHCoverConfiguration

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        _tipBarContent = [NSString stringWithFormat:@"%@全力保护您的信息安全", appName];
        _enableStateKey = @"com.unique.shield.enable";
        
        NSString *usage = @"解锁应用";
        _localizedReason = usage;
    }
    return self;
}

@end

FOUNDATION_EXTERN SHLocalAuthType SHGetDeviceLocalAuthType(void) {
    static SHLocalAuthType authType = SHLocalAuthTypeNone;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LAContext *context = [[LAContext alloc] init];
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:NULL]) {
            authType = SHLocalAuthTypeTouchID;
            if (@available(iOS 11.0, *)) {
                LABiometryType biometryType = [context biometryType];
                switch (biometryType) {
                    case LABiometryTypeTouchID: authType = SHLocalAuthTypeTouchID; break;
                    case LABiometryTypeFaceID: authType = SHLocalAuthTypeFaceID; break;
                    default: authType = SHLocalAuthTypeNone; break;
                }
            }
        }
    });
    return authType;
}
