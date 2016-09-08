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
static int k;

static float iB_R[10];  //beacon數量

//distance
static float iB_on[4];  //distance online data
static float x,y,t1,t2,t_temp,error_data; //座標累加
static float final_x,final_y;
static float point_value =0;


//filter
static int action_temp = 0;
static int filter_count = 0;
static float signal_filter[4][7];

static float iB_of_AVG[4][24]={
    {-69.56896552,-71.43103448,-73.31896552,-74.23275862,-73.3362069,-76.27586207,-75.05172414,-76.27586207,-73.79310345,-72.92241379,-71.37931034,-68.94827586,-69.17241379,-70.93103448,-74.23860837,-74.93965517,-75.61206897,-75.95689655,-77.90517241,-77.89655172,-76.82758621,-74.63793103,-72.56034483,-71.02586207},
    {-83.5862069,-83.61761084,-85.52586207,-84.74137931,-84.70689655,-84.6385468,-85.68226601,-81.75862069,-83.87068966,-81.32758621,-82.43103448,-85.25,-82.94827586,-79.99137931,-80.09482759,-83.04125616,-79.89655172,-82.1976601,-82.71551724,-78.90517241,-83.23275862,-79.99137931,-83.28448276,-83.68103448},
    {-73.19304187,-76.09482759,-73.49137931,-72.98275862,-72.73275862,-68.55172414,-69.39655172,-71.37068966,-74.13793103,-74.04310345,-76.01754926,-78.79310345,-76.47413793,-74.90517241,-72.8362069,-70.46679438,-72.07758621,-67.50862069,-71.54310345,-71.12931034,-73.26724138,-75.72413793,-76.92241379,-76.51724138},
    {-85.62068966,-83.65517241,-78.6637931,-81.37007389,-79.78448276,-80.28448276,-80.62068966,-82.99137931,-82.8362069,-82.8362069,-82.47413793,-84.77586207,-85.25862069,-82.95289409,-81.25246305,-83.32758621,-83.09482759,-83.61526181,-84.42560664,-85.21551724,-88.03448276,-85.00319285,-84.78448276,-83.31896552}
};//Offline AVERAGE 0509-off-data alldif


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


//均值濾波
-(void)filter_method {
    //signal_filter[4][30] -> 過濾 -> iB_on[0,1,2,3];
    float sg_temp[4];
    float temp;
    
    //[0]~[6]
    if (filter_count < 7) {
        signal_filter[0][filter_count] = iB_R[1];
        signal_filter[1][filter_count] = iB_R[3];
        signal_filter[2][filter_count] = iB_R[6];
        signal_filter[3][filter_count] = iB_R[8];
        filter_count++;
        self.fileTextLabel.text = [NSString stringWithFormat:@"%d",filter_count];
        
        //NSLog(@"ibr[1]%f",iB_R[1]);
        
        
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
    
        
        //加總平均
        sg_temp[0] = 0; sg_temp[1] = 0; sg_temp[2] = 0; sg_temp[3] = 0;
        for (int i=0; i<7; i++) {
            sg_temp[0] += signal_filter[0][i];
            sg_temp[1] += signal_filter[1][i];
            sg_temp[2] += signal_filter[2][i];
            sg_temp[3] += signal_filter[3][i];
        }
        sg_temp[0] = sg_temp[0]/7;
        sg_temp[1] = sg_temp[1]/7;
        sg_temp[2] = sg_temp[2]/7;
        sg_temp[3] = sg_temp[3]/7;
        
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

//均值濾波
-(void)distance_matching{
    
    float dis[24];
    float pt[24]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24};
    float temp;
    int i=0,j=0;

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
    
    
    
    if (action_temp < 19) {
        [self button03:self];
        action_temp ++;
    }else{
        self.pointLabel.text = [NSString stringWithFormat:@"下一個點"];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

//均值濾波
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
                filedata = [NSString stringWithFormat:@"k=%d , %f\n",k,error_data];
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
