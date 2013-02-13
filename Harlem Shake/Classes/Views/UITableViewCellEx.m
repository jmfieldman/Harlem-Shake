//
//  UITableViewCellEx.m
//

#import "UITableViewCellEx.h"

#define kUITableViewCellExDefaultCellHeight 40

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


@end
