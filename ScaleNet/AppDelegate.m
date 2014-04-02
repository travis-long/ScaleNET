//
//  AppDelegate.m
//  ScaleNet
//
//  Created by Don Wilson on 6/12/13.
//  Copyright (c) 2013 Don Wilson. All rights reserved.
//

#import "AppDelegate.h"
#import "SetupView.h"
#import "ViewController.h"

@implementation AppDelegate



// @synthesize viewController;

struct param_struct
{
    const char* prompt;
    const char* cmdget;
    const char* cmdrcv;
    int flag;
    int min;
    int max;
    UIKeyboardType keyboardType;
    
} param[] =
{
    { "Capacity",      "\nX<CAPACITY\r",       "CAPACITY=",     SCALENET_CHK_MIN, 1,  0,  UIKeyboardTypeNumberPad},
    { "Interval",      "\nX<INTERVAL\r",       "INTERVAL=",     SCALENET_CHK_INTV, 0,  0, UIKeyboardTypeNumberPad      },
    { "Decimal",       "\nX<DECIMAL\r",        "DECIMAL=",      SCALENET_CHK_RANGE,  0,  3, UIKeyboardTypeNumberPad       },
    { "Sample Rate",    "\nX<SAMPLERATE\r",     "SAMPLERATE=",   SCALENET_CHK_RANGE,  1,  100, UIKeyboardTypeNumberPad     },
    { "Motion Range",   "\nX<MOTION\r",         "MOTION=",      SCALENET_CHK_RANGE,   1,  20, UIKeyboardTypeNumberPad      },
    { "Units",         "\nX<UNITS\r",          "UNITS=",       0, 0,  0, UIKeyboardTypeAlphabet       },
    { "Filter Mode",    "\nX<FILTERMODE\r",     "FILTERMODE=", SCALENET_CHK_RANGE,  0,  2, UIKeyboardTypeNumberPad       },
    { "Filter Break",   "\nX<FILTERBREAK\r",    "FILTERBREAK=",SCALENET_CHK_RANGE,  0,  64, UIKeyboardTypeNumberPad      },
    { "Filter Value",   "\nX<FILTERVALUE\r",    "FILTERVALUE=", SCALENET_CHK_RANGE, 0,  128, UIKeyboardTypeNumberPad     },
};


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    viewController = (ViewController*)self.window.rootViewController;
    
    sendParam = -1;
    // Override point for customization after application launch.
    
    // DW Fix for standardUseDefaults not working ???
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"addr1"]) {
        NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *settingsPropertyListPath = [mainBundlePath stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
        
        NSDictionary *settingsPropertyList = [NSDictionary dictionaryWithContentsOfFile:settingsPropertyListPath];
        NSMutableArray *preferenceArray = [settingsPropertyList objectForKey:@"PreferenceSpecifiers"];
        NSMutableDictionary *registerableDictionary = [NSMutableDictionary dictionary];
        
        for(int i = 0; i < [preferenceArray count]; i++) {
            NSString *key = [[preferenceArray objectAtIndex:i] objectForKey:@"Key"];
            
            NSLog(@"key [%@]\n", key);
            
            if(key ) {
                id value = [[ preferenceArray objectAtIndex:i] objectForKey:@"DefaultValue"];
                [registerableDictionary setObject:value forKey:key];
                
            }
        }
        [[NSUserDefaults standardUserDefaults] registerDefaults:registerableDictionary];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    // ViewController* vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    
    // [vc enterBackground];
    [self->viewController enterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self->viewController enterForeground];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(NSString*)getParamPrompt:(int)item
{
    NSString* s;
    if(item >= 0 && item < 16)
    {
        s = [[NSString alloc] initWithFormat:@"%s", param[item].prompt];
        //NSLog(@"GetAboutItem %d [%@", item, s);
    }
    else
        s = @"";
    
    return s;
}

-(const char*)getParamGetCmd:(int)item
{
    if(item >= 0 && item < SCALENET_NUM_PARAMS)
    {
        return param[item].cmdget;
    }
    else
        return NULL;
}

-(const char*)getParamRcvPrefix:(int)item
{
    if(item >= 0 && item < SCALENET_NUM_PARAMS)
    {
        return param[item].cmdrcv;
    }
    else
        return NULL;
}

- (void)clearParamInfo
{
    memset(&paramInfo, 0, sizeof(paramInfo));
}

- (void)setParamItem:(int)item buffer:(uint8_t*)buf
{
    if(item >= 0 && item < SCALENET_NUM_PARAMS)
    {
        NSLog(@"item %d prompt %s set %s", item, param[item].prompt, (char*)buf);
        
        strcpy(paramInfo[item], (char*)buf);
        
    }
    
}

-(NSString*)getParamValueString:(int)item
{
    NSString* s;
    if(item >= 0 && item < SCALENET_NUM_PARAMS)
    {
        s = [[NSString alloc] initWithFormat:@"%s", paramInfo[item]];
        //NSLog(@"GetAboutItem %d [%@", item, s);
    }
    else
        s = @"";
    
    return s;
}

-(char*)getParamValueCString:(int)item
{
    if(item >= 0 && item < SCALENET_NUM_PARAMS)
    {
        return paramInfo[item];
    }
    return "";
}

-(int)getParamFlag:(int)item
{
    if(item >= 0 && item < SCALENET_NUM_PARAMS)
    {
        return param[item].flag;
    }
    return 0;
}

- (int)getParamMin:(int)item
{
    if(item >= 0 && item < SCALENET_NUM_PARAMS)
    {
        return param[item].min;
    }
    return 0;
    
}

- (int)getParamMax:(int)item
{
    if(item >= 0 && item < SCALENET_NUM_PARAMS)
    {
        return param[item].max;
    }
    return 0;
    
}

- (UIKeyboardType)getParamKeyboardType:(int)item
{
    if(item >= 0 && item < SCALENET_NUM_PARAMS)
    {
        return param[item].keyboardType;
    }
    return UIKeyboardTypeDefault;
    
}

-(void)sendParams
{
    sendParam = 0;
}

- (int)getSendParam
{
    return sendParam;
}

- (void)nextSendParam
{
    if(sendParam == (SCALENET_NUM_PARAMS - 1))
        sendParam = -1;
    else
        sendParam++;
}


@end
