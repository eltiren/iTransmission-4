//
//  TorrentViewController.h
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALAlertBanner.h"
#import <AVFoundation/AVFoundation.h>

@class Controller;
@class TDBadgeView;
@class Torrent;
@class TorrentCell;
@class PrefViewController;
@class LeftMenuController;

@interface TorrentViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIView *activityItemView;
@property (nonatomic, retain) IBOutlet TDBadgeView *activityCounterBadge;
@property (nonatomic, retain) NSArray *normalToolbarItems;
@property (nonatomic, retain) UIBarButtonItem *activityItem;
@property (nonatomic, retain) NSMutableArray *selectedIndexPaths;
@property (strong, nonatomic) AVAudioPlayer *audio;
@property (nonatomic, retain) PrefViewController *pref;
@property (nonatomic, retain) Controller *controller;
@property (nonatomic, retain) NSTimer *updateTimer;
@property (nonatomic, retain) LeftMenuController *leftMenu;

- (void)addFromURLWithExistingURL:(NSString*)url message:(NSString*)msg;
- (void)addFromMagnetWithExistingMagnet:(NSString*)magnet message:(NSString*)msg;
- (void)newTorrentAdded:(NSNotification*)notif;
- (void)removedTorrents:(NSNotification*)notif;
- (void)playAudio:(NSNotification*)notif;

- (void)controlButtonClicked:(id)sender;
- (void)resumeButtonClicked:(id)sender;
- (void)pauseButtonClicked:(id)sender;
- (void)removeButtonClicked:(id)sender;

- (void)setupCell:(TorrentCell*)cell forTorrent:(Torrent*)torrent;

- (void)updateCell:(TorrentCell*)c;

@end
