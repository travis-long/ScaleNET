//
//  ViewController.h
//  ScaleNet
//
//  Created by Don Wilson on 6/12/13.
//  Copyright (c) 2013 Don Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kIP1    @"addr1"
//#define kPort1  @"port1"

#define DSP_WIDTH_IPAD_PORTRAIT 768.0f
#define DSP_WIDTH_IPHONE_PORTRAIT 320.0f

#define DSP_WIDTH_IPAD_LANDSCAPE 1024.0f

#define DSP_WTINFO_IPAD_HEIGHT_PORTRAIT  400.0f
#define DSP_WTINFO_IPAD_HEIGHT_LANDSCAPE  400.0f

#define DSP_WTINFO_IPHONE_HEIGHT_PORTRAIT 150.0f

#define BTN_IPAD_LEFT_PORTRAIT 220.0f
#define BTN_IPAD_LEFT_LANDSCAPE 350.0f

#define SETUP_IPAD_LEFT_PORTRAIT 220.0
#define SETUP_IPAD_TOP_PORTRAIT 350.0

#define SETUP_IPAD_LEFT_LANDSCAPE 350.0
#define SETUP_IPAD_TOP_LANDSCAPE 0.0


#define WT_STATUS_IPAD_TOP 2.0f
#define WT_STATUS_IPAD_HEIGHT 70.0f
#define WT_STATUS_IPAD_FONT_SIZE 70

#define WT_STATUS_IPHONE_TOP 2.0f
#define WT_STATUS_IPHONE_HEIGHT 29.0f
#define WT_STATUS_IPHONE_FONT_SIZE 29

#define WT_VALUE_IPAD_TOP 72.0f
#define WT_VALUE_IPAD_HEIGHT 140.0f
#define WT_VALUE_IPAD_FONT_SIZE 130

#define WT_VALUE_IPHONE_TOP 31.0f
#define WT_VALUE_IPHONE_HEIGHT 60.0f
#define WT_VALUE_IPHONE_FONT_SIZE 55

#define MILLIVOLT_IPAD_TOP 280.0f
#define MILLIVOLT_IPAD_HEIGHT 60.0f
#define MILLIVOLT_IPAD_FONT_SIZE 60

#define MILLIVOLT_IPHONE_TOP 100.0f
#define MILLIVOLT_IPHONE_HEIGHT 24.0f;
#define MILLIVOLT_IPHONE_FONT_SIZE 24

#define ABOUT_INFO_IPAD_TOP 360.0
#define ABOUT_INFO_IPAD_HEIGHT 16.0f
#define ABOUT_INFO_IPAD_FONT_SIZE 14

#define ABOUT_INFO_IPHONE_TOP 130.0;
#define ABOUT_INFO_IPHONE_HEIGHT 16.0f;
#define ABOUT_INFO_IPHONE_FONT_SIZE 14

#define MSG_IPAD_HEIGHT 26.0f
#define MSG_IPAD_FONT_SIZE 26

#define MSG_IPHONE_HEIGHT 26.0f
#define MSG_IPHONE_FONT_SIZE 26


#define BTN_IPAD_TOP 500.0f
#define BTN_IPAD_WIDTH 320.0f
#define BTN_IPAD_HEIGHT 42.0f
#define BTN_IPAD_FONT_SIZE 14
#define BTN_IPAD_MARGIN 4.0f

#define BTN_IPHONE_LEFT 0.0f
#define BTN_IPHONE_TOP 240.0f
#define BTN_IPHONE_WIDTH 320.0f
#define BTN_IPHONE_HEIGHT 42.0f
#define BTN_IPHONE_FONT_SIZE 14
#define BTN_IPHONE_MARGIN 4.0f

#define STATUS_IPAD_HEIGHT 21.0f
#define STATUS_IPHONE_HEIGHT 21.0f

@interface ViewController : UIViewController <NSStreamDelegate, UIAlertViewDelegate, UITextFieldDelegate, SetupViewDelegate>
{
    UILabel *lblStatus;
    UILabel *lblMessage;
    
    UIView *dsp;
    
    UILabel *lblScaleWt;
    UILabel *lblWtStatus;
    
  //  UILabel *lblUnits;
    
    //UITextField *textFieldID;
   // UITextField* textIPAddress;
   // UITextField* textCalWeight;
    
  //  UILabel *lblID;
    UILabel *lblMillivolts;
    
    UILabel *lblAbout[5];
    
    UIAlertView* alertEnterIP;
    UIAlertView* alertCalWeight;
    UIAlertView* alertCalUnload;
    UIAlertView* alertPromptForQuickCal;
    UIAlertView* alertCellCapacity;
    UIAlertView* alertCellUnits;
    UIAlertView* alertOpUnits;
    UIAlertView* alertMvPerV;
    UIAlertView* alertCellCount;
    
    double cell_capacity;
    NSString* cell_units;
    NSString* op_units;
    double cell_mv_per_v;
    NSInteger cell_count;
    
    NSString* ip;
    int nPort;
    
    NSTimeInterval _tsBackground;
    
    bool _enteredBackgroundWhileConnected;
    
    UIButton* btn[4];
    //    MyBtnImageView* imgBtn[10];
    
    //enum PossibleWtUnits { unitsLb, unitsKg };
    
    //enum PossibleWtUnits curWtUnits;
    
    int nAboutTimeout;
    int nAboutRcvd;
    int nParamRcvd;
    
    int nJustSentParam;
    
    SetupView* setupView;
    
    int nCalibrationInProgress;
    
    int nMessageClearCnt;
    
}

//@property (retain, nonatomic) IBOutlet UISwitch *connectSwitch;
//@property (retain, nonatomic) IBOutlet UILabel *lblStatus;
// @property (retain, nonatomic) IBOutlet UILabel *lblScaleWt;

- (void)timerFires;
- (void) timerBtnFlash:(NSTimer*)timer;

- (void)disconnect;

- (void)enterBackground;
- (void)enterForeground;

- (void)doBtn:(id)sender;

- (void)finishSetup:(int)accept;
- (void)notConnectedMsg:(NSString*)msg;


@end
