//
//  ViewController.m
//  ScaleNet
//
//  Created by Don Wilson on 6/12/13.
//  Copyright (c) 2013 Don Wilson. All rights reserved.
//

#import "SetupView.h"

#import "ViewController.h"

#import "AppDelegate.h"

#import "NSStreamAdditions.h"

NSInputStream *iStream;
NSOutputStream *oStream;

NSMutableData *data;

uint8_t inpbuf[128];
int inppos = 0;
int inpmode = 0;

int connTimeout = 0;
int readTimeout = 0;

NSTimer* timer;
NSTimer* timerBtnFlash;

enum ConnectionState { notConnected, connecting, connected };

enum ConnectionState connState = notConnected;


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"FirstViewController viewDidLoad");
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [self.view setUserInteractionEnabled:YES];
    
    setupView = nil;
    
    nCalibrationInProgress = 0;
   
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ip = [[NSString alloc] initWithString:[defaults objectForKey:kIP1]];
   
    
    CGFloat dspWidth;
    CGFloat dspWtInfoHeight;
    
    CGFloat wtStatusTop, wtStatusHeight, wtStatusFontSize;
    
    CGFloat wtValueTop, wtValueHeight, wtValueFontSize;
    CGFloat millivoltTop, millivoltHeight, millivoltFontSize;
    
    CGFloat aboutInfoTop, aboutInfoHeight, aboutInfoFontSize;
    
    CGFloat msgHeight, msgFontSize;
    
    CGFloat btnLeft, btnTop, btnWidth, btnHeight, btnFontSize, btnMargin;
    
    CGFloat statusHeight;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        dspWidth = DSP_WIDTH_IPAD_PORTRAIT;
    
        dspWtInfoHeight = DSP_WTINFO_IPAD_HEIGHT_PORTRAIT;
        btnLeft = BTN_IPAD_LEFT_PORTRAIT;
        
        wtStatusTop = WT_STATUS_IPAD_TOP;
        wtStatusHeight = WT_STATUS_IPAD_HEIGHT;
        wtStatusFontSize = WT_STATUS_IPAD_FONT_SIZE;
        
        wtValueTop = WT_VALUE_IPAD_TOP;
        wtValueHeight = WT_VALUE_IPAD_HEIGHT;
        wtValueFontSize = WT_VALUE_IPAD_FONT_SIZE;
        
        millivoltTop =  MILLIVOLT_IPAD_TOP;
        millivoltHeight = MILLIVOLT_IPAD_HEIGHT;
        millivoltFontSize = MILLIVOLT_IPAD_FONT_SIZE;
        
        aboutInfoTop = ABOUT_INFO_IPAD_TOP;
        aboutInfoHeight = ABOUT_INFO_IPAD_HEIGHT;
        aboutInfoFontSize = ABOUT_INFO_IPAD_FONT_SIZE;
        
        msgHeight = MSG_IPAD_HEIGHT;
        msgFontSize = MSG_IPAD_FONT_SIZE;
        
         
        btnTop = BTN_IPAD_TOP;
        btnWidth = BTN_IPAD_WIDTH;
        btnHeight = BTN_IPAD_HEIGHT;
        btnFontSize = BTN_IPAD_FONT_SIZE;
        btnMargin = BTN_IPAD_MARGIN;
        
        statusHeight = STATUS_IPAD_HEIGHT;
    }
    else
    {
        dspWidth = DSP_WIDTH_IPHONE_PORTRAIT;
        dspWtInfoHeight = DSP_WTINFO_IPHONE_HEIGHT_PORTRAIT;
       
        wtStatusTop = WT_STATUS_IPHONE_TOP;
        wtStatusHeight = WT_STATUS_IPHONE_HEIGHT;
        wtStatusFontSize = WT_STATUS_IPHONE_FONT_SIZE;

        wtValueTop = WT_VALUE_IPHONE_TOP;
        wtValueHeight = WT_VALUE_IPHONE_HEIGHT;
        wtValueFontSize = WT_VALUE_IPHONE_FONT_SIZE;
        
        millivoltTop =  MILLIVOLT_IPHONE_TOP;
        millivoltHeight = MILLIVOLT_IPHONE_HEIGHT;
        millivoltFontSize = MILLIVOLT_IPHONE_FONT_SIZE;
        
        aboutInfoTop = ABOUT_INFO_IPHONE_TOP;
        aboutInfoHeight = ABOUT_INFO_IPHONE_HEIGHT;
        aboutInfoFontSize = ABOUT_INFO_IPHONE_FONT_SIZE;
 
        msgHeight = MSG_IPHONE_HEIGHT;
        msgFontSize = MSG_IPHONE_FONT_SIZE;

        btnLeft = BTN_IPHONE_LEFT;
        btnTop = BTN_IPHONE_TOP;
        btnWidth = BTN_IPHONE_WIDTH;
        btnHeight = BTN_IPHONE_HEIGHT;
        btnFontSize = BTN_IPHONE_FONT_SIZE;
        btnMargin = BTN_IPHONE_MARGIN;

        statusHeight = STATUS_IPHONE_HEIGHT;
   }
    
        
        dsp = [[UIView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, dspWidth, dspWtInfoHeight)];
        dsp.backgroundColor = [UIColor blackColor];
        [self.view addSubview:dsp];
        
        lblWtStatus = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, wtStatusTop, dspWidth, wtStatusHeight)];
        lblWtStatus.font = [UIFont fontWithName:@"Helvetica-Bold" size:wtStatusFontSize];
        [lblWtStatus setBackgroundColor:[UIColor clearColor]];
        [lblWtStatus setTextColor:[UIColor greenColor]];
        //[lblWtStatus setText:@"Wt Status"];
        [lblWtStatus setTextAlignment:NSTextAlignmentCenter];
        [dsp addSubview:lblWtStatus];
        
        lblScaleWt = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, wtValueTop, dspWidth, wtValueHeight)];
        [lblScaleWt setFont:[UIFont fontWithName:@"Arial-BoldMT" size:wtValueFontSize]];
        [lblScaleWt setBackgroundColor:[UIColor clearColor]];
        
        [lblScaleWt setTextColor:[UIColor greenColor]];
        
        [lblScaleWt setText:@"8888.88 lb"];
        [lblScaleWt setTextAlignment:NSTextAlignmentCenter];
        [dsp addSubview:lblScaleWt];
        
        
        lblMillivolts = [[UILabel alloc] initWithFrame: CGRectMake(0.0f, millivoltTop, dspWidth, millivoltHeight)];
        lblMillivolts.backgroundColor = [UIColor clearColor];
        lblMillivolts.textColor = [UIColor greenColor];
        [lblMillivolts setFont:[UIFont fontWithName:@"Arial-BoldMT" size:millivoltFontSize]];
        [lblMillivolts setTextAlignment:NSTextAlignmentCenter];
        lblMillivolts.text = @"88.888 mV";
        
        [dsp addSubview:lblMillivolts];
        
        NSString* lblBtn[] = { @"Zero Scale", @"Scale Parameters", @"Calibrate Scale", @"Connect To ScaleNET" };
        
        CGFloat y = aboutInfoTop;
        int n;
        
        for(n = 0; n < 5; n++)
        {
            lblAbout[n] = [[UILabel alloc] initWithFrame:CGRectMake(00.0f, y, dspWidth, aboutInfoHeight)];
            //[lblStatus setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
            [lblAbout[n] setBackgroundColor:[UIColor clearColor]];
            [lblAbout[n] setTextColor:[UIColor whiteColor]];
            //[lblAbout[n] setText:@"About"];
            [lblAbout[n] setFont:[UIFont fontWithName:@"Arial" size:aboutInfoFontSize]];
            [lblAbout[n] setTextAlignment:NSTextAlignmentLeft];
            [self.view addSubview:lblAbout[n]];
            y += aboutInfoHeight;
        }
        
        lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, dspWidth, msgHeight)];
        [lblMessage setFont:[UIFont fontWithName:@"Helvetica-Bold" size:msgFontSize]];
        [lblMessage setBackgroundColor:[UIColor clearColor]];
        [lblMessage setTextColor:[UIColor redColor]];
        // [lblStatus setText:@"Status"];
        [lblMessage setTextAlignment:NSTextAlignmentLeft];
        [self.view addSubview:lblMessage];
        
        y = btnTop;
        
        for(n = 0; n < 4; n++)
        {
            
            btn[n] = [UIButton buttonWithType:UIButtonTypeCustom];
            btn[n].frame = CGRectMake(btnLeft, y, btnWidth, btnHeight);
            [btn[n] setUserInteractionEnabled:YES];
            [btn[n] addTarget:self action:@selector(doBtn:) forControlEvents:UIControlEventTouchDown];
            [btn[n] setBackgroundColor:[UIColor whiteColor]];
            
            [btn[n] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            [btn[n].titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:btnFontSize]];
            [btn[n] setTitle:lblBtn[n] forState:UIControlStateNormal];
            [self.view addSubview:btn[n]];
            
            y += btnHeight + btnMargin;
            
            
        }
        
        lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, dspWidth, statusHeight)];
        //[lblStatus setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        [lblStatus setBackgroundColor:[UIColor clearColor]];
        [lblStatus setTextColor:[UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0]];
        [lblStatus setText:@"Not connected"];
        [lblStatus setTextAlignment:NSTextAlignmentLeft];
        [self.view addSubview:lblStatus];
      
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"willAnimateRotation...\n");
    
    CGFloat dspWidth;
    CGFloat dspWtInfoHeight;
    
    CGFloat wtStatusTop, wtStatusHeight, wtStatusFontSize;
    
    CGFloat wtValueTop, wtValueHeight, wtValueFontSize;
    CGFloat millivoltTop, millivoltHeight, millivoltFontSize;
    
    CGFloat aboutInfoTop, aboutInfoHeight, aboutInfoFontSize;
    
    CGFloat msgHeight, msgFontSize;
    
    CGFloat btnLeft, btnTop, btnWidth, btnHeight, btnFontSize, btnMargin;
    
    CGFloat statusHeight;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if(toInterfaceOrientation == UIInterfaceOrientationPortrait ||
           toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            dspWidth = DSP_WIDTH_IPAD_PORTRAIT;
        
            dspWtInfoHeight = DSP_WTINFO_IPAD_HEIGHT_PORTRAIT;

            btnLeft = BTN_IPAD_LEFT_PORTRAIT;

        }
        else
        {
            dspWidth = DSP_WIDTH_IPAD_LANDSCAPE;
            
            dspWtInfoHeight = DSP_WTINFO_IPAD_HEIGHT_LANDSCAPE;
            btnLeft = BTN_IPAD_LEFT_LANDSCAPE;
       }
        
        wtStatusTop = WT_STATUS_IPAD_TOP;
        wtStatusHeight = WT_STATUS_IPAD_HEIGHT;
        wtStatusFontSize = WT_STATUS_IPAD_FONT_SIZE;
        
        wtValueTop = WT_VALUE_IPAD_TOP;
        wtValueHeight = WT_VALUE_IPAD_HEIGHT;
        wtValueFontSize = WT_VALUE_IPAD_FONT_SIZE;
        
        millivoltTop =  MILLIVOLT_IPAD_TOP;
        millivoltHeight = MILLIVOLT_IPAD_HEIGHT;
        millivoltFontSize = MILLIVOLT_IPAD_FONT_SIZE;
        
        aboutInfoTop = ABOUT_INFO_IPAD_TOP;
        aboutInfoHeight = ABOUT_INFO_IPAD_HEIGHT;
        aboutInfoFontSize = ABOUT_INFO_IPAD_FONT_SIZE;
        
        msgHeight = MSG_IPAD_HEIGHT;
        msgFontSize = MSG_IPAD_FONT_SIZE;
        
        btnTop = BTN_IPAD_TOP;
        btnWidth = BTN_IPAD_WIDTH;
        btnHeight = BTN_IPAD_HEIGHT;
        btnFontSize = BTN_IPAD_FONT_SIZE;
        btnMargin = BTN_IPAD_MARGIN;
        
        statusHeight = STATUS_IPAD_HEIGHT;
    }
    else
    {
        dspWidth = DSP_WIDTH_IPHONE_PORTRAIT;
        dspWtInfoHeight = DSP_WTINFO_IPHONE_HEIGHT_PORTRAIT;
        
        wtStatusTop = WT_STATUS_IPHONE_TOP;
        wtStatusHeight = WT_STATUS_IPHONE_HEIGHT;
        wtStatusFontSize = WT_STATUS_IPHONE_FONT_SIZE;
        
        wtValueTop = WT_VALUE_IPHONE_TOP;
        wtValueHeight = WT_VALUE_IPHONE_HEIGHT;
        wtValueFontSize = WT_VALUE_IPHONE_FONT_SIZE;
        
        millivoltTop =  MILLIVOLT_IPHONE_TOP;
        millivoltHeight = MILLIVOLT_IPHONE_HEIGHT;
        millivoltFontSize = MILLIVOLT_IPHONE_FONT_SIZE;
        
        aboutInfoTop = ABOUT_INFO_IPHONE_TOP;
        aboutInfoHeight = ABOUT_INFO_IPHONE_HEIGHT;
        aboutInfoFontSize = ABOUT_INFO_IPHONE_FONT_SIZE;
        
        msgHeight = MSG_IPHONE_HEIGHT;
        msgFontSize = MSG_IPHONE_FONT_SIZE;
        
        btnLeft = BTN_IPHONE_LEFT;
        btnTop = BTN_IPHONE_TOP;
        btnWidth = BTN_IPHONE_WIDTH;
        btnHeight = BTN_IPHONE_HEIGHT;
        btnFontSize = BTN_IPHONE_FONT_SIZE;
        btnMargin = BTN_IPHONE_MARGIN;
        
        statusHeight = STATUS_IPHONE_HEIGHT;
    }

    CGRect frame = CGRectMake(0, 0, dspWidth, dspWtInfoHeight);

    [UIView animateWithDuration:duration animations:^{ dsp.frame = frame; }];

    CGRect wtframe = CGRectMake(0, wtValueTop, dspWidth, wtValueHeight);
    [UIView animateWithDuration:duration animations:^{ lblScaleWt.frame = wtframe; }];

    frame = CGRectMake(0, wtStatusTop, dspWidth, wtStatusHeight);
    [UIView animateWithDuration:duration animations:^{ lblWtStatus.frame = frame; }];

    frame = CGRectMake(0, millivoltTop, dspWidth, millivoltHeight);
    [UIView animateWithDuration:duration animations:^{ lblMillivolts.frame = frame; }];

    int n;
    CGFloat y;
    
    y = btnTop;
    
    for(n = 0; n < 4; n++)
    {
        
        frame = CGRectMake(btnLeft, y, btnWidth, btnHeight);
        [UIView animateWithDuration:duration animations:^{ btn[n].frame = frame; }];
       
        y += btnHeight + btnMargin;
      
        
    }
    
    if(setupView != nil)
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if(toInterfaceOrientation == UIInterfaceOrientationPortrait ||
               toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
            {
                frame = CGRectMake(SETUP_IPAD_LEFT_PORTRAIT, SETUP_IPAD_TOP_PORTRAIT, 320.0, 400.0);
            }
            else
            {
                frame = CGRectMake(SETUP_IPAD_LEFT_LANDSCAPE, SETUP_IPAD_TOP_LANDSCAPE, 320.0, 400.0);
                
            }
            [UIView animateWithDuration:duration animations:^{ setupView.frame = frame; }];
        }
        
    }
    
   // lblScaleWt.text = @"88888";
    
