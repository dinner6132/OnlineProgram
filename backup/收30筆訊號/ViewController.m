//
//  ViewController.m
//  TestNotification
//

#import "ViewController.h"

#import <EstimoteSDK/EstimoteSDK.h>
#import <AudioToolBox/AudioToolbox.h>

/* ----- iBeacon編號 Data ----- */
#define BEACON_1_UUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define BEACON_1_MAJOR 1
#define BEACON_1_MINOR 299

#define BEACON_2_UUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define BEACON_2_MAJOR 2
#define BEACON_2_MINOR 26532

#define BEACON_3_UUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define BEACON_3_MAJOR 3
#define BEACON_3_MINOR 299

#define BEACON_4_UUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define BEACON_4_MAJOR 4
#define BEACON_4_MINOR 299

#define BEACON_5_UUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define BEACON_5_MAJOR 5
#define BEACON_5_MINOR 38209

#define BEACON_6_UUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define BEACON_6_MAJOR 6
#define BEACON_6_MINOR 28798

#define BEACON_7_UUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define BEACON_7_MAJOR 7
#define BEACON_7_MINOR 16651

#define BEACON_8_UUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define BEACON_8_MAJOR 8
#define BEACON_8_MINOR 1357

#define BEACON_9_UUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define BEACON_9_MAJOR 9
#define BEACON_9_MINOR 35171

#define BEACON_10_UUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define BEACON_10_MAJOR 10
#define BEACON_10_MINOR 299

BOOL isBeaconWithUUIDMajorMinor(CLBeacon *beacon, NSString *UUIDString, CLBeaconMajorValue major, CLBeaconMinorValue minor) {
    return [beacon.proximityUUID.UUIDString isEqualToString:UUIDString] && beacon.major.unsignedShortValue == major && beacon.minor.unsignedShortValue == minor;
}

@interface ViewController () <ESTBeaconManagerDelegate ,CLLocationManagerDelegate>

@property (atomic) ESTBeaconManager *beaconManager;

@property (atomic) CLBeaconRegion *beaconRegion1;
@property (atomic) CLBeaconRegion *beaconRegion2;
@property (atomic) CLBeaconRegion *beaconRegion3;
@property (atomic) CLBeaconRegion *beaconRegion4;
@property (atomic) CLBeaconRegion *beaconRegion5;
@property (atomic) CLBeaconRegion *beaconRegion6;
@property (atomic) CLBeaconRegion *beaconRegion7;
@property (atomic) CLBeaconRegion *beaconRegion8;
@property (atomic) CLBeaconRegion *beaconRegion9;
@property (atomic) CLBeaconRegion *beaconRegion10;


@property (atomic, strong) NSString *UserBlock;
@property (atomic, strong) NSArray *beaconsArray;
@property (atomic, strong) NSMutableArray *iB_ID;
@property (atomic, strong) NSMutableArray *Point;
@property (retain, atomic) CLLocationManager *locationManager;
@property (strong, atomic) CLHeading *currentHeading;
@property (strong, atomic) NSMutableArray *Heading;
@property (weak, atomic) IBOutlet UILabel *label;

@end

@interface ESTTableViewCell : UITableViewCell
@end

static double heading;
static int file_count;

static float iB_R[10];  //beacon數量

//distance
static float iB_on[4];  //distance online data
static float x,y,t1,t2,t_temp,error_data; //座標累加
static float final_x,final_y;
static float point_value =0;


//filter
static int filter_count = 0;
static float signal_filter[4][30];

