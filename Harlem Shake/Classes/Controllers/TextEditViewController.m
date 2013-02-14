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
		self.view.backgroundColor = [UIColor whiteColor];
		self.view.autoresizesSubviews = YES;
		self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		
		/* Text view */
		_textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 300, 300-216)];
		_textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_textView.backgroundColor = [UIColor clearColor];
		_textView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
		[self.view addSubview:_textView];
				
	}
	return self;
}


- (void) setAttributeName:(NSString *)attributeName {
	_attributeName = attributeName;
	if (_videoId) {
		_textView.text = [[[VideoModel sharedInstance] videoDic:_videoId] objectForKey:_attributeName];
	}
}


- (void) viewWillAppear:(BOOL)animated {
	[_textView becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated {
	[[[VideoModel sharedInstance] videoDic:_videoId] setObject:[NSMutableString stringWithString:_textView.text] forKey:_attributeName];
}


@end
