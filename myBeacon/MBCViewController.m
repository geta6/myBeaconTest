//
//  MBCViewController.m
//  myBeacon
//
//  Created by geta6 on 5/26/14.
//  Copyright (c) 2014 geta6. All rights reserved.
//

#import "MBCViewController.h"

#define isRegion(region) [region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]

@interface MBCViewController ()
{
  __weak IBOutlet UILabel* beaconRange;
}

@property (nonatomic, readwrite) CLLocationManager* locationManager;
@property (nonatomic, readwrite) NSUUID* proximityUUID;
@property (nonatomic, readwrite) CLBeaconRegion* beaconRegion;

@end

@implementation MBCViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"ここにUUID"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID identifier:@"net.geta6.mybeaconregion"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
  }
}

- (void)setRangeTextWithBeacon:(CLBeacon*)beacon
{
  [beaconRange setText:[NSString stringWithFormat:@"major:%@\nminor:%@\naccuracy:%f\nrssi:%d",
                        beacon.major, beacon.minor, beacon.accuracy, beacon.rssi]];
}

// アプリケーションの起動時、Beaconの範囲内にいるかどうかのチェッカーをキックする
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
  [self.locationManager requestStateForRegion:self.beaconRegion];
}

// ↑を受けてBeaconの範囲内にいるか判定
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
  if (state == CLRegionStateInside && isRegion(region))
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

// Beacon範囲内に入った
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
  if (isRegion(region))
    [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
}

// Beacon範囲内から出た
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
  if (isRegion(region))
    [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
}

// Beacon範囲内にいる時にキックされ続けるdelegate
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
  if (beacons.count > 0)
    [self setRangeTextWithBeacon:beacons.firstObject];
}

@end