static float iB_of_AVG[4][24]={
    {-79.15116995,-76.43103448,-80.53065134,-83.12931034,-85.4137931,-85.2179803,-84.53756158,-83.54310345,-80.87068966,-83.04587438,-79.48275862,-75.84482759,-80.84667488,-83.82758621,-82.47413793,-84.48183498,-82.57758621,-84.34482759,-84.77586207,-86.74353448,-82.72814039,-83.0591133,-80.87931034,-79.56034483},
    {-86.54064039,-87.56604634,-86.93518519,-89.18197957,-88.27283358,-87.97811671,-88.11034483,-82.90517241,-88.73212005,-85.12931034,-83.97877984,-89.54125616,-87.79310345,-85.26724138,-86.06834975,-88.41899288,-84.43103448,-86.44827586,-85.4104064,-83.7533867,-84.00708128,-81.31896552,-86.60664112,-88.07423372},
    {-78.61206897,-78.60344828,-78.45320197,-75.63793103,-79.57758621,-73.42364532,-72.07758621,-76.19827586,-75.35344828,-75.76724138,-79.94827586,-80.11206897,-79.43965517,-77.92241379,-78.25862069,-76.53448276,-77.02586207,-74.12068966,-76.3362069,-78.72413793,-79.21551724,-80.04310345,-80.95320197,-83.32758621},
    {-82.27514368,-79.66779557,-78.88762315,-80.51416256,-79.97814039,-81.26200739,-82.67274536,-81.17750568,-81.4171798,-81.22229064,-83.59359606,-85.64688329,-82.9811622,-85.07788177,-82.93585796,-84.52770936,-82.92975734,-80.21305419,-84.39655172,-85.97844828,-84.26262315,-83.21397783,-85.68811576,-85.25}
};//Offline AVERAGE 0426-data -4 -8

//0426 方向 -4-8
static float iB_of_E[4][24]={
    {-75.75862069,-74.03448276,-81.77777778,-81.65517241,-84.72413793,-84.89655172,-90.03448276,-85.82758621,-78.75862069,-84.27586207,-80.24137931,-78.13793103,-85.21428571,-84.72413793,-82.34482759,-88,-84.86206897,-85.34482759,-88.75862069,-89.53571429,-84.06896552,-86.55172414,-82.75862069,-88.4137931},
    {-85.89655172,-85.4137931,-84.51724138,-86.10344828,-81.55172414,-83.48275862,-81.82758621,-80.55172414,-89,-83.17241379,-84.48275862,-91.51724138,-90,-85.51724138,-85.13793103,-91.71428571,-81.06896552,-81,-84.55172414,-79.34482759,-83.82142857,-81.51724138,-85.62068966,-87.96551724},
    {-81.34482759,-77.72413793,-81.57142857,-76.48275862,-80.5862069,-72.27586207,-67.68965517,-74.86206897,-74.06896552,-76.86206897,-79.68965517,-79.68965517,-83.13793103,-81.51724138,-77,-76.82758621,-75.75862069,-71.79310345,-80.03448276,-77.4137931,-79.4137931,-82.82758621,-79.44827586,-87.5862069},
    {-84.58333333,-82.46428571,-75.96428571,-81.64285714,-81.46428571,-81.25,-81.34615385,-81.82142857,-80.39285714,-79.78571429,-84.85714286,-86.34615385,-87.74074074,-85.71428571,-80.89285714,-84.35714286,-83.92592593,-79.10714286,-84,-88.5,-84.46428571,-80.82142857,-85.35714286,-85.57142857}
};//Offline-East

static float iB_of_S[4][24]={
    {-82.10344828,-75.75862069,-79.93103448,-81.72413793,-83.75862069,-86.93103448,-86.27586207,-84,-80.62068966,-83.72413793,-79.93103448,-74,-78.48275862,-86,-79.55172414,-82.89285714,-82.48275862,-85.06896552,-82.24137931,-84.86206897,-82.06896552,-83.62068966,-80.51724138,-75.55172414},
    {-88.71428571,-86.44827586,-89.74074074,-93.12,-92.43478261,-88.37931034,-92.10344828,-83.89655172,-92.96296296,-87.82758621,-87.84615385,-89.78571429,-86.24137931,-82.34482759,-83.92857143,-87.96551724,-84.31034483,-87.03448276,-88.60714286,-86.65517241,-83.24137931,-82.10344828,-83.89655172,-83.10344828},
    {-76.03448276,-79.24137931,-76.13793103,-74.65517241,-78.4137931,-67.14285714,-68.96551724,-73.79310345,-70.62068966,-74.51724138,-78.48275862,-75.17241379,-74.4137931,-73.4137931,-77.17241379,-73.62068966,-77.24137931,-75.13793103,-73.62068966,-77.79310345,-78.4137931,-75.96551724,-84.4137931,-82.17241379},
    {-81.93103448,-75.4137931,-85.79310345,-80.72413793,-82.86206897,-82.14285714,-85.20689655,-82.4137931,-82.79310345,-84.82758621,-80.86206897,-86.62068966,-82.34482759,-90.03448276,-83,-84.31034483,-82.27586207,-78.96551724,-86.62068966,-87.51724138,-85.51724138,-86.68965517,-86.44827586,-82}
};//Offline-South