//    [UIView animateWithDuration:duration animations:^{ keypad.frame = keypadFrame; }];
    
 
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
   //  NSLog(@"should");
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
 
        return YES;
    }
    else
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}


- (NSUInteger)supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)notConnectedMsg:(NSString*)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Not Connected"
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)doBtn:(id)sender
{
    const uint8_t* buf = NULL;
    
    // NSLog(@"button %@", event);
  
           NSLog(@"begin");
            [sender setBackgroundColor:[UIColor blueColor]];
            timerBtnFlash = [NSTimer scheduledTimerWithTimeInterval:0.3
                                             target:self
                                            selector:@selector(timerBtnFlash:)
                                           userInfo:sender
                                            repeats:YES];
    
            if(sender == btn[0])
            {
                NSLog(@"Zero");
                if(connState != connected)
                {
                    [self notConnectedMsg:@"Cannot zero while not connected"];
                }
                else
                {
                    if(connState == connected)
                    {
                        buf = (const uint8_t*)"\nZ\r";
              
                        [oStream write:buf maxLength:strlen((char*)buf)];
                        [lblMessage setText:@"Zero command sent"];
                        [lblMessage setTextColor:[UIColor blueColor]];
                        nMessageClearCnt = 10;
                
                    }
                }
            }
            else if(sender == btn[1])
            {
                NSLog(@"Setup");
                if(connState != connected)
                {
                    [self notConnectedMsg:@"Cannot review or change scale parameters while not connected"];
                }
                else
                {
                    CGRect frame;
                    
                    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    {
                        // setupView = [[SetupView alloc] initWithFrame:CGRectMake(220.0, 350.0, 320.0, 400.0)];
                        
                        if(UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
                        {
                             frame = CGRectMake(SETUP_IPAD_LEFT_PORTRAIT, SETUP_IPAD_TOP_PORTRAIT, 320.0, 400.0);
                        }
                        else
                        {
                             frame = CGRectMake(SETUP_IPAD_LEFT_LANDSCAPE, SETUP_IPAD_TOP_LANDSCAPE, 320.0, 400.0);
            
                        }
                        
                    }
                    else
                    {
                        // setupView = [[SetupView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 600.0)];
                        frame = CGRectMake(0.0, 0.0, 320.0, 600.0);
                
                    }
                    
                    int n;
                    for(n = 0; n < 4; n++)
                    {
                        [btn[n] setHidden:YES];
                    }
                    setupView = [[SetupView alloc] initWithFrame:frame];
                    setupView.delegate = self;
                    
                    [self.view addSubview:setupView];
               }
            }
            else if(sender == btn[2])
            {
                if(connState != connected)
                {
                    [self notConnectedMsg:@"Cannot calibrate while not connected"];
                }
                else
                {
                    alertCalWeight = [[UIAlertView alloc] initWithTitle:@"Calibration Weight" message:@"Place weight on scale before proceeding" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                    //UITextField *textField;
            //textCalWeight = [[UITextField alloc] init];
            //[textCalWeight setBackgroundColor:[UIColor whiteColor]];
            //textCalWeight.delegate = self;
            //textCalWeight.borderStyle = UITextBorderStyleLine;
            //textCalWeight.frame = CGRectMake(15, 95, 255, 30);
            //textCalWeight.font = [UIFont fontWithName:@"ArialMT" size:20];
            //textCalWeight.placeholder = @"Enter the weight";
            // textIPAddress.text = @"10.1.3.105";
            //textCalWeight.textAlignment = UITextAlignmentCenter;
            //textCalWeight.keyboardAppearance = UIKeyboardAppearanceAlert;
            //textCalWeight.keyboardType = UIKeyboardTypeDecimalPad;
            //[textCalWeight becomeFirstResponder];
            //[alertCalWeight addSubview:textCalWeight];
        
                    [alertCalWeight setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [alertCalWeight textFieldAtIndex:0].placeholder = @"Enter the weight";
                    [alertCalWeight textFieldAtIndex:0].keyboardType = UIKeyboardTypeDecimalPad;
            
                    [alertCalWeight show];
                }
        
            }
            else if(sender == btn[3])
            {
                if(connState == connected)
                {
                    [self disconnect];
                }
        
                alertEnterIP = [[UIAlertView alloc] initWithTitle:@"Enter IP Address" message:@"" /*@"\n\n"*/ delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            //UITextField *textField;
            //textIPAddress = [[UITextField alloc] init];
            //[textIPAddress setBackgroundColor:[UIColor whiteColor]];
            //textIPAddress.delegate = self;
            //textIPAddress.borderStyle = UITextBorderStyleLine;
            //textIPAddress.frame = CGRectMake(15, 60, 255, 30);
            //textIPAddress.font = [UIFont fontWithName:@"ArialMT" size:20];
            //// .placeholder = @"Enter the weight";
            //textIPAddress.text = ip; // @"10.1.3.105";
            //textIPAddress.textAlignment = UITextAlignmentCenter;
            //textIPAddress.keyboardAppearance = UIKeyboardAppearanceAlert;
            //textIPAddress.keyboardType = UIKeyboardTypeDecimalPad;
            //[textIPAddress becomeFirstResponder];
            //[alertEnterIP addSubview:textIPAddress];
        
                [alertEnterIP setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [alertEnterIP textFieldAtIndex:0].text = ip;
                [alertEnterIP textFieldAtIndex:0].keyboardType = UIKeyboardTypeDecimalPad;
        
                [alertEnterIP show];
            }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // NSString* detailString = textFieldID.text;
    // detailString = [detailString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // NSLog(@"String is: %@", detailString);
    if (/*[textFieldID.text length] <= 0 ||*/ buttonIndex == 0){
        
        if(alertView == alertCalUnload)
        {
            lblMessage.text = @"CANCELLED";
            nMessageClearCnt = 10;
            nCalibrationInProgress = 0;
        }
        
        return; //If cancel or 0 length string the string doesn't matter
    }
    if (buttonIndex == 1) {
        NSLog(@"buttonindex == 1");
        
        if(alertView == alertEnterIP)
        {
            if([/*textIPAddress.text*/ [alertView textFieldAtIndex:0].text isEqualToString:ip] == false)
            {
                ip = [alertView textFieldAtIndex:0].text; // textIPAddress.text;
                NSLog(@"IP changed %@", ip);
                
                // Save to preferences
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:ip forKey:kIP1];
                [defaults synchronize];

            }
        
            [self connect];
        }
        else if(alertView == alertCalWeight)
        {
            NSLog(@"Cal weight %@", [alertView textFieldAtIndex:0].text);
            
            int wt = atoi([[alertView textFieldAtIndex:0].text UTF8String]); // atoi([textCalWeight.text UTF8String]);
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if(wt == 0 || wt > atoi([appDelegate getParamValueCString:0]))
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Weight"
                                                                message:@"Calibration weight must be greater than zero and less than  or equal to scale capacity"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                [alert show];
            
                nCalibrationInProgress = 0;
            }
            else
            {
                nCalibrationInProgress = 1;
                const uint8_t buf[20];
                if(connState == connected)
                {
                    sprintf((char*)buf, "\nXL%d\r", wt);
                
                    [oStream write:buf maxLength:strlen((char*)buf)];
                }
            }
        }
        else if(alertView == alertCalUnload)
        {
            nCalibrationInProgress = 5;
            
            const uint8_t* buf = (uint8_t*)"\nXU\r";
            if(connState == connected)
            {
                
                [oStream write:buf maxLength:strlen((char*)buf)];
            }
         
        }
        
    }
}



- (void)disconnect
{
    
    [timer invalidate];
    timer = nil;
    
    NSLog(@"disconnect");
    
    if(connState != notConnected)
    {
        // connected = false;
        connState = notConnected;
        
        [iStream close];
        [oStream close];
        //  [iStream release];
        //  [oStream release];
        
    }
    lblScaleWt.text = @"";
    lblMillivolts.text = @"";
    lblWtStatus.text = @"";
 //   lblUnits.text = @"";
    int n;
    for(n = 0; n < 5; n++)
    {
        lblAbout[n].text = @"";
    }
    
    // NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // ip = [[NSString alloc] initWithString:[defaults objectForKey:kIP1]];
    // nPort = [[defaults objectForKey:kPort1] intValue];
    
    // NSString* msg = [[NSString alloc] initWithFormat:@"%@:%d", ip, nPort];
    // lblStatus.text = msg;
    lblStatus.text = @"Not connected";
   //[msg release];
    
    
    
    
}


- (void)connect
{
    //  const uint8_t* buf;
    
    NSLog(@"connect\n");
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(connState == notConnected)
    {
        //ip = [[NSString alloc] initWithString:[defaults objectForKey:kIP1]];
        //nPort = [[defaults objectForKey:kPort1] intValue];
        nPort = 10001;
        
        nMessageClearCnt = 0;
        
        NSLog(@"connecting %@ to %d \n", ip, nPort);
        // Create socket.
        if(nPort != 0 && ip != nil)
        {
            
            NSString* msg = [[NSString alloc] initWithFormat:@"Connecting to %@:%d", ip, nPort];
            lblStatus.text = msg;
            //[msg release];
            
            lblScaleWt.text = @"";
            //lblUnits.text = @"";
            lblMillivolts.text = @"";
            
            [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
            
            
            NSInputStream *lociStream;
            NSOutputStream *locoStream;
            
            [NSStream getStreamsToHostNamed:ip
                                       port:nPort
                                inputStream:&lociStream
                               outputStream:&locoStream];
            iStream = lociStream;
            oStream = locoStream;
            
            //[iStream retain];
            //[oStream retain];
            
            [iStream setDelegate:self];
            [oStream setDelegate:self];
            
            [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
            [oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
            
            [oStream open];
            [iStream open];
            
            nAboutRcvd = -4;
            nAboutTimeout = 0;
   
            nParamRcvd = 0;
            
            
            connState = connecting;
            
            timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                     target:self
                                                   selector:@selector(timerFires)
                                                   userInfo:nil
                                                    repeats:YES];
            //[timer fire];
            
            
            
            connTimeout = 0;
            readTimeout = 0;
            
            
            // Request about info
            // buf = (const uint8_t*)"\nA\r";
            // [oStream write:buf maxLength:strlen((char*)buf)];
            
        }
    }
    
}

- (void)enterBackground
{
    if(connState != notConnected)
    {
        _enteredBackgroundWhileConnected = true;
        
        _tsBackground = [[NSProcessInfo processInfo] systemUptime];
        [self disconnect];
    }
    else{
        _enteredBackgroundWhileConnected = false;
    }
    
}

- (void)enterForeground
{
    NSLog(@"enterForeground");
    
    if(_enteredBackgroundWhileConnected == true)
    {
        // TODO if less than an hour since it was connected reconnect
        NSTimeInterval system = [[NSProcessInfo processInfo] systemUptime];
        
        if(system - _tsBackground < 7200)
        {
            NSLog(@"enterForeground Connect");
            [self connect];
        }
    }
    
}

- (void) timerFires
{
    char sendcmd[80];
    const uint8_t* buf = NULL;
    static int cnt = 0;
    
    if(connState == connected)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if(nAboutRcvd < 100)
        {
            if(nAboutRcvd < -1) // Do a few weight requests before about to give us quicker weight display when first connected
            {
                nAboutRcvd++;
                buf = (const uint8_t*)"\nW\r";
            }
            else
            {
                if(nAboutRcvd == -1)
                    buf = (const uint8_t*)"\nA\r";
                else if(nAboutRcvd < 100)
                    buf = (const uint8_t*)"\nB\r";
                nAboutTimeout++;
                
                if(nAboutTimeout > 3)
                {
                    nAboutRcvd = 100;
                    nAboutTimeout = 0;
                }
            }
        }
        else if(nParamRcvd >= 0 && nParamRcvd < 100)
        {
            buf = (const uint8_t*)[appDelegate getParamGetCmd:nParamRcvd];
        }
        else if([appDelegate getSendParam] >= 0)
        {
            strcpy(sendcmd, "\nX>");
            strcat(sendcmd, [appDelegate getParamRcvPrefix:[appDelegate getSendParam]]);
            strcat(sendcmd, [appDelegate getParamValueCString:[appDelegate getSendParam]]);
            strcat(sendcmd, "\r");
            
            buf = (uint8_t*)&sendcmd;
 
            nJustSentParam = [appDelegate getSendParam];
            
            NSLog(@"sending [%s]", (char*)buf);
            
        }
        else if(nCalibrationInProgress == 0) 
        {
            cnt++;
            if((cnt % 3) == 0) // request mV
            {
                buf = (const uint8_t*)"\nXM\r";
            }
            else
            {
                buf = (const uint8_t*)"\nW\r";
            }
        }
        
        //NSLog(@"timer [%s]", (char*)buf);
        
        if(buf != NULL)
        {
            [oStream write:buf maxLength:strlen((char*)buf)];
        }
        
        if(nCalibrationInProgress == 0)
        {
            readTimeout++;
            if(readTimeout >= 10)
            {
                readTimeout = 0;
                [self disconnect];
            
                NSString* msg = [[NSString alloc] initWithFormat:@"Rd timeout %@:%d", ip, nPort];
                lblStatus.text = msg;
                // [msg release];
            }
        }
    }
    else if(connState == connecting)
    {
        connTimeout++;
        if(connTimeout >= 10)
        {
            connTimeout = 0;
            [self disconnect];
            
            NSString* msg = [[NSString alloc] initWithFormat:@"Conn timeout %@:%d", ip, nPort];
            lblStatus.text = msg;
            // [msg release];
            
        }
    }
    
    if(nMessageClearCnt > 0)
    {
        nMessageClearCnt--;
        if(nMessageClearCnt == 0)
        {
            lblMessage.text = @"";
        }
    }
}

- (void) timerBtnFlash:(NSTimer*)timer
{
    UIButton* button = (UIButton*)[timer userInfo];
    [button setBackgroundColor:[UIColor whiteColor]];
 
}

const char* about[] = { "SMA", "MFG", "MOD", "REV", "SN ", "MAC", "OP2", "OP3", "OP4", "OP5", "OP6", "OP7", "OP8", "OP9", "OP0", "END" };

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    
    
    switch(eventCode) {
        case NSStreamEventNone:
            break;
        case NSStreamEventHasSpaceAvailable:
            break;
        case NSStreamEventEndEncountered:
            break;
            
        case NSStreamEventOpenCompleted:
        {
            NSString* msg = [[NSString alloc] initWithFormat:@"Connected to %@:%d", ip, nPort];
            lblStatus.text = msg;
            //[msg release];
            
            connState = connected;
        }
            break;
            
        case NSStreamEventErrorOccurred:
        {
            [self disconnect];
            
            NSError *theError = [stream streamError];
            
            NSString *message = [[NSString alloc] initWithFormat: @"%@: %@", (stream == iStream)? @"Input Stream" : @"Output Stream", [theError localizedDescription]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Stream Error"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"Yes"
                                                  otherButtonTitles:nil];
            [alert show];
            //[alert release];
            
            //[message release];
            
            
        }
            break;
            
        case NSStreamEventHasBytesAvailable:
        {
            if(stream == iStream)
            {
                
                if (data == nil)
                {
                    data = [[NSMutableData alloc] init];
                }
                uint8_t buf[1024];
                unsigned int len = 0;
                len = [(NSInputStream *)stream read:buf maxLength:1024];
                int z;
                for(z = 0; z < len; z++)
                {
                    if(buf[z] == '\r')
                    {
                        readTimeout = 0;
                        
                        inpbuf[inppos] = '\0';
                        //NSLog(@"rcv [%s]\n", inpbuf);
                        
                        // MedVue sending '0' instead of 'O' for over capacity
                        if((inpbuf[0] == ' ' || inpbuf[0] == 'Z' || inpbuf[0] == 'U' ||
                            inpbuf[0] == 'O' || inpbuf[0] == 'E' || inpbuf[0] == 'I' ||
                            inpbuf[0] == 'T' || inpbuf[0] == '0') &&
                           inpbuf[1] == '1' &&
                           (inpbuf[2] == 'G' || inpbuf[2] == 'N' || inpbuf[2] == 'T'))
                        {
                            //if(inpbuf[16] == 'k')
                            //{
                            //    lblUnits.text = @"kg";
                            //    curWtUnits = unitsKg;
                            //}
                            //else{
                            //    lblUnits.text = @"lb";
                            //    curWtUnits = unitsLb;
                            //
                            //}
                   
                            inpbuf[18] = '\0';
                            
                            NSString* units = [[NSString alloc] initWithFormat:@"%s", (inpbuf + 15)];
                            // lblUnits.text = s;
                            
                             inpbuf[15] = '\0';
                            //inpbuf[16] = '\0';
                            
                            NSString* s = [[NSString alloc] initWithFormat:@"%s %@", (inpbuf + 8), units];
                            lblScaleWt.text = s;
                            
                            //[s release];
                            
                            
                            if(inpbuf[0] == 'O')
                            {
                                lblWtStatus.text = @"OVER CAPACITY";
                            }
                            else if(inpbuf[0] == 'U')
                            {
                                lblWtStatus.text = @"BELOW ZERO";
                            }
                            else if(inpbuf[0] == 'Z')
                            {
                                lblWtStatus.text = @"CENTER ZERO";
                            }
                            else if(inpbuf[3] == 'M')
                            {
                                lblWtStatus.text = @"MOTION";
                            }
                            else
                            {
                                lblWtStatus.text = @"";
                            }
                             
                        }
                        else if(inpbuf[0] == 'O' && inpbuf[1] == 'K')
                        {
                            if(nJustSentParam != -1)
                            {
                                
                                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                
                                NSString* s = [[NSString alloc] initWithFormat:@"Sent %@ OK", [appDelegate getParamPrompt:nJustSentParam] ];
                                
                                [lblMessage setText:s];
                                [lblMessage setTextColor:[UIColor blueColor]];
                                nMessageClearCnt = 10;
                                
                                nJustSentParam = -1;
                                
                               [appDelegate nextSendParam];
                                
                                
                                if([appDelegate getSendParam] == -1)
                                {
                           //     SecondViewController* vc = [appDelegate getSetupView];
                           //     if(vc != nil)
                           //         [vc sentParamAck:[appDelegate getSendParam]];
                                     [lblMessage setText:@"Sending done"];
                                }
                                
                            }
                        }
                        else if(strstr((char*)inpbuf, "mV") != NULL)
                        {
                            //NSLog(@"mV [%s]", inpbuf);
                            
                            NSString* s = [[NSString alloc] initWithFormat:@"%s", inpbuf];
                            [lblMillivolts setText:s];
                        }
                        else if(inpbuf[3] == ':') // About response
                        {
                            NSLog(@"rcv about [%s]\n", inpbuf);
                            
                            //const uint8_t* buf;
                            int n;
                            for(n = 0; n < sizeof(about) / sizeof(about[0]); n++)
                            {
                                if(memcmp(inpbuf, about[n], 3) == 0)
                                {
                                    NSLog(@"Rcvd about item %d", n);
                                    if(n < 15)
                                    {
                                        if(n > 0 && n < 6)
                                        {
                                            NSString* s = [[NSString alloc] initWithFormat:@"%s", inpbuf];
                                            [lblAbout[n - 1] setText:s];
                                            
                                        }
                                        nAboutRcvd++;
                                    }
                                    else
                                    {
                                        nAboutRcvd = 100;
                                    }
                                    break;
                                }
                            }
                            nAboutTimeout = 0;
                        }
                        else if(inpbuf[0] == 'X')
                        {
                            NSLog(@"rcv XL [%s]\n", inpbuf);
                            if(!strcmp((const char*)inpbuf, "XL=CALIBRATING"))
                            {
                                lblMessage.text = @"CALIBRATING LOAD...";
                                [lblMessage setTextColor:[UIColor blueColor]];
                                if(nCalibrationInProgress == 1)
                                    nCalibrationInProgress = 12;
                                
                            }
                            else if(!strcmp((const char*)inpbuf, "XL=READY FOR XU CMD"))
                            {
                                lblMessage.text = @"READY FOR UNLOAD";
                                nCalibrationInProgress = 3;
                                
                                alertCalUnload = [[UIAlertView alloc] initWithTitle:@"Unload" message:@"Remove calibration weight for unload step" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                                [alertCalUnload show];

                            }
                             else if(!strcmp((const char*)inpbuf, "XU=CALIBRATING"))
                            {
                                lblMessage.text = @"CALIBRATING ZERO...";
                                nCalibrationInProgress = 12;
                            }
                            else if(!strcmp((const char*)inpbuf, "XU=CAL COMPLETE"))
                            {
                                lblMessage.text = @"CALIBRATION DONE";
                                nCalibrationInProgress = 0;
                            
                                nMessageClearCnt = 10;
                            }
                            
                        }
                        else if(strncmp((char*)inpbuf, "ERROR|", 6) == 0)
                        {
                            NSString* msg = [[NSString alloc] initWithFormat:@"%s", inpbuf + 6];
                            lblMessage.text = msg;
                            [lblMessage setTextColor:[UIColor redColor]];
                            
                            nMessageClearCnt = 10;
                        }
                        else{
                            
                            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                            int n;
                            const char* p;
                            bool found = false;
                            for(n = 0; n < SCALENET_NUM_PARAMS; n++)
                            {
                                p = [appDelegate getParamRcvPrefix:n];
                                if(memcmp(inpbuf, p, strlen(p)) == 0)
                                {
                                    found = true;
                                    
                                    //NSLog(@"Get param %d %s", n, p);
                                    
                                    [appDelegate setParamItem:n buffer:inpbuf + strlen(p)];
                                    
                                    if(n < SCALENET_NUM_PARAMS - 1)
                                        nParamRcvd = n + 1;
                                    else
                                    {
                                      //  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                      //  SecondViewController* vc = [appDelegate getSetupView];
                                      //  if(vc != nil)
                                      //      [vc updateInputs];
                                        if(setupView != nil)
                                            [setupView updateInputs];
                                       nParamRcvd = 100;
                                    }
                                    break;
                                }
                            }
                            
                            if(found == false)
                            {
                                NSLog(@"rcv unknown [%s]\n", inpbuf);
                            }
                            
                        }
                        
                        inppos = 0;
                    }
                    else if(inppos < 127 && buf[z] >= ' ' && buf[z] < 127)
                    {
                        inpbuf[inppos++] = buf[z];
                    }
                    
                }
                
                // [data release];
                data = nil;
            }
        }
            
    }
}

- (void)finishSetup:(int)accept
{
    [setupView removeFromSuperview];
    setupView = nil;
    int n;
    for(n = 0; n < 4; n++)
    {
        [btn[n] setHidden:NO];
    }
    
}


@end
