//
//  SHMaskViewController.m
//  Shield
//
//  Created by Magic-Unique on 2022/11/5.
//

#import "SHMaskViewController.h"
#import <Masonry/Masonry.h>

@interface SHMaskViewController ()

@property (nonatomic, strong, readonly) SHCoverConfiguration *configuration;

@property (nonatomic, strong, readonly) UIButton *authButton;

@property (nonatomic, strong, readonly) UIView *tipBar;

@property (nonatomic, strong, readonly) UIView *coverView;

@end

@implementation SHMaskViewController

- (instancetype)initWithConfiguration:(SHCoverConfiguration *)configuration {
    self = [super init];
    if (self) {
        _configuration = configuration;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.coverView];
    [self.view addSubview:self.tipBar];
    [self.view addSubview:self.authButton];
    [self.view setNeedsUpdateConstraints];
    
    self.maskState = self.maskState;
}

- (void)updateViewConstraints {
    [self.coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
    [self.tipBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(30);
    }];
    [self.authButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.centerX.mas_equalTo(self.view);
        make.centerY.mas_equalTo(self.view);
    }];
    [super updateViewConstraints];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (self.configuration.coverStyle == SHCoverStyleBlur) {
        [self.coverView removeFromSuperview];
        _coverView = nil;
        [self.view insertSubview:self.coverView atIndex:0];
        [self.view setNeedsUpdateConstraints];
    }
}

- (void)setMaskState:(SHMaskState)maskState {
    if (maskState == SHMaskStateBackground) {
        self.tipBar.hidden = NO;
        self.authButton.hidden = YES;
    }
    else if (maskState == SHMaskStateForeground) {
        self.tipBar.hidden = YES;
        self.authButton.hidden = NO;
    }
}

- (void)__onClickAuthButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(maskViewController:didClickAuthButton:)]) {
        [self.delegate maskViewController:self didClickAuthButton:sender];
    }
}

+ (UIImage *)__imageForLocalAuthType:(SHLocalAuthType)authType dismissType:(SHDismissType)dismissType {
    if (dismissType == SHDismissTypeAuto) {
        return nil;
    }
    NSBundle *binaryBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [binaryBundle pathForResource:@"Shield" ofType:@"bundle"];;
    NSBundle *resourceBundle = [NSBundle bundleWithPath:path];
    UIImage *image = nil;
    NSString *imageName = nil;
    if (authType == SHLocalAuthTypeFaceID) {
        imageName = @"faceid";
    }
    else if (authType == SHLocalAuthTypeTouchID) {
        imageName = @"touchid";
    }
    if (@available(iOS 13.0, *)) {
        image = [UIImage imageNamed:imageName inBundle:resourceBundle withConfiguration:nil];
    } else {
        NSString *path = [resourceBundle pathForResource:imageName ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:path];
    }
    return image;
}

@synthesize coverView = _coverView;
- (UIView *)coverView {
    if (!_coverView) {
        switch (self.configuration.coverStyle) {
            case SHCoverStyleBlur:
                if (@available(iOS 12.0, *)) {
                    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                        _coverView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
                    } else {
                        _coverView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
                    }
                } else {
                    _coverView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
                }
                break;
            case SHCoverStyleMonochrome:
                _coverView = [[UIView alloc] init];
                if (@available(iOS 13.0, *)) {
                    _coverView.backgroundColor = [UIColor systemBackgroundColor];
                } else {
                    _coverView.backgroundColor = [UIColor whiteColor];
                }
                break;
            default:
                break;
        }
    }
    return _coverView;
}

@synthesize authButton = _authButton;
- (UIButton *)authButton {
    if (!_authButton) {
        _authButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_authButton addTarget:self action:@selector(__onClickAuthButton:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *image = [SHMaskViewController __imageForLocalAuthType:SHGetDeviceLocalAuthType() dismissType:self.configuration.dismissType];
        [_authButton setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        if (@available(iOS 13.0, *)) {
            _authButton.tintColor = [UIColor labelColor];
        } else {
            _authButton.tintColor = [UIColor blackColor];
        }
    }
    return _authButton;
}

@synthesize tipBar = _tipBar;
- (UIView *)tipBar {
    if (!_tipBar) {
        UIButton *tipBar = [UIButton buttonWithType:UIButtonTypeCustom];
        [tipBar setTitle:self.configuration.tipBarContent forState:UIControlStateNormal];
        [tipBar setImage:self.configuration.tipBarImage forState:UIControlStateNormal];
        tipBar.titleLabel.font = [UIFont systemFontOfSize:13];
        if (@available(iOS 13.0, *)) {
            tipBar.backgroundColor = [UIColor systemBackgroundColor];
            [tipBar setTitleColor:[UIColor secondaryLabelColor] forState:UIControlStateNormal];
        } else {
            tipBar.backgroundColor = [UIColor whiteColor];
            [tipBar setTitleColor:[UIColor colorWithRed:0.23529411764705882
                                                  green:0.23529411764705882
                                                   blue:0.2627450980392157
                                                  alpha:1] forState:UIControlStateNormal]; // secondaryLabelColor
        }
        _tipBar = tipBar;
    }
    return _tipBar;
}

@end
