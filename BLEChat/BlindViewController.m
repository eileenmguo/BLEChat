//
//  BlindViewController.m
//  BLE Chat
//
//  Created by Eileen Guo on 10/24/16.
//  Copyright © 2016 Red Bear Company Limited. All rights reserved.
//

#import "BlindViewController.h"

@interface BlindViewController ()

@end

@implementation BlindViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLEDidConnect:) name:kBleConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLEDidDisconnect:) name:kBleDisconnectNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (onBLEDidReceiveData:) name:kBleReceivedDataNotification object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)adjustBlindSlider:(UISlider *)sender {
    //BLE Shield Sender!!!!
    
    self.BlindOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:(1.0-self.BlindSlider.value)];
    
    NSString *s;
    NSData *d;
    
    float f = (int) (self.BlindSlider.value * 180);
    
    s = [NSString stringWithFormat:@"p %f", f];
    NSLog(@"%@", s);
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.bleShield write:d];
}


// NEW FUNCTION EXAMPLE: parse the received data from NSNotification
-(void) onBLEDidReceiveData:(NSNotification *)notification
{
    NSData* d = [[notification userInfo] objectForKey:@"data"];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSLog(@"%@", s);
    
    float value = [s floatValue];
    self.BlindOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:(1.0-value)];
}

-(void) onBLEDidDisconnect:(NSNotification *)NSNotification
{
    NSLog(@"Disconnected");
}

-(void) onBLEDidConnect:(NSNotification *)notification
{
    NSString *name = [[notification userInfo] objectForKey:@"deviceName"];
    NSLog(@"%@", name);
    //    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
}


-(BLE*)bleShield
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.bleShield;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