static float iB_of_W[4][24]={
    {-80.53571429,-79.03448276,-82.82758621,-84.89655172,-86.96551724,-84.28571429,-83.35714286,-85.75862069,-86,-86.32142857,-81.89655172,-74.96551724,-82.4137931,-83,-84.86206897,-84.86206897,-83.68965517,-82.27586207,-86.89655172,-85.86206897,-84.46428571,-80.85714286,-78.34482759,-80.48275862},
    {-87.34482759,-85.25925926,-84.72413793,-87.68965517,-90.34482759,-91.89655172,-91.2,-83.75862069,-85.65517241,-85.79310345,-81.51724138,-88.03448276,-86.96551724,-85.34482759,-88.4137931,-89.44444444,-86.20689655,-87.93103448,-84.51724138,-88.39285714,-86.44827586,-79.31034483,-87.72413793,-88.17241379},
    {-78.48275862,-81.03448276,-79.4137931,-74.75862069,-79.10344828,-79.24137931,-79.20689655,-79.72413793,-78.82758621,-75.62068966,-80.13793103,-80.44827586,-80.44827586,-76.4137931,-77.96551724,-76.75862069,-78.65517241,-75.65517241,-74.03448276,-82.79310345,-80.5862069,-79.89655172,-82.57142857,-79.89655172},
    {-77.10344828,-77.06896552,-71.06896552,-75.79310345,-76.4137931,-78.10344828,-83.89655172,-78.55172414,-79.51724138,-76.4137931,-79.48275862,-80.72413793,-77.17241379,-76.48275862,-82.33333333,-82.5862069,-84,-77.17241379,-80.4137931,-80.4137931,-84.34482759,-81.48275862,-82.48275862,-82.21428571}
};//Offline-West

static float iB_of_N[4][24]={
    {-78.20689655,-76.89655172,-77.5862069,-84.24137931,-86.20689655,-84.75862069,-78.48275862,-78.5862069,-78.10344828,-77.86206897,-75.86206897,-76.27586207,-77.27586207,-81.5862069,-83.13793103,-82.17241379,-79.27586207,-84.68965517,-81.20689655,-86.71428571,-80.31034483,-81.20689655,-81.89655172,-73.79310345},
    {-84.20689655,-93.14285714,-88.75862069,-89.81481481,-88.76,-88.15384615,-87.31034483,-83.4137931,-87.31034483,-83.72413793,-82.06896552,-88.82758621,-87.96551724,-87.86206897,-86.79310345,-84.55172414,-86.13793103,-89.82758621,-83.96551724,-80.62068966,-82.51724138,-82.34482759,-89.18518519,-93.05555556},
    {-78.5862069,-76.4137931,-76.68965517,-76.65517241,-80.20689655,-75.03448276,-72.44827586,-76.4137931,-77.89655172,-76.06896552,-81.48275862,-85.13793103,-79.75862069,-80.34482759,-80.89655172,-78.93103448,-76.44827586,-73.89655172,-77.65517241,-76.89655172,-78.44827586,-81.48275862,-77.37931034,-83.65517241},
    {-85.48275862,-83.72413793,-82.72413793,-83.89655172,-79.17241379,-83.55172414,-80.24137931,-81.92307692,-82.96551724,-83.86206897,-89.17241379,-88.89655172,-84.66666667,-88.08,-85.51724138,-86.85714286,-81.51724138,-85.60714286,-86.55172414,-87.48275862,-82.72413793,-83.86206897,-88.46428571,-91.21428571}
};//Offline-North


@implementation ESTTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}
@end


@implementation ViewController

/* ----- 方位資料 ----- */
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    
    self.currentHeading = newHeading;
    //NSLog(@"%d",(int)newHeading.magneticHeading);
    
    
    heading = self.currentHeading.magneticHeading;
    
    //NSLog(@"%f",heading);
    
    if (newHeading.magneticHeading >= 315 || newHeading.magneticHeading < 45 ) {
        self.HeadingTextLabel.text = @"北";
    }else if( newHeading.magneticHeading >=45 && newHeading.magneticHeading < 135 ){
        self.HeadingTextLabel.text = @"東";
    }else if( newHeading.magneticHeading >= 135 && newHeading.magneticHeading < 225 ){
        self.HeadingTextLabel.text = @"南";
    }else if( newHeading.magneticHeading >= 225 && newHeading.magneticHeading < 315 ){
        self.HeadingTextLabel.text = @"西";
    }
}

