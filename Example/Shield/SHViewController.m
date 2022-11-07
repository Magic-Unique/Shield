//
//  SHViewController.m
//  Shield
//
//  Created by Magic-Unique on 08/12/2021.
//  Copyright (c) 2021 Magic-Unique. All rights reserved.
//

#import "SHViewController.h"
#import "Shield+Example.h"

@interface SHViewController ()

@end

@implementation SHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSwitch:(UISwitch *)sender {
    if (sender.isOn) {
        sender.enabled = NO;
        [[Shield sharedInstance] enableWithCompleted:^(BOOL success, NSError *error) {
            if (!success) {
                sender.on = NO;
            }
            sender.enabled = YES;
        }];
    } else {
        [[Shield sharedInstance] disable];
    }
}

@end
