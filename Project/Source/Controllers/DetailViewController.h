//
//  DetailViewController.h
//  iTransmission
//
//  Created by Mike Chen on 10/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Torrent;
@class Controller;
@class FlexibleLabelCell;

@interface DetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) Torrent *torrent;
@property (nonatomic, retain) UIBarButtonItem *startButton;
@property (nonatomic, retain) UIBarButtonItem *pauseButton;
@property (nonatomic, retain) UIBarButtonItem *removeButton;
@property (nonatomic, retain) UIBarButtonItem *refreshButton;
@property (nonatomic, retain) UIBarButtonItem *bandwidthButton;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, retain) Controller *controller;
@property (nonatomic, retain) NSTimer *updateTimer;

- (void)initWithTorrent:(Torrent*)t controller:(Controller*)c;

- (void)startButtonClicked:(id)sender;
- (void)pauseButtonClicked:(id)sender;
- (void)removeButtonClicked:(id)sender;
- (void)sessionStatusChanged:(NSNotification*)notif;
- (void)bandwidthButtonClicked:(id)sender;

- (void)performRemove:(BOOL)trashData;

@end
