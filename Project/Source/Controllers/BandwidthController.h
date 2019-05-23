//
//  BandwidthController.h
//  iTransmission
//
//  Created by Mike Chen on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Controller.h"

@class Torrent;
@interface BandwidthController : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) Controller *controller;
@property (nonatomic, assign) Torrent *torrent;
@property (nonatomic, readonly, getter=isVisible) BOOL visible;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSIndexPath *indexPathToScroll;

- (IBAction)maximumConnectionsSliderValueChanged:(id)sender;
- (IBAction)connectionsPerTorrentSliderValueChanged:(id)sender;
- (IBAction)uploadSpeedLimitEnabledValueChanged:(id)sender;
- (IBAction)downloadSpeedLimitEnabledValueChanged:(id)sender;
- (IBAction)overrideGlobalLimitsEnabledValueChanged:(id)sender;

- (void)enableOrDisableLimitCells;
- (void)hide;
- (void)keyboardDoneButton:(id)sender;
- (void)resizeToFit;

- (void)keyboardWillHide:(NSNotification*)notif;
- (void)keyboardDidHide:(NSNotification*)notif;
- (void)keyboardWillShow:(NSNotification*)notif;
- (void)keyboardDidShow:(NSNotification*)notif;

@end
