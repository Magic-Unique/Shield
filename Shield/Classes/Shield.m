//
//  Shield.m
//  Shield
//
//  Created by Magic-Unique on 2021/8/12.
//

#import "Shield.h"
#import "SHMaskViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

#pragma mark - Shield

@interface Shield () <SHMaskViewControllerDelegate>

@property (nonatomic, strong, readonly) SHCoverConfiguration *configuration;

@property (nonatomic, strong, readonly) SHMaskViewController *viewController;

@property (nonatomic, strong, readonly) UIWindow *window;

@property (nonatomic, assign) BOOL requesting;

@property (nonatomic, copy) void (^activeTask)(void);

@end

@implementation Shield

- (instancetype)initWithConfiguration:(SHCoverConfiguration *)configuration {
    self = [super init];
    if (self) {
        _configuration = configuration ?: [[SHCoverConfiguration alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__onEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__onEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__onFinishLaunched:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__onResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__onBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        _enable = [[NSUserDefaults standardUserDefaults] boolForKey:configuration.enableStateKey];
#ifdef DEBUG
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDictionary *info = [NSBundle mainBundle].infoDictionary;
            if (self.authType != SHLocalAuthTypeNone) {
                NSAssert(info[@"NSFaceIDUsageDescription"], @"Info.plist requires `NSFaceIDUsageDescription`");
            }
        });
#endif
    }
    return self;
}

- (void)enableWithCompleted:(void (^)(BOOL, NSError *))completion {
    if (self.enable == YES) {
        !completion ?: completion(YES, nil);
        return;
    }
    
    [self __requestLocalAuthWithPasscode:NO
                         localizedReason:nil
                               completed:^(BOOL success, NSError *error) {
        if (success) {
            self.enable = YES;
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success, error);
            });
        }
    }];
}

- (void)disable {
    self.enable = NO;
}

- (void)__requestUnlock:(void (^)(BOOL success, NSError *error))completion {
    [self __requestLocalAuthWithPasscode:YES
                         localizedReason:nil
                               completed:^(BOOL success, NSError *error) {
        if (success) {
            __weak typeof(self) weak_self = self;
            self.activeTask = ^{
                __strong typeof(weak_self) self = weak_self;
                [self __dismiss:YES];
            };
        }
        else if (error.code == LAErrorUserCancel && error.code == LAErrorSystemCancel) {
            // User Cancel
            return;
        }
        else if (error.code == LAErrorUserFallback) {
            
        }
        else {
            
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success, error);
            });
        }
    }];
}

- (void)__requestLocalAuthWithPasscode:(BOOL)passcode
                       localizedReason:(NSString *)localizedReason
                             completed:(void (^)(BOOL success, NSError *error))completion {
    self.requesting = YES;
    LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    if (passcode) {
        policy = LAPolicyDeviceOwnerAuthentication;
    }
    LAContext *context = [[LAContext alloc] init];
    localizedReason = localizedReason ?: self.configuration.localizedReason;
    [context evaluatePolicy:policy localizedReason:localizedReason reply:^(BOOL success, NSError * _Nullable error) {
        self.requesting = NO;
        !completion ?: completion(success, error);
    }];
}

- (void)__onFinishLaunched:(NSNotification *)notification {
    if (self.enable) {
        [self __onEnterBackground:notification];
        [self __onEnterForeground:notification];
    }
}

- (void)__onEnterBackground:(NSNotification *)notification {
    if (self.enable) {
        self.window.hidden = NO;
        self.viewController.maskState = SHMaskStateBackground;
    }
}

- (void)__onEnterForeground:(NSNotification *)notification {
    if (!self.enable) {
        return;
    }
    SHDismissType dismissType = self.configuration.dismissType;
    if (dismissType == SHDismissTypeAuto) {
        [self __dismiss:YES];
    }
    else if (dismissType == SHDismissTypeAutoTriggerLocalAuth) {
        if (self.authType == SHLocalAuthTypeNone) {
            [self __dismiss:YES];
            return;
        }
        [self __requestUnlock:nil];
    }
    self.viewController.maskState = SHMaskStateForeground;
}

- (void)__onResignActive:(id)notify {
    
}

- (void)__onBecomeActive:(id)notify {
    if (self.activeTask) {
        self.activeTask();
        self.activeTask = nil;
    }
}

- (void)__dismiss:(BOOL)animated {
    __auto_type imp = ^{
        if (animated) {
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                self.window.alpha = 0;
                self.window.transform = CGAffineTransformMakeScale(1.3, 1.3);
            } completion:^(BOOL finished) {
                self.window.hidden = YES;
                self.window.alpha = 1;
                self.window.transform = CGAffineTransformIdentity;
            }];
        } else {
            self.window.hidden = YES;
        }
    };
    if ([NSThread currentThread].isMainThread) {
        imp();
    } else {
        dispatch_sync(dispatch_get_main_queue(), imp);
    }
}

- (void)setEnable:(BOOL)enable {
    _enable = enable;
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:self.configuration.enableStateKey];
}

- (SHLocalAuthType)authType {
    return SHGetDeviceLocalAuthType();
}

#pragma mark - Mask View Controller Delegate

- (void)maskViewController:(SHMaskViewController *)maskViewController didClickAuthButton:(UIButton *)sender {
    [self __requestUnlock:nil];
}

@synthesize window = _window;
- (UIWindow *)window {
    if (!_window) {
        _window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        _window.windowLevel = UIWindowLevelStatusBar + 0.1;
        _window.rootViewController = self.viewController;
        _window.hidden = YES;
    }
    return _window;
}

@synthesize viewController = _viewController;
- (SHMaskViewController *)viewController {
    if (!_viewController) {
        _viewController = [[SHMaskViewController alloc] initWithConfiguration:self.configuration];
        _viewController.delegate = self;
    }
    return _viewController;
}

@end
