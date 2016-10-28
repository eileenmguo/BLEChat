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
    self.bleShield = [[BLE alloc] init];
    [self.bleShield controlSetup];
    self.bleShield.delegate = self;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLEDidConnect:) name:kBleConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLEDidDisconnect:) name:kBleDisconnectNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (onBLEDidReceiveData:) name:kBleReceivedDataNotification object:nil];

    self.BlindOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:(1.0-self.BlindSlider.value)];
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
    
    self.BlindOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:(1.0-self.BlindSlider.value)];
    UInt8 buf[3] = {0x03, 0x00, 0x00};  //opcode for slider we set to 0x03, other two bytes hold the data to send
    
    buf[1] = self.BlindSlider.value;
    buf[2] = (int)self.BlindSlider.value >> 8;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
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
    
    if (opCode == 0x00) {
        v = ((float)data) / 255.0;
        NSLog(@"%d", data);
        NSLog(@"%.4f", v);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.view.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:1-v alpha:1];
        });
    }
    
//    float value = [s floatValue];
//    self.BlindOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:(1.0-value)];
}

-(void) onBLEDidDisconnect:(NSNotification *)NSNotification
{
    NSLog(@"Disconnected");
}

-(void) onBLEDidConnect:(NSNotification *)notification
{
    NSString *name = [[notification userInfo] objectForKey:@"deviceName"];
    NSLog(@"%@ %s", name, "Connected");

    
    //    [indConnecting stopAnimating];
    
    self.BlindSlider.enabled = true;
    
    self.BlindSlider.value = 0;
    
    // send reset
    UInt8 buf[] = {0x04, 0x00, 0x00};  // opcode 0x04 is defined as a reset by the arduino code
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self.bleShield write:data];

    
    
    
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
