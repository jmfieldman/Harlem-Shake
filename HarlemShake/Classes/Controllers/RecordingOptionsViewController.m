//
//  RecordingOptionsViewController.m
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/13/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import "RecordingOptionsViewController.h"

#import "UITableViewCellEx.h"

@implementation RecordingOptionsViewController

- (id) init {
	if ((self = [super init])) {
		
		/* title */
		self.title = @"Recording Options";
		
		/* Initialize the main view */
		self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
		self.view.backgroundColor = [UIColor clearColor];
		self.view.autoresizesSubviews = YES;
		self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		
		/* Initialize the table */
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100) style:UITableViewStyleGrouped];
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_tableView.backgroundColor = [UIColor clearColor];
		_tableView.delegate = self;
		_tableView.dataSource = self;
		[self.view addSubview:_tableView];
		
		
		
	}
	return self;
}


- (void) viewWillAppear:(BOOL)animated {
	[self initializeTableCells];
	[_tableView reloadData];
}


- (void) initializeTableCells {
	
	_tableCells = [NSMutableArray array];
	
	{
		NSMutableArray *currentSection = [NSMutableArray array];
		
		{
			UISwitch *tog = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
			[tog addTarget:self action:@selector(toggledPlaySong:) forControlEvents:UIControlEventValueChanged];
			tog.on = [OptionsModel playSong];
			
			UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.text = @"Play Song";
			cell.accessoryView = tog;
			[currentSection addObject:cell];
		}
		
		{
			UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
			cell.sectionFooterText = @"If ON, this will cause the app to the play the corresponding audio clip while video is being recorded.";
			[currentSection addObject:cell];
		}
				
		[_tableCells addObject:currentSection];
	}
	
	{
		NSMutableArray *currentSection = [NSMutableArray array];
		
		{
			UISegmentedControl *tog = [[UISegmentedControl alloc] initWithItems:@[@"Low", @"Medium", @"High"]];
			[tog addTarget:self action:@selector(toggledQuality:) forControlEvents:UIControlEventValueChanged];
			tog.segmentedControlStyle = UISegmentedControlStyleBar;
			tog.selectedSegmentIndex = [OptionsModel desiredQuality];
			
			UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.text = @"Quality";
			cell.accessoryView = tog;
			[currentSection addObject:cell];
		}
		
		{
			UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
			cell.sectionFooterText = @"Selects the video quality to record in.  Higher quality will produce higher resolution, but larger files.  Quality is dependent on the device.";
			[currentSection addObject:cell];
		}
		
		[_tableCells addObject:currentSection];
	}
	
	{
		NSMutableArray *currentSection = [NSMutableArray array];
		
		{
			UISegmentedControl *tog = [[UISegmentedControl alloc] initWithItems:@[@"Off", @"5s", @"10s", @"30s"]];
			[tog addTarget:self action:@selector(toggledTimerDelay:) forControlEvents:UIControlEventValueChanged];
			tog.segmentedControlStyle = UISegmentedControlStyleBar;
			tog.selectedSegmentIndex = 0;
			int opt = [OptionsModel timerDelay];
			if (opt == 5 ) tog.selectedSegmentIndex = 1;
			if (opt == 10) tog.selectedSegmentIndex = 2;
			if (opt == 30) tog.selectedSegmentIndex = 3;
			
			UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.text = @"Timer Delay";
			cell.accessoryView = tog;
			[currentSection addObject:cell];
		}
		
		{
			UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
			cell.sectionFooterText = @"If set, after hitting the button to record a clip, the app will wait for the selected time before recording begins.";
			[currentSection addObject:cell];
		}
		
		[_tableCells addObject:currentSection];
	}
	
	{
		NSMutableArray *currentSection = [NSMutableArray array];
		
		{
			UISegmentedControl *tog = [[UISegmentedControl alloc] initWithItems:@[@"Off", @"5s", @"10s", @"30s"]];
			[tog addTarget:self action:@selector(toggledRecordBoth:) forControlEvents:UIControlEventValueChanged];
			tog.segmentedControlStyle = UISegmentedControlStyleBar;
			tog.selectedSegmentIndex = 0;
			int opt = [OptionsModel recordBoth];
			if (opt == 5 ) tog.selectedSegmentIndex = 1;
			if (opt == 10) tog.selectedSegmentIndex = 2;
			if (opt == 30) tog.selectedSegmentIndex = 3;
			
			UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.text = @"Record Both";
			cell.accessoryView = tog;
			[currentSection addObject:cell];
		}
		
		{
			UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
			cell.sectionFooterText = @"If set, after the app has finished recording the \"Before Drop\" clip, it will automatically record the \"After Drop\" clip after this amount of time.";
			[currentSection addObject:cell];
		}
		
		[_tableCells addObject:currentSection];
	}
	
	if ([OptionsModel hasDeviceWithFlash]) {
		NSMutableArray *currentSection = [NSMutableArray array];
		
		{
			UISwitch *tog = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
			[tog addTarget:self action:@selector(toggledFlashBlink:) forControlEvents:UIControlEventValueChanged];
			tog.on = [OptionsModel flashBlink];
			
			UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.text = @"Timer Flash Blink";
			cell.accessoryView = tog;
			[currentSection addObject:cell];
		}
		
		{
			UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
			cell.sectionFooterText = @"We've detected that your device has a flash.  If this option is ON, and the timer delay is enabled, the flash will blink during the last three seconds of the timer before recording starts.";
			[currentSection addObject:cell];
		}
		
		[_tableCells addObject:currentSection];
	}
	
}


#pragma mark Accessory handlers

- (void) toggledPlaySong:(id)sender {
	UISwitch *tog = (UISwitch*)sender;
	[OptionsModel setPlaySong:tog.on];
}


- (void) toggledQuality:(id)sender {
	UISegmentedControl *tog = (UISegmentedControl*)sender;
	[OptionsModel setDesiredQuality:tog.selectedSegmentIndex];
}

- (void) toggledTimerDelay:(id)sender {
	UISegmentedControl *tog = (UISegmentedControl*)sender;
	if (tog.selectedSegmentIndex == 0) [OptionsModel setTimerDelay:0];
	if (tog.selectedSegmentIndex == 1) [OptionsModel setTimerDelay:5];
	if (tog.selectedSegmentIndex == 2) [OptionsModel setTimerDelay:10];
	if (tog.selectedSegmentIndex == 3) [OptionsModel setTimerDelay:30];
}

- (void) toggledRecordBoth:(id)sender {
	UISegmentedControl *tog = (UISegmentedControl*)sender;
	if (tog.selectedSegmentIndex == 0) [OptionsModel setRecordBoth:0];
	if (tog.selectedSegmentIndex == 1) [OptionsModel setRecordBoth:5];
	if (tog.selectedSegmentIndex == 2) [OptionsModel setRecordBoth:10];
	if (tog.selectedSegmentIndex == 3) [OptionsModel setRecordBoth:30];
}

- (void) toggledFlashBlink:(id)sender {
	UISwitch *tog = (UISwitch*)sender;
	[OptionsModel setFlashBlink:tog.on];
}


#pragma mark UITableViewDelegate methods

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
	return [_tableCells count];
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[_tableCells objectAtIndex:section] count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[_tableCells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEx *cell = [[_tableCells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	return cell.cellHeight;
}



@end
