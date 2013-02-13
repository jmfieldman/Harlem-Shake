//
//  UITableViewCellEx.m
//

#import "UITableViewCellEx.h"

#define kUITableViewCellExDefaultCellHeight 40

#define kFooterWidth 280

@implementation UITableViewCellEx

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		_cellHeight = kUITableViewCellExDefaultCellHeight;
    }
	return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {    
	if (_selectionActivatesAccessory && selected) {
		[self.accessoryView becomeFirstResponder];
		return;
	}	
	if (_shouldSelect) {
		[super setSelected:selected animated:animated]; 
	}
}


- (void)setHighlighted:(BOOL)selected animated:(BOOL)animated {    
	if (_shouldHighlight) {
		[super setHighlighted:selected animated:animated];
	}		
}


- (void) setSectionFooterText:(NSString *)sectionFooterText {
	_sectionFooterText = sectionFooterText;
	_shouldHighlight = NO;
	_shouldSelect = NO;
	_selectionActivatesAccessory = NO;
	
	[_footerLabel removeFromSuperview];
	_footerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_footerLabel.text = sectionFooterText;
	_footerLabel.textAlignment = NSTextAlignmentLeft;
	_footerLabel.backgroundColor = [UIColor clearColor];
	_footerLabel.font = [UIFont systemFontOfSize:12];
	_footerLabel.numberOfLines = 0;
	[self.contentView addSubview:_footerLabel];
	
	/* Get height */
	CGSize labelSize = [sectionFooterText sizeWithFont:_footerLabel.font constrainedToSize:CGSizeMake(kFooterWidth, 10000)];
	_cellHeight = labelSize.height + 10;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	
	if (_sectionFooterText) {
		_footerLabel.frame = CGRectMake((self.contentView.frame.size.width - kFooterWidth)/2, 5, kFooterWidth, _cellHeight - 10);
	}
}


@end
