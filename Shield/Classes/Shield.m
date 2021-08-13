//
//  Shield.m
//  Shield
//
//  Created by Magic-Unique on 2021/8/12.
//

#import "Shield.h"

#pragma mark - Background View

@interface SHBackgroundView : UIView

@property (nonatomic, strong) SHCoverConfiguration *configuration;

@property (nonatomic, strong) UIView *coverView;

@end

@implementation SHBackgroundView

- (instancetype)initWithConfiguration:(SHCoverConfiguration *)configuration {
    self = [super init];
    if (self) {
        _configuration = configuration;
        [self addSubview:self.coverView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *subview in self.subviews) {
        subview.frame = self.bounds;
    }
}

@synthesize coverView = _coverView;
- (UIView *)coverView {
    if (!_coverView) {
        switch (self.configuration.coverStyle) {
            case SHCoverStyleLightBlur:
                _coverView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
                break;
            case SHCoverStyleDarkBlur:
                _coverView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
                break;
            default:
                _coverView = [[UIView alloc] init];
                _coverView.backgroundColor = [UIColor blackColor];
                break;
        }
    }
    return _coverView;
}

@end

#pragma mark - Shield

@implementation Shield

+ (instancetype)shared {
    static Shield *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc] init];
    });
    return _shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _configuration = [[SHCoverConfiguration alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__onResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__onBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)start {
    self.enable = YES;
}

- (void)stop {
    self.enable = NO;
}

- (void)__onResignActive:(NSNotification *)notification {
    if (self.enable) {
        UIWindow *win = self.window;
        SHBackgroundView *view = [[SHBackgroundView alloc] initWithConfiguration:self.configuration];
        [win addSubview:view];
        view.frame = win.bounds;
    }
}

- (void)__onBecomeActive:(NSNotification *)notification {
    UIWindow *win = self.window;
    [win.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:SHBackgroundView.class]) {
            [obj removeFromSuperview];
        }
    }];
}

- (void)setEnable:(BOOL)enable { _enable = enable; }
- (UIWindow *)window { return [UIApplication sharedApplication].delegate.window; }

@end


@implementation SHCoverConfiguration
@end
