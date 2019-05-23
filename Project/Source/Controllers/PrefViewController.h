//
//  PrefViewController.h
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Controller.h"

@class GradientButton;
@class PortChecker;
@class Controller;
@interface PrefViewController :UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) PortChecker *portChecker;
@property (nonatomic, retain) NSDictionary *originalPreferences;
@property (nonatomic, retain) NSIndexPath *indexPathToScroll;
@property (nonatomic, assign) Controller *controller;
@property (nonatomic, strong) TorrentViewController *torrentView;

- (void)closeButtonClicked;
- (void)portCheckButtonClicked;
- (void)keyboardDoneButton:(id)sender;

- (void)loadPreferences;

- (IBAction)checkPortButtonClicked:(id)sender;
- (IBAction)enableBackgroundDownloadSwitchChanged:(id)sender;

- (IBAction)uploadSpeedLimitEnabledValueChanged:(id)sender;
- (IBAction)downloadSpeedLimitEnabledValueChanged:(id)sender;
- (IBAction)connectionsPerTorrentChanged:(id)sender;
- (IBAction)maximumConnectionsPerTorrentChanged:(id)sender;

- (IBAction)tweet:(id)sender;

@end
