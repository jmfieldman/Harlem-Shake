//
//  TextEditViewController.h
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/13/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextEditViewController : UIViewController <UITextViewDelegate> {
	UITextView *_textView;
}

@property (nonatomic, strong) NSMutableString *stringToEdit;

@end
