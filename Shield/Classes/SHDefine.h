//
//  SHDefine.h
//  Shield_Example
//
//  Created by Magic-Unique on 2022/11/5.
//  Copyright © 2022 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, SHCoverStyle) {
    SHCoverStyleBlur,
    SHCoverStyleMonochrome,
};

typedef NS_ENUM(NSUInteger, SHDismissType) {
    SHDismissTypeAuto,
    SHDismissTypeAutoTriggerLocalAuth,
    SHDismissTypeManualTriggerLocalAuth,
};

@interface SHCoverConfiguration : NSObject

@property (nonatomic, assign) SHDismissType dismissType;

@property (nonatomic, assign) SHCoverStyle coverStyle;

@property (nonatomic, strong) NSString *enableStateKey;

@property (nonatomic, strong) NSString *localizedReason;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UIImage *tipBarImage;

@property (nonatomic, strong) NSString *tipBarContent;

@end


typedef NS_ENUM(NSUInteger, SHLocalAuthType) {
    SHLocalAuthTypeNone,
    SHLocalAuthTypeTouchID,
    SHLocalAuthTypeFaceID,
};

FOUNDATION_EXTERN SHLocalAuthType SHGetDeviceLocalAuthType(void);
