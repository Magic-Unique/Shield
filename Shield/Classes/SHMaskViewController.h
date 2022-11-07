//
//  SHMaskViewController.h
//  Shield
//
//  Created by Magic-Unique on 2022/11/5.
//

#import <UIKit/UIKit.h>
#import "SHDefine.h"

@class SHMaskViewController;


typedef NS_ENUM(NSUInteger, SHMaskState) {
    SHMaskStateBackground,
    SHMaskStateForeground,
};


@protocol SHMaskViewControllerDelegate <NSObject>

@optional

- (void)maskViewController:(SHMaskViewController *)maskViewController didClickAuthButton:(UIButton *)sender;

@end

@interface SHMaskViewController : UIViewController

@property (nonatomic, assign, readonly) SHLocalAuthType localAuthType;

@property (nonatomic, weak) id<SHMaskViewControllerDelegate> delegate;

@property (nonatomic, assign) SHMaskState maskState;

- (instancetype)initWithConfiguration:(SHCoverConfiguration *)configuration;

@end
