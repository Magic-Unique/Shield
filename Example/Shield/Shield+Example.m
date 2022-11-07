//
//  Shield+Example.m
//  Shield_Example
//
//  Created by 吴双 on 2022/11/7.
//  Copyright © 2022 Magic-Unique. All rights reserved.
//

#import "Shield+Example.h"

@implementation Shield (Example)

+ (instancetype)sharedInstance {
    static Shield *shield = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SHCoverConfiguration *configuration = [[SHCoverConfiguration alloc] init];
        configuration.dismissType = SHDismissTypeAutoTriggerLocalAuth;
        shield = [[Shield alloc] initWithConfiguration:configuration];
    });
    return shield;
}

@end
