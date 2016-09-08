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
static int dir_count;

static float iB_R[10];  //beacon數量

//distance
static float iB_on[4];  //distance online data
static float x,y,t1,t2,t_temp,error_data; //座標累加
static float final_x,final_y;
static float point_value =0;
static int k;


//filter
static int action_temp = 0;
static int filter_count = 0;
static float signal_filter[4][7];

//Offline AVERAGE off-data alldif
static float iB_of_AVG[4][56]={
    {-81.449999,-82.424999,-82.125,-79.6000005,-78.749998,-75.3999975,-77.39999975,-76.29999925,-76.1499995,-73.20000075,-69.7250005,-69.35000025,-71.27499925,-71.30000125,-63.34999825,-68.00000025,-71.674999,-74.674999,-72.37500025,-76.80000125,-75.02499975,-74.6500015,-77.2749995,-78.37499975,-81.29999925,-81.4750005,-83.04999925,-81.450001,-79.27499975,-81.3500005,-82.07500075,-79.8999995,-76.77499975,-77.424999,-76.25000175,-75.04999925,-78.17500125,-75.07500075,-76.5750005,-74.0999985,-68.24999925,-66.57500175,-67.19999775,-69.74999775,-70.95000075,-73.5,-74.375,-77.29999725,-77.699999,-75.2250005,-77.050001,-80.22500025,-78.82500075,-78.04999925,-78.75,-79.65000175},
    {-88.375,-87.875,-85.3249985,-77.2250005,-78.42499725,-84.92499925,-86.5749985,-85.800001,-91.12500025,-91.57499875,-92.5999985,-93.75,-93.07499875,-93.574999,-93.624998,-92.875,-93.824999,-93.15000175,-91.27499975,-88.49999975,-90.200001,-87.92500125,-83.67500125,-83.375,-80.55000125,-84.5,-86.70000075,-87.55000125,-86.52499975,-87.125,-85.3000015,-83.27499975,-86.8250005,-86.22500225,-88.0249995,-90.42499925,-90.175001,-92.74999825,-93.24999975,-91.02499775,-92.1499995,-91.92500125,-92.70000075,-92.50000025,-92.3999995,-90.97499825,-92.924999,-89.57499875,-87.875,-88.875,-83.02499975,-86.125,-84.69999875,-89.3500005,-86.47500025,-87.39999775},
    {-68.800001,-72.75,-71.074997,-74.550001,-74.49999825,-76.450001,-78.14999975,-77.425001,-78.5,-79.10000025,-80.15000175,-81.42499925,-84.125002,-80.72500225,-81.29999925,-81.57499875,-83.574999,-83.1750015,-80.64999975,-81.25,-78.65000175,-78.37499975,-76.500002,-74.700001,-74.375,-71.19999875,-70.625,-64.32500075,-61.17500025,-67.37500175,-72,-73.1499995,-74.45000075,-76.174999,-77.6750015,-77.375,-77.2250025,-81.25,-82.5249995,-82.45000075,-81.1500015,-81.77499975,-80.3999975,-80.375,-81.1499995,-80.2250005,-79.6000025,-75.2749995,-75.07500075,-76.825001,-76.79999925,-75.25,-73,-72.62500025,-67.37500175,-67.79999925},
    {-93.92500125,-93.67499925,-93.07499875,-92.74999975,-91.17499925,-88.62499975,-85.5,-87.1500015,-84.875002,-86.62499975,-87.17500125,-88.10000075,-89.89999975,-89.4750005,-90.32499875,-90.30000125,-89.22499825,-87.22500025,-84.875,-86.6000025,-82.82499875,-89.04999925,-90.45000075,-90.575001,-92.125,-91.8999995,-92.25,-93.20000075,-94.074999,-94.2749995,-94.6000005,-93.57499875,-91.90000175,-86.02500175,-87.7250005,-81.37500225,-83.3499985,-84.25,-89.17500125,-90.5,-87.7250005,-92.575001,-93.5,-91.4000015,-89.97500025,-89,-83.7250005,-73.325001,-78.10000075,-85.57500075,-88,-91.72500075,-91.22500025,-91.0750005,-92.49999975,-94.125}
};//Offline - 行政大樓


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
    dir_count = 1;
    final_x = 0;
    final_y = 0;
    
    self.AppVersionLabel.text = @"修改動平均56pt1-10k";
    
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
            //NSLog(@"ib2=%f",iB_R[1]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_3_UUID, BEACON_3_MAJOR, BEACON_3_MINOR)) {
            
            iB_R[2] = beacon.rssi;
            //NSLog(@"ib3=%f",iB_R[2]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_4_UUID, BEACON_4_MAJOR, BEACON_4_MINOR)) {
            
            iB_R[3] = beacon.rssi;
            //NSLog(@"ib4=%f",iB_R[3]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_5_UUID, BEACON_5_MAJOR, BEACON_5_MINOR)) {
            
            iB_R[4] = beacon.rssi;
            //NSLog(@"ib5=%f",iB_R[4]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_6_UUID, BEACON_6_MAJOR, BEACON_6_MINOR)) {
            
            iB_R[5] = beacon.rssi;
            //NSLog(@"ib6=%f",iB_R[5]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_7_UUID, BEACON_7_MAJOR, BEACON_7_MINOR)) {
            
            iB_R[6] = beacon.rssi;
            //NSLog(@"ib7=%f",iB_R[6]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_8_UUID, BEACON_8_MAJOR, BEACON_8_MINOR)) {
            
            iB_R[7] = beacon.rssi;
            //NSLog(@"ib8=%f",iB_R[7]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_9_UUID, BEACON_9_MAJOR, BEACON_9_MINOR)) {
            
            iB_R[8] = beacon.rssi;
            //NSLog(@"ib9=%f",iB_R[8]);
            
        }else if (isBeaconWithUUIDMajorMinor(beacon, BEACON_10_UUID, BEACON_10_MAJOR, BEACON_10_MINOR)) {
          
          iB_R[9] = beacon.rssi;
          //NSLog(@"ib10=%f",iB_R[9]);
          
          }
    }
    
    for (int i=0; i < 9; i++) {
        if (iB_R[i] == 0) {
            iB_R[i] = -100;
        }
    }
    
    /* ------------------------------------------------------------ */
    
    //訊號判斷
    if(iB_R[1] >= -99 && iB_R[3] >= -99 && iB_R[6] >= -99 && iB_R[8] >= -99) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pointLabel.text = @"計算中...";
            [self filter_method];
        });
    }
}

