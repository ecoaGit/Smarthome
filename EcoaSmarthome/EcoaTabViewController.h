//
//  TabViewController.h
//  EcoaSmarthome
//
//  Created by Apple on 2014/5/26.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "import.h"
#import "EcoaSipManager.h"
#import "AppDelegate.h"

@interface EcoaTabViewController : UITabBarController <UITabBarControllerDelegate>
{
    EcoaSipManager *manager;
}

@end
