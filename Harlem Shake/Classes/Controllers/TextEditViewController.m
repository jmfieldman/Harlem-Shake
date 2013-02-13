//
//  TextEditViewController.m
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/13/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import "TextEditViewController.h"

@implementation TextEditViewController

- (id) init {
	if ((self = [super init])) {
		/* Initialize the main view */
		self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
		self.view.backgroundColor = [UIColor clearColor];
		self.view.autoresizesSubviews = YES;
		self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		
		/* Text view */
		_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 300-216)];
		_textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_textView.backgroundColor = [UIColor yellowColor];
		_textView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
		[self.view addSubview:_textView];
				
	}
	return self;
}


- (void) setStringToEdit:(NSMutableString *)stringToEdit {
	_stringToEdit = stringToEdit;
	_textView.text = stringToEdit;
}


- (void) viewWillAppear:(BOOL)animated {
	[_textView becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated {
	[_stringToEdit setString:_textView.text];
}


@end
