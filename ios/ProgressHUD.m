//
//  ProgressHUD.m
//  RNBluetoothPrinter
//
//  Created by Zayin Krige on 2018/01/31.
//  Copyright © 2018 Marc Shilling. All rights reserved.
//

#import "ProgressHUD.h"
@import MBProgressHUD;

@implementation ProgressHUD

+ (void)showMessage:(NSString *)message {
    
    UIView *view = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (hud == nil) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:NO];
    }
    hud.label.text = message;
    hud.minShowTime = 0.5;
    hud.removeFromSuperViewOnHide = YES;
    [MBProgressHUD hideHUDForView:view animated:NO];

}

@end
