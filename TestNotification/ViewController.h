//
//  ViewController.h
//  TestNotification
//
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    NSTimer *timer;
    NSTimer *timer2;
}
@property (strong, nonatomic) IBOutlet UILabel *fileTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *ErrorData;
@property (strong, nonatomic) IBOutlet UILabel *dirTextLabel;

@property (weak, nonatomic) IBOutlet UILabel *HeadingTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;

@property (weak, nonatomic) IBOutlet UILabel *ScanStatus;
@property (weak, nonatomic) IBOutlet UIStepper *Stepper;
@property (strong, nonatomic) IBOutlet UILabel *Threshold;

- (IBAction)ChangeValue:(UIStepper *)sender;
- (IBAction)button03:(id)sender;
- (IBAction)dirbutton:(id)sender;



@end

