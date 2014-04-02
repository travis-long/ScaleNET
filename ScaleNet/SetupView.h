//
//  SetupView.h
//  ScaleNet
//
//  Created by Don Wilson on 6/12/13.
//  Copyright (c) 2013 Don Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetupViewDelegate <NSObject>
@required
- (void)finishSetup:(int)accept;
@end

@interface SetupView : UIView <UITextFieldDelegate>
{
    UILabel* lblLabel[16];
    UITextField* textValue[16];
    
    UIButton* btnSubmit;
    UIButton* btnCancel;
    
    UITextField* textFieldWt;
    
    //UILabel* lblStatus;
    
    id <NSObject, SetupViewDelegate > delegate;

    
}
@property (retain) id <NSObject, SetupViewDelegate > delegate;

- (void)updateInputs;

- (void)submitPressed:(id)sender;
- (void)cancelPressed:(id)sender;
- (void)tapCaptured:(UITapGestureRecognizer *)gesture;
- (void)sendParams;

@end