/* ----- 搜尋iBeacon ----- */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    heading = 0;
    file_count = 1;
    final_x = 0;
    final_y = 0;
    
    self.currentHeading = [[CLHeading alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.headingFilter = 1;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingHeading];
    self.Threshold.text = [NSString stringWithFormat:@"%.3f",point_value];
    
    self.beaconManager = [ESTBeaconManager new];
    self.beaconManager.delegate = self;
    self.beaconManager.returnAllRangedBeaconsAtOnce = YES;
    
    [self.beaconManager requestWhenInUseAuthorization];
    
    self.beaconRegion1 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACON_1_UUID] major:BEACON_1_MAJOR minor:BEACON_1_MINOR identifier:@"beaconRegion1"];
    self.beaconRegion2 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACON_2_UUID] major:BEACON_2_MAJOR minor:BEACON_2_MINOR identifier:@"beaconRegion2"];
    self.beaconRegion3 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACON_3_UUID] major:BEACON_3_MAJOR minor:BEACON_3_MINOR identifier:@"beaconRegion3"];
    self.beaconRegion4 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACON_4_UUID] major:BEACON_4_MAJOR minor:BEACON_4_MINOR identifier:@"beaconRegion4"];
    self.beaconRegion5 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACON_5_UUID] major:BEACON_5_MAJOR minor:BEACON_5_MINOR identifier:@"beaconRegion5"];
    self.beaconRegion6 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACON_6_UUID] major:BEACON_6_MAJOR minor:BEACON_6_MINOR identifier:@"beaconRegion6"];
    self.beaconRegion7 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACON_7_UUID] major:BEACON_7_MAJOR minor:BEACON_7_MINOR identifier:@"beaconRegion7"];
    self.beaconRegion8 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACON_8_UUID] major:BEACON_8_MAJOR minor:BEACON_8_MINOR identifier:@"beaconRegion8"];
    self.beaconRegion9 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACON_9_UUID] major:BEACON_9_MAJOR minor:BEACON_9_MINOR identifier:@"beaconRegion9"];
    //self.beaconRegion10 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACON_10_UUID] major:BEACON_10_MAJOR minor:BEACON_10_MINOR identifier:@"beaconRegion10"];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //[self.beaconManager startRangingBeaconsInRegion:self.beaconRegion1];
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion2];
    //[self.beaconManager startRangingBeaconsInRegion:self.beaconRegion3];
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion4];
    //[self.beaconManager startRangingBeaconsInRegion:self.beaconRegion5];
    //[self.beaconManager startRangingBeaconsInRegion:self.beaconRegion6];
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion7];
    //[self.beaconManager startRangingBeaconsInRegion:self.beaconRegion8];
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion9];
    //[self.beaconManager startRangingBeaconsInRegion:self.beaconRegion10];
    
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion1];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion2];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion3];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion4];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion5];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion6];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion7];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion8];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion9];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion10];
    
}

- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    CLBeacon *nearestBeacon = [beacons firstObject];
    
    self.beaconsArray = beacons;
    
    
    switch (nearestBeacon.proximity) {
        case CLProximityUnknown:
            break;
        case CLProximityFar:
            break;
        case CLProximityNear:
            break;
        case CLProximityImmediate:
            break;
        default:
            break;
    }
    
    if (nearestBeacon) {
        if (isBeaconWithUUIDMajorMinor(nearestBeacon, BEACON_2_UUID, BEACON_2_MAJOR, BEACON_2_MINOR)) {
            // beacon #2
            self.label.text = @"beacon #2";
        } else if (isBeaconWithUUIDMajorMinor(nearestBeacon, BEACON_3_UUID, BEACON_3_MAJOR, BEACON_3_MINOR)) {
            // beacon #3
            self.label.text = @"beacon #3";
        } else if (isBeaconWithUUIDMajorMinor(nearestBeacon, BEACON_4_UUID, BEACON_4_MAJOR, BEACON_4_MINOR)) {
            // beacon #4
            self.label.text = @"beacon #4";
        } else if (isBeaconWithUUIDMajorMinor(nearestBeacon, BEACON_5_UUID, BEACON_5_MAJOR, BEACON_5_MINOR)) {
            // beacon #5
            self.label.text = @"beacon #5";
        }else if (isBeaconWithUUIDMajorMinor(nearestBeacon, BEACON_1_UUID, BEACON_1_MAJOR, BEACON_1_MINOR)) {
            // beacon #1
            self.label.text = @"beacon #1";
        }else if (isBeaconWithUUIDMajorMinor(nearestBeacon, BEACON_6_UUID, BEACON_6_MAJOR, BEACON_6_MINOR)) {
            // beacon #6
            self.label.text = @"beacon #6";
        }else if (isBeaconWithUUIDMajorMinor(nearestBeacon, BEACON_7_UUID, BEACON_7_MAJOR, BEACON_7_MINOR)) {
            // beacon #7
            self.label.text = @"beacon #7";
        }else if (isBeaconWithUUIDMajorMinor(nearestBeacon, BEACON_8_UUID, BEACON_8_MAJOR, BEACON_8_MINOR)) {
            // beacon #8
            self.label.text = @"beacon #8";
        }else if (isBeaconWithUUIDMajorMinor(nearestBeacon, BEACON_9_UUID, BEACON_9_MAJOR, BEACON_9_MINOR)) {
            // beacon #9
            self.label.text = @"beacon #9";
        }else if (isBeaconWithUUIDMajorMinor(nearestBeacon, BEACON_10_UUID, BEACON_10_MAJOR, BEACON_10_MINOR)) {
            // beacon #10
            self.label.text = @"beacon #10";
        }else
        {
            // no beacons found
            self.label.text = @"There are no beacons nearby";
        }
    }
}

- (void)beaconManager:(id)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        NSLog(@"Location Services authorization denied, can't range");
    }
}

- (void)beaconManager:(id)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"Ranging beacons failed for region '%@'\n\nMake sure that Bluetooth and Location Services are on, and that Location Services are allowed for this app. Also note that iOS simulator doesn't support Bluetooth.\n\nThe error was: %@", region.identifier, error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


//Online 訊號寫入陣列

-(void)OnlineMethod {
    
    for (int i=0; i < 9; i++) {
        iB_R[i] = -99;
    }
    
    for (int i=0; i < [self.beaconsArray count]; i++) {
        CLBeacon *beacon = [self.beaconsArray objectAtIndex:i];
        
        if (isBeaconWithUUIDMajorMinor(beacon, BEACON_1_UUID, BEACON_1_MAJOR, BEACON_1_MINOR)) {
            
            iB_R[0] = beacon.rssi;
            //NSLog(@"ib1=%f",iB_R[0]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_2_UUID, BEACON_2_MAJOR, BEACON_2_MINOR)) {
            
            iB_R[1] = beacon.rssi;
            NSLog(@"ib2=%f",iB_R[1]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_3_UUID, BEACON_3_MAJOR, BEACON_3_MINOR)) {
            
            iB_R[2] = beacon.rssi;
            //NSLog(@"ib3=%f",iB_R[2]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_4_UUID, BEACON_4_MAJOR, BEACON_4_MINOR)) {
            
            iB_R[3] = beacon.rssi;
            NSLog(@"ib4=%f",iB_R[3]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_5_UUID, BEACON_5_MAJOR, BEACON_5_MINOR)) {
            
            iB_R[4] = beacon.rssi;
            //NSLog(@"ib5=%f",iB_R[4]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_6_UUID, BEACON_6_MAJOR, BEACON_6_MINOR)) {
            
            iB_R[5] = beacon.rssi;
            //NSLog(@"ib6=%f",iB_R[5]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_7_UUID, BEACON_7_MAJOR, BEACON_7_MINOR)) {
            
            iB_R[6] = beacon.rssi;
            NSLog(@"ib7=%f",iB_R[6]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_8_UUID, BEACON_8_MAJOR, BEACON_8_MINOR)) {
            
            iB_R[7] = beacon.rssi;
            //NSLog(@"ib8=%f",iB_R[7]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_9_UUID, BEACON_9_MAJOR, BEACON_9_MINOR)) {
            
            iB_R[8] = beacon.rssi;
            NSLog(@"ib9=%f",iB_R[8]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_10_UUID, BEACON_10_MAJOR, BEACON_10_MINOR)) {
          
          iB_R[9] = beacon.rssi;
          NSLog(@"ib10=%f",iB_R[9]);
          
          }
    }
    
    //    iB_R[1] =-86.7241;
    //    iB_R[3] =-89.9286;
    //    iB_R[6] =-81.7931;
    //    iB_R[8] =-85.8889;
    
    for (int i=0; i < 9; i++) {
        if (iB_R[i] == 0) {
            iB_R[i] = -99;
        }
    }
    
    /* ------------------------------------------------------------ */
    
    //訊號判斷
    if(iB_R[1] >= -90 && iB_R[3] >= -90 && iB_R[6] >= -90 && iB_R[8] >= -90) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pointLabel.text = @"計算中...";
            [self filter_method];
        });
    }
}