-(void)filter_method {
    //signal_filter[4][30] -> 過濾 -> iB_on[0,1,2,3];
    float sg_temp[4];
    float filter_temp[4][7];
    float temp;
    
    //[0]~[6]
    if (filter_count < 7) {
        signal_filter[0][filter_count] = iB_R[1];
        signal_filter[1][filter_count] = iB_R[3];
        signal_filter[2][filter_count] = iB_R[6];
        signal_filter[3][filter_count] = iB_R[8];
        filter_count++;
        self.fileTextLabel.text = [NSString stringWithFormat:@"%d",filter_count];
        
    }else{
        
        for (int i=0; i<4; i++) {
            for (int j=0; j<7; j++) {
                NSLog(@"1 s_g[%d][%d]=%f",i,j,signal_filter[i][j]);
            }
            NSLog(@"\n");
        }
        NSLog(@"\n");
        
        //訊號複製
        for (int i=6; i>0; i--) {
            signal_filter[0][i] = signal_filter[0][i-1];
            signal_filter[1][i] = signal_filter[1][i-1];
            signal_filter[2][i] = signal_filter[2][i-1];
            signal_filter[3][i] = signal_filter[3][i-1];
        }
        
        signal_filter[0][0] = iB_R[1];
        signal_filter[1][0] = iB_R[3];
        signal_filter[2][0] = iB_R[6];
        signal_filter[3][0] = iB_R[8];
        
        for (int i=0; i<4; i++) {
            for (int j=0; j<7; j++) {
                filter_temp[i][j] = signal_filter[i][j];
            }
        }
        
        for(int i=0;i<7;i++)
        {
            for(int j=0;j<7;j++)
            {
                if(filter_temp[0][i]<filter_temp[0][j])
                {
                    temp = filter_temp[0][i];
                    filter_temp[0][i] = filter_temp[0][j];
                    filter_temp[0][j] = temp;
                }
                if(filter_temp[1][i]<filter_temp[1][j])
                {
                    temp = filter_temp[1][i];
                    filter_temp[1][i] = filter_temp[1][j];
                    filter_temp[1][j] = temp;
                }
                if(filter_temp[2][i]<filter_temp[2][j])
                {
                    temp = filter_temp[2][i];
                    filter_temp[2][i] = filter_temp[2][j];
                    filter_temp[2][j] = temp;
                }
                if(filter_temp[3][i]<filter_temp[3][j])
                {
                    temp = filter_temp[3][i];
                    filter_temp[3][i] = filter_temp[3][j];
                    filter_temp[3][j] = temp;
                }
            }
        }
        
        //去頭尾
        sg_temp[0] = 0; sg_temp[1] = 0; sg_temp[2] = 0; sg_temp[3] = 0;
        for (int i=1; i<6; i++) {
            sg_temp[0] += filter_temp[0][i];
            sg_temp[1] += filter_temp[1][i];
            sg_temp[2] += filter_temp[2][i];
            sg_temp[3] += filter_temp[3][i];
        }
        sg_temp[0] = sg_temp[0]/5;
        sg_temp[1] = sg_temp[1]/5;
        sg_temp[2] = sg_temp[2]/5;
        sg_temp[3] = sg_temp[3]/5;
        
        //訊號取用
        iB_on[0] = sg_temp[0];
        iB_on[1] = sg_temp[1];
        iB_on[2] = sg_temp[2];
        iB_on[3] = sg_temp[3];
        
        [timer invalidate];
        timer = nil;
        
        
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
    
    float dis[56];
    float pt[56]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56};
    float temp;
    int i=0,j=0;

    //AVG比對
     for(j=0;j<56;j++)
     {
         temp = sqrt(pow((iB_on[0]-iB_of_AVG[0][j]),2)+pow((iB_on[1]-iB_of_AVG[1][j]),2)+pow((iB_on[2]-iB_of_AVG[2][j]),2)+pow((iB_on[3]-iB_of_AVG[3][j]),2));
         dis[j] = temp;
     }
    
    
    
    for(i=0;i<56;i++)
    {
        for(j=0;j<56;j++)
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
    k=1;
    self.KLabel.text = [NSString stringWithFormat:@"%d",k];
    //計算座標
    t1 = 0; t2 = 0;
    i=0;
    while (i<k) {
        t_temp = pt[i];
        [self func];
        i++;
    }
    final_x = t1/k;
    final_y = t2/k;
    error_data=sqrt((x-final_x)*(x-final_x)+(y-final_y)*(y-final_y));
    self.pointLabel.text = [NSString stringWithFormat:@"(%.1f,%.1f)",final_x,final_y];
    self.ErrorData.text = [NSString stringWithFormat:@"%f",error_data];
    [self WriteToFile];
    
    //調整K
    k=2;
    self.KLabel.text = [NSString stringWithFormat:@"%d",k];
    //計算座標
    t1 = 0; t2 = 0;
    i=0;
    while (i<k) {
        t_temp = pt[i];
        [self func];
        i++;
    }
    final_x = t1/k;
    final_y = t2/k;
    error_data=sqrt((x-final_x)*(x-final_x)+(y-final_y)*(y-final_y));
    self.pointLabel.text = [NSString stringWithFormat:@"(%.1f,%.1f)",final_x,final_y];
    self.ErrorData.text = [NSString stringWithFormat:@"%f",error_data];
    [self WriteToFile];
    
    //調整K
    k=3;
    self.KLabel.text = [NSString stringWithFormat:@"%d",k];
    //計算座標
    t1 = 0; t2 = 0;
    i=0;
    while (i<k) {
        t_temp = pt[i];
        [self func];
        i++;
    }
    final_x = t1/k;
    final_y = t2/k;
    error_data=sqrt((x-final_x)*(x-final_x)+(y-final_y)*(y-final_y));
    self.pointLabel.text = [NSString stringWithFormat:@"(%.1f,%.1f)",final_x,final_y];
    self.ErrorData.text = [NSString stringWithFormat:@"%f",error_data];
    [self WriteToFile];
    
    //調整K
    k=4;
    self.KLabel.text = [NSString stringWithFormat:@"%d",k];
    //計算座標
    t1 = 0; t2 = 0;
    i=0;
    while (i<k) {
        t_temp = pt[i];
        [self func];
        i++;
    }
    final_x = t1/k;
    final_y = t2/k;
    error_data=sqrt((x-final_x)*(x-final_x)+(y-final_y)*(y-final_y));
    self.pointLabel.text = [NSString stringWithFormat:@"(%.1f,%.1f)",final_x,final_y];
    self.ErrorData.text = [NSString stringWithFormat:@"%f",error_data];
    [self WriteToFile];
    
    //調整K
    k=5;
    self.KLabel.text = [NSString stringWithFormat:@"%d",k];
    //計算座標
    t1 = 0; t2 = 0;
    i=0;
    while (i<k) {
        t_temp = pt[i];
        [self func];
        i++;
    }
    final_x = t1/k;
    final_y = t2/k;
    error_data=sqrt((x-final_x)*(x-final_x)+(y-final_y)*(y-final_y));
    self.pointLabel.text = [NSString stringWithFormat:@"(%.1f,%.1f)",final_x,final_y];
    self.ErrorData.text = [NSString stringWithFormat:@"%f",error_data];
    [self WriteToFile];
    
    //調整K
    k=6;
    self.KLabel.text = [NSString stringWithFormat:@"%d",k];
    //計算座標
    t1 = 0; t2 = 0;
    i=0;
    while (i<k) {
        t_temp = pt[i];
        [self func];
        i++;
    }
    final_x = t1/k;
    final_y = t2/k;
    error_data=sqrt((x-final_x)*(x-final_x)+(y-final_y)*(y-final_y));
    self.pointLabel.text = [NSString stringWithFormat:@"(%.1f,%.1f)",final_x,final_y];
    self.ErrorData.text = [NSString stringWithFormat:@"%f",error_data];
    [self WriteToFile];
    
    //調整K
    k=7;
    self.KLabel.text = [NSString stringWithFormat:@"%d",k];
    //計算座標
    t1 = 0; t2 = 0;
    i=0;
    while (i<k) {
        t_temp = pt[i];
        [self func];
        i++;
    }
    final_x = t1/k;
    final_y = t2/k;
    error_data=sqrt((x-final_x)*(x-final_x)+(y-final_y)*(y-final_y));
    self.pointLabel.text = [NSString stringWithFormat:@"(%.1f,%.1f)",final_x,final_y];
    self.ErrorData.text = [NSString stringWithFormat:@"%f",error_data];
    [self WriteToFile];
    
    //調整K
    k=8;
    self.KLabel.text = [NSString stringWithFormat:@"%d",k];
    //計算座標
    t1 = 0; t2 = 0;
    i=0;
    while (i<k) {
        t_temp = pt[i];
        [self func];
        i++;
    }
    final_x = t1/k;
    final_y = t2/k;
    error_data=sqrt((x-final_x)*(x-final_x)+(y-final_y)*(y-final_y));
    self.pointLabel.text = [NSString stringWithFormat:@"(%.1f,%.1f)",final_x,final_y];
    self.ErrorData.text = [NSString stringWithFormat:@"%f",error_data];
    [self WriteToFile];
    
    //調整K
    k=9;
    self.KLabel.text = [NSString stringWithFormat:@"%d",k];
    //計算座標
    t1 = 0; t2 = 0;
    i=0;
    while (i<k) {
        t_temp = pt[i];
        [self func];
        i++;
    }
    final_x = t1/k;
    final_y = t2/k;
    error_data=sqrt((x-final_x)*(x-final_x)+(y-final_y)*(y-final_y));
    self.pointLabel.text = [NSString stringWithFormat:@"(%.1f,%.1f)",final_x,final_y];
    self.ErrorData.text = [NSString stringWithFormat:@"%f",error_data];
    [self WriteToFile];
    
    //調整K
    k=10;
    self.KLabel.text = [NSString stringWithFormat:@"%d",k];
    //計算座標
    t1 = 0; t2 = 0;
    i=0;
    while (i<k) {
        t_temp = pt[i];
        [self func];
        i++;
    }
    final_x = t1/k;
    final_y = t2/k;
    error_data=sqrt((x-final_x)*(x-final_x)+(y-final_y)*(y-final_y));
    self.pointLabel.text = [NSString stringWithFormat:@"(%.1f,%.1f)",final_x,final_y];
    self.ErrorData.text = [NSString stringWithFormat:@"%f",error_data];
    [self WriteToFile];
    
    
    if (action_temp < 19) {
        [self button03:self];
        action_temp ++;
    }else{
        self.pointLabel.text = [NSString stringWithFormat:@"下一個點"];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
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

- (IBAction)dirbutton:(id)sender {
    dir_count ++;
    action_temp = 0;
    filter_count = 0;
    
    self.dirTextLabel.text =[NSString stringWithFormat:@"%d",dir_count];
}

-(void)WriteToFile {
    //寫一次檔案 創檔,寫檔x1
    
    NSFileManager *fm = [NSFileManager defaultManager];
    //Create 目錄
    NSString *dir;
    dir = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/ErrorData/point_%d",dir_count];
    
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
    
    NSString *strDate = [NSString stringWithFormat:@"k, error \n"];
    data = [strDate dataUsingEncoding:NSUTF8StringEncoding];
        //寫入檔案
            if ([fm fileExistsAtPath:file])  {
                NSLog(@"檔案存在，寫入檔案");
                filedata = [NSString stringWithFormat:@"k=%d , %f\n",k,error_data];
                data = [filedata dataUsingEncoding:NSUTF8StringEncoding];
                [update seekToEndOfFile];
                [update writeData:data];
                file_count ++;
                
            }else{
                filedata = [NSString stringWithFormat:@"k=%d, %f\n",k,error_data];
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

//定位出的座標
-(void)func{
    if(t_temp == 1)
    {
        t1 += 0; t2 += 0;
    }else if(t_temp == 2){
        t1 += 0; t2 += 2;
    }else if(t_temp == 3){
        t1 += 0; t2 += 4;
    }else if(t_temp == 4){
        t1 += 0; t2 += 6;
    }else if(t_temp == 5){
        t1 += 0; t2 += 8;
    }else if(t_temp == 6){
        t1 += 0; t2 += 10;
    }else if(t_temp == 7){
        t1 += 0; t2 += 12;
    }else if(t_temp == 8){
        t1 += 0; t2 += 14;
    }else if(t_temp == 9){
        t1 += 0; t2 += 16;
    }else if(t_temp == 10){
        t1 += 0; t2 += 18;
    }else if(t_temp == 11){
        t1 += 0; t2 += 20;
    }else if(t_temp == 12){
        t1 += 0; t2 += 22;
    }else if(t_temp == 13){
        t1 += 0; t2 += 24;
    }else if(t_temp == 14){
        t1 += 0; t2 += 26;
    }else if(t_temp == 15){
        t1 += 2; t2 += 26;
    }else if(t_temp == 16){
        t1 += 2; t2 += 24;
    }else if(t_temp == 17){
        t1 += 2; t2 += 22;
    }else if(t_temp == 18){
        t1 += 2; t2 += 20;
    }else if(t_temp == 19){
        t1 += 2; t2 += 18;
    }else if(t_temp == 20){
        t1 += 2; t2 += 16;
    }else if(t_temp == 21){
        t1 += 2; t2 += 14;
    }else if(t_temp == 22){
        t1 += 2; t2 += 12;
    }else if(t_temp == 23){
        t1 += 2; t2 += 10;
    }else if(t_temp == 24){
        t1 += 2; t2 += 8;
    }else if(t_temp == 25){
        t1 += 2; t2 += 6;
    }else if(t_temp == 26){
        t1 += 2; t2 += 4;
    }else if(t_temp == 27){
        t1 += 2; t2 += 2;
    }else if(t_temp == 28){
        t1 += 2; t2 += 0;
    }else if(t_temp == 29){
        t1 += 4; t2 += 0;
    }else if(t_temp == 30){
        t1 += 4; t2 += 2;
    }else if(t_temp == 31){
        t1 += 4; t2 += 4;
    }else if(t_temp == 32){
        t1 += 4; t2 += 6;
    }else if(t_temp == 33){
        t1 += 4; t2 += 8;
    }else if(t_temp == 34){
        t1 += 4; t2 += 10;
    }else if(t_temp == 35){
        t1 += 4; t2 += 12;
    }else if(t_temp == 36){
        t1 += 4; t2 += 14;
    }else if(t_temp == 37){
        t1 += 4; t2 += 16;
    }else if(t_temp == 38){
        t1 += 4; t2 += 18;
    }else if(t_temp == 39){
        t1 += 4; t2 += 20;
    }else if(t_temp == 40){
        t1 += 4; t2 += 22;
    }else if(t_temp == 41){
        t1 += 4; t2 += 24;
    }else if(t_temp == 42){
        t1 += 4; t2 += 26;
    }else if(t_temp == 43){
        t1 += 6; t2 += 26;
    }else if(t_temp == 44){
        t1 += 6; t2 += 24;
    }else if(t_temp == 45){
        t1 += 6; t2 += 22;
    }else if(t_temp == 46){
        t1 += 6; t2 += 20;
    }else if(t_temp == 47){
        t1 += 6; t2 += 18;
    }else if(t_temp == 48){
        t1 += 6; t2 += 16;
    }else if(t_temp == 49){
        t1 += 6; t2 += 14;
    }else if(t_temp == 50){
        t1 += 6; t2 += 12;
    }else if(t_temp == 51){
        t1 += 6; t2 += 10;
    }else if(t_temp == 52){
        t1 += 6; t2 += 8;
    }else if(t_temp == 53){
        t1 += 6; t2 += 6;
    }else if(t_temp == 54){
        t1 += 6; t2 += 4;
    }else if(t_temp == 55){
        t1 += 6; t2 += 2;
    }else if(t_temp == 56){
        t1 += 6; t2 += 0;
    }
}

//自己座標
-(void)func2{
    
    x = 0; y = 0;
    
    if(point_value == 1)
    {
        x += 0; y += 0;
    }else if(point_value == 2){
        x += 0; y += 2;
    }else if(point_value == 3){
        x += 0; y += 4;
    }else if(point_value == 4){
        x += 0; y += 6;
    }else if(point_value == 5){
        x += 0; y += 8;
    }else if(point_value == 6){
        x += 0; y += 10;
    }else if(point_value == 7){
        x += 0; y += 12;
    }else if(point_value == 8){
        x += 0; y += 14;
    }else if(point_value == 9){
        x += 0; y += 16;
    }else if(point_value == 10){
        x += 0; y += 18;
    }else if(point_value == 11){
        x += 0; y += 20;
    }else if(point_value == 12){
        x += 0; y += 22;
    }else if(point_value == 13){
        x += 0; y += 24;
    }else if(point_value == 14){
        x += 0; y += 26;
    }else if(point_value == 15){
        x += 2; y += 26;
    }else if(point_value == 16){
        x += 2; y += 24;
    }else if(point_value == 17){
        x += 2; y += 22;
    }else if(point_value == 18){
        x += 2; y += 20;
    }else if(point_value == 19){
        x += 2; y += 18;
    }else if(point_value == 20){
        x += 2; y += 16;
    }else if(point_value == 21){
        x += 2; y += 14;
    }else if(point_value == 22){
        x += 2; y += 12;
    }else if(point_value == 23){
        x += 2; y += 10;
    }else if(point_value == 24){
        x += 2; y += 8;
    }else if(point_value == 25){
        x += 2; y += 6;
    }else if(point_value == 26){
        x += 2; y += 4;
    }else if(point_value == 27){
        x += 2; y += 2;
    }else if(point_value == 28){
        x += 2; y += 0;
    }else if(point_value == 29){
        x += 4; y += 0;
    }else if(point_value == 30){
        x += 4; y += 2;
    }else if(point_value == 31){
        x += 4; y += 4;
    }else if(point_value == 32){
        x += 4; y += 6;
    }else if(point_value == 33){
        x += 4; y += 8;
    }else if(point_value == 34){
        x += 4; y += 10;
    }else if(point_value == 35){
        x += 4; y += 12;
    }else if(point_value == 36){
        x += 4; y += 14;
    }else if(point_value == 37){
        x += 4; y += 16;
    }else if(point_value == 38){
        x += 4; y += 18;
    }else if(point_value == 39){
        x += 4; y += 20;
    }else if(point_value == 40){
        x += 4; y += 22;
    }else if(point_value == 41){
        x += 4; y += 24;
    }else if(point_value == 42){
        x += 4; y += 26;
    }else if(point_value == 43){
        x += 6; y += 26;
    }else if(point_value == 44){
        x += 6; y += 24;
    }else if(point_value == 45){
        x += 6; y += 22;
    }else if(point_value == 46){
        x += 6; y += 20;
    }else if(point_value == 47){
        x += 6; y += 18;
    }else if(point_value == 48){
        x += 6; y += 16;
    }else if(point_value == 49){
        x += 6; y += 14;
    }else if(point_value == 50){
        x += 6; y += 12;
    }else if(point_value == 51){
        x += 6; y += 10;
    }else if(point_value == 52){
        x += 6; y += 8;
    }else if(point_value == 53){
        x += 6; y += 6;
    }else if(point_value == 54){
        x += 6; y += 4;
    }else if(point_value == 55){
        x += 6; y += 2;
    }else if(point_value == 56){
        x += 6; y += 0;
    }
    
}

@end
