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

@property (nonatomic, strong) VideoID_t  videoId;
@property (nonatomic, strong) NSString  *attributeName;

@end