-(void)filter_method {
    //signal_filter[4][30] -> 過濾 -> iB_on[0,1,2,3];
    float temp;
    float sg_temp[4];
    
    if (filter_count < 30) {
        signal_filter[0][filter_count] = iB_R[1];
        signal_filter[1][filter_count] = iB_R[3];
        signal_filter[2][filter_count] = iB_R[6];
        signal_filter[3][filter_count] = iB_R[8];
        filter_count++;
        self.fileTextLabel.text = [NSString stringWithFormat:@"%d",filter_count];
    }else{
        
        //排序
        for(int i=0;i<30;i++){
            for (int j=0; j<30; j++) {
                if(signal_filter[0][i] > signal_filter[0][j])
                {
                    temp = signal_filter[0][i];
                    signal_filter[0][i] = signal_filter[0][j];
                    signal_filter[0][j] = temp;
                }
                if(signal_filter[1][i] > signal_filter[1][j])
                {
                    temp = signal_filter[1][i];
                    signal_filter[1][i] = signal_filter[1][j];
                    signal_filter[1][j] = temp;
                }
                if(signal_filter[2][i] > signal_filter[2][j])
                {
                    temp = signal_filter[2][i];
                    signal_filter[2][i] = signal_filter[2][j];
                    signal_filter[2][j] = temp;
                }
                if(signal_filter[3][i] > signal_filter[3][j])
                {
                    temp = signal_filter[3][i];
                    signal_filter[3][i] = signal_filter[3][j];
                    signal_filter[3][j] = temp;
                }
            }
        }
        //取前15
        sg_temp[0] = 0; sg_temp[1] = 0; sg_temp[2] = 0; sg_temp[3] = 0;
        for (int i=0; i<15; i++) {
            sg_temp[0] += signal_filter[0][i];
            sg_temp[1] += signal_filter[1][i];
            sg_temp[2] += signal_filter[2][i];
            sg_temp[3] += signal_filter[3][i];
        }
        //平均
        sg_temp[0] = sg_temp[0]/15;
        sg_temp[1] = sg_temp[1]/15;
        sg_temp[2] = sg_temp[2]/15;
        sg_temp[3] = sg_temp[3]/15;
        
        //訊號取用
        iB_on[0] = sg_temp[0];
        iB_on[1] = sg_temp[1];
        iB_on[2] = sg_temp[2];
        iB_on[3] = sg_temp[3];
        
        [timer invalidate];
        timer = nil;
        
        filter_count = 0;
        self.fileTextLabel.text = [NSString stringWithFormat:@"%d",filter_count];
        self.ScanStatus.text = [NSString stringWithFormat:@"Stop scan"];
        
        //跑一次distance_matching
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self Matching];
            [self distance_matching];
        });
        
     //over
    }
}


-(void)distance_matching{
    
    float dis[24];
    float pt[24]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24};
    float temp;
    int i=0,j=0,k=0;
    
    
    //方向比對
