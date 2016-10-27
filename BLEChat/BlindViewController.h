//
//  BlindViewController.h
//  BLE Chat
//
//  Created by Eileen Guo on 10/24/16.
//  Copyright © 2016 Red Bear Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlindViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISlider *BlindSlider;
@property (weak, nonatomic) IBOutlet UIView *BlindOverlay;

@end
