//
//  AppDelegate.h
//  ScaleNet
//
//  Created by Don Wilson on 6/12/13.
//  Copyright (c) 2013 Don Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

static const int SCALENET_NUM_PARAMS = 9;

static const int SCALENET_CHK_RANGE = 1;
static const int SCALENET_CHK_MIN = 2;
static const int SCALENET_CHK_INTV = 3;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    int sendParam;
    
    char paramInfo[SCALENET_NUM_PARAMS][24];

    ViewController* viewController;
}

// @property (nonatomic, retain) IBOutlet ViewController *viewController;

@property (strong, nonatomic) UIWindow *window;
//-(void)setSetupView:(SecondViewController*)setupController;
//-(SecondViewController*)getSetupView;

-(NSString*)getParamPrompt:(int)item;
-(const char*)getParamGetCmd:(int)item;
-(const char*)getParamRcvPrefix:(int)item;

-(void)clearParamInfo;
- (void)setParamItem:(int)item buffer:(uint8_t*)buf;
-(NSString*)getParamValueString:(int)item;
-(char*)getParamValueCString:(int)item;

-(int)getParamFlag:(int)item;
- (int)getParamMin:(int)item;
- (int)getParamMax:(int)item;
- (UIKeyboardType)getParamKeyboardType:(int)item;
- (void)sendParams;
- (int)getSendParam;
- (void)nextSendParam;

@end