//    for (int j =0; j<24; j++) {
//        if (heading >= 315 || heading < 45 ){
//            
//            temp = sqrt(pow((iB_on[0]-iB_of_E[0][j]),2)+pow((iB_on[1]-iB_of_E[1][j]),2)+pow((iB_on[2]-iB_of_E[2][j]),2)+pow((iB_on[3]-iB_of_E[3][j]),2));
//            dis[j] = temp;
//            
//        }else if(heading >=45 && heading < 135 ){
//            
//            temp = sqrt(pow((iB_on[0]-iB_of_S[0][j]),2)+pow((iB_on[1]-iB_of_S[1][j]),2)+pow((iB_on[2]-iB_of_S[2][j]),2)+pow((iB_on[3]-iB_of_S[3][j]),2));
//            dis[j] = temp;
//            
//        }else if(heading >= 135 && heading < 225 ){
//            
//            temp = sqrt(pow((iB_on[0]-iB_of_W[0][j]),2)+pow((iB_on[1]-iB_of_W[1][j]),2)+pow((iB_on[2]-iB_of_W[2][j]),2)+pow((iB_on[3]-iB_of_W[3][j]),2));
//            dis[j] = temp;
//            
//        }else if(heading >= 225 && heading < 315 ){
//            
//            temp = sqrt(pow((iB_on[0]-iB_of_N[0][j]),2)+pow((iB_on[1]-iB_of_N[1][j]),2)+pow((iB_on[2]-iB_of_N[2][j]),2)+pow((iB_on[3]-iB_of_N[3][j]),2));
//            dis[j] = temp;
//            
//        }
//    }
    
    
      //AVG比對
     for(j=0;j<24;j++)
     {
         temp = sqrt(pow((iB_on[0]-iB_of_AVG[0][j]),2)+pow((iB_on[1]-iB_of_AVG[1][j]),2)+pow((iB_on[2]-iB_of_AVG[2][j]),2)+pow((iB_on[3]-iB_of_AVG[3][j]),2));
         dis[j] = temp;
     }
    
    
    
    for(i=0;i<24;i++)
    {
        for(j=0;j<24;j++)
        {
            if(dis[i]<dis[j])
            {
                temp = dis[i];
                dis[i] = dis[j];
                dis[j] = temp;
                
                temp = pt[i];
                pt[i] = pt[j];
                pt[j] = temp;
            }
        }
    }
    
    //調整K
    k=3;    
    //計算座標
    
    t1 = 0; t2 = 0;
    
    i=0;
    while (i<k) {
        t_temp = pt[i];
        [self func];
        i++;
    }
    
    //直接算
    final_x = t1/k;
    final_y = t2/k;
    error_data=sqrt((x-final_x)*(x-final_x)+(y-final_y)*(y-final_y));
    
    self.pointLabel.text = [NSString stringWithFormat:@"(%.1f,%.1f)",final_x,final_y];
    self.ErrorData.text = [NSString stringWithFormat:@"%f",error_data];
    
    [self WriteToFile];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

//設定定位座標
- (IBAction)ChangeValue:(UIStepper *)sender {
    NSLog(@"%f",sender.value);
    point_value = sender.value;
    self.Threshold.text = [NSString stringWithFormat:@"%.0f",point_value];
    [self func2];
    NSLog(@"x:%f y:%f",x,y);
}


- (IBAction)button03:(id)sender {
    
    file_count = 0;
    
    
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
        self.ScanStatus.text = [NSString stringWithFormat:@"Stop scan"];
    }else{
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(OnlineMethod)
                                               userInfo:nil
                                                repeats:YES];
        self.ScanStatus.text = [NSString stringWithFormat:@"online scaning"];
        
    }
    
}

-(void)WriteToFile {
    //寫一次檔案 創檔,寫檔x1
    
    NSFileManager *fm = [NSFileManager defaultManager];
    //Create 目錄
    NSString *dir;
    dir = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/ErrorData"];
    
    //Create file
    NSString *file = [dir stringByAppendingFormat:@"/data.txt"];
    NSError *error;
    NSString *filedata;
    NSFileHandle *update = [NSFileHandle fileHandleForWritingAtPath:file];
    NSData *data;
    
    BOOL success = [fm createDirectoryAtPath:
                    dir withIntermediateDirectories:YES attributes:nil error:&error];
    if (success) {
        NSLog(@"目錄建立成功");
    }else {
        NSLog(@"目錄建立失敗");
    }
    
    NSString *strDate = [NSString stringWithFormat:@"point, error \n"];
    data = [strDate dataUsingEncoding:NSUTF8StringEncoding];
        //寫入檔案
            if ([fm fileExistsAtPath:file])  {
                NSLog(@"檔案存在，寫入檔案");
                filedata = [NSString stringWithFormat:@"%.1f , %f\n",point_value,error_data];
                data = [filedata dataUsingEncoding:NSUTF8StringEncoding];
                [update seekToEndOfFile];
                [update writeData:data];
                file_count ++;
                NSString *n = @"-----------\n";
                data = [n dataUsingEncoding:NSUTF8StringEncoding];
                [update seekToEndOfFile];
                [update writeData:data];
            }else{
                filedata = [NSString stringWithFormat:@"%.1f , %f\n",point_value,error_data];
                data = [filedata dataUsingEncoding:NSUTF8StringEncoding];
                
                NSLog(@"檔案不存在，新增檔案並寫入");
                success = [fm createFileAtPath:file contents:data attributes:nil];
                if (success) {
                    NSLog(@"Create File success");
                }else{
                    NSLog(@"Create File ERROR");
                }
            }
    [update closeFile];
}

