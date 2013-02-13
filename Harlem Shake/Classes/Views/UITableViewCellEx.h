//
//  UITableViewCellEx.h
//

#import <UIKit/UIKit.h>


@interface UITableViewCellEx : UITableViewCell {
	UILabel *_footerLabel;
}

@property (nonatomic, assign) BOOL selectionActivatesAccessory;
@property (nonatomic, assign) float cellHeight;
@property (nonatomic, assign) BOOL shouldHighlight;
@property (nonatomic, assign) BOOL shouldSelect;

@property (nonatomic, strong) NSString *sectionFooterText;

@end
