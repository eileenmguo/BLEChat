//
//  BlindViewController.h
//  BLE Chat
//
//  Created by Eileen Guo on 10/24/16.
//  Copyright © 2016 Red Bear Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"
#import "AppDelegate.h"

@interface BlindViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISlider *BlindSlider;
@property (weak, nonatomic) IBOutlet UIView *BlindOverlay;
@property (weak, nonatomic) IBOutlet UISwitch *Manual_Auto_Switch;
@property (strong, nonatomic) BLE *bleShield;

@end