-(void)func{
    
    
    if(t_temp == 1)
    {
        t1 += 0; t2 += 5;
    }else if(t_temp == 2){
        t1 +=0; t2 +=4;
    }else if(t_temp == 3){
        t1 +=0; t2 +=3;
    }else if(t_temp == 4){
        t1 +=0; t2 +=2;
    }else if(t_temp == 5){
        t1 +=0; t2 +=1;
    }else if(t_temp == 6){
        t1 +=0; t2 +=0;
    }else if(t_temp == 7){
        t1 +=1; t2 +=0;
    }else if(t_temp == 8){
        t1 +=1; t2 +=1;
    }else if(t_temp == 9){
        t1 +=1; t2 +=2;
    }else if(t_temp == 10){
        t1 +=1; t2 +=3;
    }else if(t_temp == 11){
        t1 +=1; t2 +=4;
    }else if(t_temp == 12){
        t1 +=1; t2 +=5;
    }else if(t_temp == 13){
        t1 +=2; t2 +=5;
    }else if(t_temp == 14){
        t1 +=2; t2 +=4;
    }else if(t_temp == 15){
        t1 +=2; t2 +=3;
    }else if(t_temp == 16){
        t1 +=2; t2 +=2;
    }else if(t_temp == 17){
        t1 +=2; t2 +=1;
    }else if(t_temp == 18){
        t1 +=2; t2 +=0;
    }else if(t_temp == 19){
        t1 +=3; t2 +=0;
    }else if(t_temp == 20){
        t1 +=3; t2 +=1;
    }else if(t_temp == 21){
        t1 +=3; t2 +=2;
    }else if(t_temp == 22){
        t1 +=3; t2 +=3;
    }else if(t_temp == 23){
        t1 +=3; t2 +=4;
    }else if(t_temp == 24){
        t1 +=3; t2 +=5;
    }
}

-(void)func2{
    
    x = 0; y = 0;
    
    if(point_value == 1)
    {
        x += 0; y += 5;
    }else if(point_value == 2){
        x +=0; y +=4;
    }else if(point_value == 3){
        x +=0; y +=3;
    }else if(point_value == 4){
        x +=0; y +=2;
    }else if(point_value == 5){
        x +=0; y +=1;
    }else if(point_value == 6){
        x +=0; y +=0;
    }else if(point_value == 7){
        x +=1; y +=0;
    }else if(point_value == 8){
        x +=1; y +=1;
    }else if(point_value == 9){
        x +=1; y +=2;
    }else if(point_value == 10){
        x +=1; y +=3;
    }else if(point_value == 11){
        x +=1; y +=4;
    }else if(point_value == 12){
        x +=1; y +=5;
    }else if(point_value == 13){
        x +=2; y +=5;
    }else if(point_value == 14){
        x +=2; y +=4;
    }else if(point_value == 15){
        x +=2; y +=3;
    }else if(point_value == 16){
        x +=2; y +=2;
    }else if(point_value == 17){
        x +=2; y +=1;
    }else if(point_value == 18){
        x +=2; y +=0;
    }else if(point_value == 19){
        x +=3; y +=0;
    }else if(point_value == 20){
        x +=3; y +=1;
    }else if(point_value == 21){
        x +=3; y +=2;
    }else if(point_value == 22){
        x +=3; y +=3;
    }else if(point_value == 23){
        x +=3; y +=4;
    }else if(point_value == 24){
        x +=3; y +=5;
    }
}


@end
