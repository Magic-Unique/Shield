//
//  Shield.h
//  Shield
//
//  Created by Magic-Unique on 2021/8/12.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, SHCoverStyle) {
    SHCoverStyleLightBlur,
    SHCoverStyleDarkBlur,
};



@interface SHCoverConfiguration : NSObject

@property (nonatomic, assign) SHCoverStyle coverStyle;

@end



@interface Shield : NSObject

@property (nonatomic, assign, readonly) BOOL enable;

@property (nonatomic, strong) SHCoverConfiguration *configuration;

+ (instancetype)shared;

- (void)start;
- (void)stop;

@end
