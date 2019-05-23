//
//  TackersController.h
//  iTransmission
//
//  Created by Dhruvit Raithatha on 16/12/13.
//
//

#import <Foundation/Foundation.h>
#import "TrackerCell.h"
#import "Torrent.h"
#import "TrackerNode.h"
#import "NSStringAdditions.h"
#import "UIAlertViewPrivate.h"

@class Torrent, TrackerCell;

@interface TrackersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIDocumentInteractionControllerDelegate>
@property (nonatomic, readonly) Torrent *torrent;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UIDocumentInteractionController *docController;
@property (nonatomic, retain) NSTimer *updateTimer;

- (void)initWithTorrent:(Torrent*)t;

- (void)updateCell:(TrackerCell*)cell;
- (void)editButtonTouched;

- (void)addButtonTouched;

- (void)removeButtonTouched;
- (void)reloadTrackers;

@end
