//
//  SetupView.m
//  ScaleNet
//
//  Created by Don Wilson on 6/12/13.
//  Copyright (c) 2013 Don Wilson. All rights reserved.
//
// GIT Test

#import "SetupView.h"
#import "AppDelegate.h"

@implementation SetupView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // Do any additional setup after loading the view, typically from a nib.
        NSLog(@"SetupView initWithFrame");
        
        int n;
        CGFloat y = 5.0;
        
        
        self.backgroundColor = [UIColor whiteColor];
         
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCaptured:)];
        [self addGestureRecognizer:tap];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        for(n = 0; n < SCALENET_NUM_PARAMS; n++)
        {
            lblLabel[n] = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, y, 160.0f, 28.0f)];
            [lblLabel[n] setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
            [lblLabel[n] setBackgroundColor:[UIColor clearColor]];
            [lblLabel[n] setTextColor:[UIColor blackColor]];
            [lblLabel[n] setText:[appDelegate getParamPrompt:n]];
            //[lbl release];
            [lblLabel[n] setTextAlignment:NSTextAlignmentLeft];
            [self addSubview:lblLabel[n]];
            
            textValue[n] = [[UITextField alloc] initWithFrame:CGRectMake(170.0f, y, n == 0? 110.0f : 50.0f, 28.0f)];
            [textValue[n] setBorderStyle:UITextBorderStyleLine];
            [textValue[n] setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
            
            [textValue[n] setKeyboardType:[appDelegate getParamKeyboardType:n]];
            [textValue[n] setDelegate:self];
            
            [self addSubview:textValue[n]];
            y += 34.0;
        }
        
        y += 10.0;
        
        btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSubmit.frame = CGRectMake(30.0f, y, 120.0f, 40.0f);
        [btnSubmit addTarget:self action:@selector(submitPressed:) forControlEvents:UIControlEventTouchDown];
      //  [btnSubmit set]
        [btnSubmit setBackgroundColor:[UIColor grayColor]];
        [btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [btnSubmit.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
        [btnSubmit setTitle:@"Accept" forState:UIControlStateNormal];
        
        
        [self addSubview:btnSubmit];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCancel.frame = CGRectMake(160.0f, y, 120.0f, 40.0f);
        [btnCancel addTarget:self action:@selector(cancelPressed:) forControlEvents:UIControlEventTouchDown];
        [btnCancel setBackgroundColor:[UIColor grayColor]];
        [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnCancel.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
        [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
        
        
        [self addSubview:btnCancel];
        
       

        [self updateInputs];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [textValue[0] becomeFirstResponder];
        }

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
         
- (void)sendParams
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
    // Check for changes
    bool chged = false;
            
    int n;
    for(n = 0; n < SCALENET_NUM_PARAMS; n++)
    {
         const char *p = [textValue[n].text UTF8String];
         const char *p2 = [appDelegate getParamValueCString:n];
         if(strcmp(p, p2) != 0)
         {
              [appDelegate setParamItem:n buffer:(uint8_t*)p];
              chged = true;
         }
                
    }
            
    if(chged == true)
    {
         NSLog(@"Sending params");
                
         // TODO instruct first view to send the updated parameters
         [appDelegate sendParams];
    }
            
}


- (void)submitPressed:(id)sender
{
     NSLog(@"Submit pressed");
     [self sendParams];
    [delegate finishSetup:1];
}

- (void)cancelPressed:(id)sender
{
    NSLog(@"Cancel pressed");
    [delegate finishSetup:0];
}

- (void)updateInputs
{
     AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
     int n;
     for(n = 0; n < SCALENET_NUM_PARAMS; n++)
     {
           [textValue[n] setText:[appDelegate getParamValueString:n]];
     }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
     NSLog(@"shouldAutorotate");
     return YES;
}
         
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn");
    
  //  if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
  //  {
  //           [textField resignFirstResponder];
  //  }
  //  else
  //  {
        int n;
        for(n = 0; n < SCALENET_NUM_PARAMS - 1; n++)
        {
            if(textField == textValue[n])
            {
                [textValue[n + 1] becomeFirstResponder];
                
                break;
            }
        }
        
   // }
    return YES;
}

- (void)textFieldDidBeginEditing :(UITextField *)textField
{
    // Check whether to move window to input will show when keyboard is shown
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        int n;
        for(n = 0; n < SCALENET_NUM_PARAMS; n++)
        {
            if(textField == textValue[n])
            {
                NSLog(@"textFieldDidBeginEditing %d", n);
                if(n < 6)
                    self.frame = CGRectMake(0, 0, 320, 600);
                else
                    self.frame = CGRectMake(0, -120, 320, 600);
            
                break;
            }
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
             
    NSLog(@"textFieldEndEditing");
    int n;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for(n = 0; n < SCALENET_NUM_PARAMS; n++)
    {
         if(textField == textValue[n])
         {
              int flag = [appDelegate getParamFlag:n];
              if(flag == SCALENET_CHK_RANGE || flag == SCALENET_CHK_MIN || flag == SCALENET_CHK_INTV)
              {
                  int val = [textField.text intValue];
                         NSLog(@"textFieldEndEditing [%@] val %d", [appDelegate getParamPrompt:n], val);
                         
                  if(flag == SCALENET_CHK_RANGE)
                  {
                       if(val < [appDelegate getParamMin:n] || val > [appDelegate getParamMax:n])
                       {
                            NSString *message = [[NSString alloc] initWithFormat: @"%@ must be from %d to %d", [appDelegate getParamPrompt:n], [appDelegate getParamMin:n], [appDelegate getParamMax:n]];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Input Value"
                                                                                 message:message
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"Ok"
                                                                       otherButtonTitles:nil];
                            [alert show];
                            //  [alert release];
                                 
                            // [message release];
                            [textValue[n] setText:[appDelegate getParamValueString:n]];
                           
                      }
                 }
                         else if(flag == SCALENET_CHK_MIN)
                         {
                             if(val < [appDelegate getParamMin:n])
                             {
                                 NSString *message = [[NSString alloc] initWithFormat: @"%@ must be at least %d", [appDelegate getParamPrompt:n], [appDelegate getParamMin:n]];
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Input Value"
                                                                                 message:message
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"Yes"
                                                                       otherButtonTitles:nil];
                                 [alert show];
                                 
                                 [textValue[n] setText:[appDelegate getParamValueString:n]];
                             }
                         }
                         else if(flag == SCALENET_CHK_INTV)
                         {
                             if(val != 1 && val != 2 && val != 5 && val != 10 && val != 20)
                             {
                                 NSString *message = [[NSString alloc] initWithFormat: @"%@ must be 1, 2, 5, 10, or 20", [appDelegate getParamPrompt:n]];
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Input Value"
                                                                                 message:message
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"Yes"
                                                                       otherButtonTitles:nil];
                                 [alert show];
                                 
                                 [textValue[n] setText:[appDelegate getParamValueString:n]];
                                 
                             }
                         }
                         
                     }
                     
                     
                     break;
                 }
             }
         }
         
         //- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
         //{
         //   NSLog(@"touchesBegan");
         //  [self.view endEditing:YES];
         //}
         
         - (void)tapCaptured:(UITapGestureRecognizer *)gesture
        {
            NSLog(@"tapCaptured");
            
            if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
            {
                [self endEditing:YES];
                self.frame = CGRectMake(0, 0, 320, 600);
            }
            
            
        }


@end
