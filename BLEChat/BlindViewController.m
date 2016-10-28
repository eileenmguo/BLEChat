//
//  BlindViewController.m
//  BLE Chat
//
//  Created by Eileen Guo on 10/24/16.
//  Copyright © 2016 Red Bear Company Limited. All rights reserved.
//

#import "BlindViewController.h"

@interface BlindViewController ()

@property (strong, nonatomic) NSDate *lastSliderUpdateTime;
@property NSTimeInterval debounceTime;

@end

@implementation BlindViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLEDidConnect:) name:kBleConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLEDidDisconnect:) name:kBleDisconnectNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (onBLEDidReceiveData:) name:kBleReceivedDataNotification object:nil];

    self.BlindOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:(1.0-self.BlindSlider.value)];
    
    self.lastSliderUpdateTime = [NSDate date];
    self.debounceTime = 2.0;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)adjustBlindSlider:(UISlider *)sender {
    //BLE Shield Sender!!!!
    
//    NSString *s;
//    NSData *d;
//    
//    float f = (int) (self.BlindSlider.value * 180);
//    
//    s = [NSString stringWithFormat:@"p %f", f];
//    NSLog(@"%@", s);
//    d = [s dataUsingEncoding:NSUTF8StringEncoding];
//    
//    [self.self.bleShieldShield write:d];
    
    self.lastSliderUpdateTime = [NSDate date];
    
    self.BlindOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:(1.0-self.BlindSlider.value)];
//    UInt8 buf[3] = {0x03, 0x00, 0x00};  //opcode for slider we set to 0x03, other two bytes hold the data to send
    
    UInt8 buf[2] = {0x03, 0x00};
    buf[1] = (UInt8)(self.BlindSlider.value * 255);
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:2];
    [self.bleShield write:data];
    
}
- (IBAction)toggleManual_Auto_Switch:(UISwitch *)sender{
    NSLog(@"Toggled!");
    
    //1 is auto, 0 is manual
    UInt8 buf[2] = {0x04, 0x00};
    buf[1] = (UInt8)((self.Manual_Auto_Switch.isOn) ? 1 : 0);
    NSData *data = [[NSData alloc] initWithBytes:buf length:2];
    [self.bleShield write:data];
}

// NEW FUNCTION EXAMPLE: parse the received data from NSNotification
-(void) onBLEDidReceiveData:(NSNotification *)notification
{
    NSData* d = [[notification userInfo] objectForKey:@"data"];
    NSLog(@"%@", [d description]);
    UInt8 opCode;
    UInt8 data;
    [d getBytes:&opCode length:1];
    [d getBytes:&data range:NSMakeRange(1, 1)];
    float v;
    
    //receive data from photoresistor
    if (opCode == 0x00) {
        // Brighness change
        v = ((float)data) / 255.0;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.view.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:1-v alpha:1];
        });
    }
    //receive UI update data on button press
    else if(opCode == 0x01) {
        v = ((float)data) / 255.0;
        NSLog(@"%d", data);
        NSLog(@"%.4f", v);

        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                [self.BlindSlider setValue: v animated: YES];
                self.BlindOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:(1.0-v)];
            }];
            [self.Manual_Auto_Switch setOn: false];
        });
    }
    //receive switch info to update UI
    else if(opCode == 0x04) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.Manual_Auto_Switch setOn: true];

        });
    }
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
