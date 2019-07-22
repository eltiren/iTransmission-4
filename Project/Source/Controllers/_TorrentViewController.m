//
//  TorrentViewController.m
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <iTransmission-Swift.h>
#import "_TorrentViewController.h"
#import "Controller.h"
#import "Torrent.h"
#import "PrefViewController.h"
#import "TDBadgedCell.h"
#import "Notifications.h"
#import "NSStringAdditions.h"
#import "DetailViewController.h"
#import "ControlButton.h"
#import "PDColoredProgressView.h"
#import "BandwidthController.h"
#import <SafariServices/SafariServices.h>

#define ADD_TAG 1000
#define ADD_FROM_URL_TAG 1001
#define ADD_FROM_MAGNET_TAG 1002
#define REMOVE_COMFIRM_TAG 1003

@implementation _TorrentViewController

@synthesize tableView;
@synthesize activityIndicator;
@synthesize activityItemView;
@synthesize activityCounterBadge;
@synthesize normalToolbarItems;
@synthesize selectedIndexPaths;
@synthesize activityItem;
@synthesize audio;
@synthesize pref;


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     if (self.tableView.editing == NO) {
     }
     else {
     [self.selectedIndexPaths removeObject:indexPath];
     TorrentCell *cell = (TorrentCell*)[self.tableView cellForRowAtIndexPath:indexPath];
     [cell.controlButton setEnabled:YES];
     }
     */
}

- (UITableViewCell *)tableView:(UITableView *)ftableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    TorrentCell *cell = (TorrentCell*)[ftableView dequeueReusableCellWithIdentifier:TorrentCell.identifier];
    
    [cell.controlButton addTarget:self action:@selector(controlButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    Torrent *t = [self.controller torrentAtIndex:index];
    [self setupCell:cell forTorrent:t];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath { 
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Torrent * torrent = [self.controller torrentAtIndex:indexPath.row];
    self.selectedIndexPaths = [NSMutableArray array];
    [self.selectedIndexPaths addObject:indexPath];
    NSString *msg = [NSString stringWithFormat:@"Are you sure to remove %@ torrent?", [torrent name]];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *removeDataAction = [UIAlertAction actionWithTitle:@"Yes and remove data" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self removeTorrentsTrashData:YES];
    }];
    [actionSheet addAction:removeDataAction];
    
    UIAlertAction *keepDataAction = [UIAlertAction actionWithTitle:@"Yes, but keep data" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self removeTorrentsTrashData:NO];
    }];
    [actionSheet addAction:keepDataAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.selectedIndexPaths = [NSMutableArray array];
    }];
    [actionSheet addAction:cancelAction];
    
    if (actionSheet.popoverPresentationController != nil) {
        actionSheet.popoverPresentationController.sourceView = self.tableView;
    }
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)controlButtonClicked:(id)sender
{
    CGPoint pos = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pos];

    Torrent *torrent = [self.controller torrentAtIndex:indexPath.row];
    if ([torrent isActive])
        [torrent stopTransfer];
    else
        [torrent startTransfer];

    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setupCell:(TorrentCell*)cell forTorrent:(Torrent*)t
{
    [t update];
    cell.nameLabel.text = [t name];
    cell.upperDetailLabel.text = [t progressString];
    if (![t isChecking]) {
        [cell.progressView setProgress:[t progress]];
    }
    
    if ([t isSeeding])
        [cell useGreenColor];
    else if ([t isChecking]) {
        [cell useGreenColor];
        [cell.progressView setProgress:[t checkingProgress]];
    }
    else if ([t isActive] && ![t isComplete])
        [cell useBlueColor];
    else if (![t isActive])
        [cell useBlueColor];
    else if (![t isChecking])
        [cell useGreenColor];
    if ([t isActive])
        [cell.controlButton setPauseStyle];
    else
        [cell.controlButton setResumeStyle];

    if (![self.controller isStartingTransferAllowed]) {
        [cell.controlButton setEnabled:NO];
    }
    else {
        [cell.controlButton setEnabled:YES];
    }
    cell.lowerDetailLabel.text = [t statusString];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // transmission init
    self.controller = (Controller*)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removedTorrents:) name:NotificationTorrentsRemoved object:self.controller];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityCounterDidChange:) name:NotificationActivityCounterChanged object:self.controller];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTorrentAdded:) name:NotificationNewTorrentAdded object:self.controller];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playAudio:) name:@"AudioPrefChanged" object:self.pref];
    
    // load audio
    NSURL *audioURL = [[NSBundle mainBundle] URLForResource:@"phone" withExtension:@"mp3"];
    self.audio = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
    self.audio.numberOfLoops = -1;
    [self.audio setVolume:0.0];
    
    // only play if enabled
    NSUserDefaults *fDefaults = [NSUserDefaults standardUserDefaults];
    if([fDefaults boolForKey:@"BackgroundDownloading"])
    {
        // play audio
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        [self.audio play];
    }
    
    
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)resumeButtonClicked:(id)sender
{
    for (NSIndexPath *indexPath in self.selectedIndexPaths) {
        Torrent *torrent = [self.controller torrentAtIndex:indexPath.row];
        [torrent startTransfer];
    }
    [self.tableView reloadData];
    self.selectedIndexPaths = nil;
}

- (void)pauseButtonClicked:(id)sender
{
    for (NSIndexPath *indexPath in self.selectedIndexPaths) {
        Torrent *torrent = [self.controller torrentAtIndex:indexPath.row];
        [torrent stopTransfer];
    }
    [self.tableView reloadData];
    self.selectedIndexPaths = nil;
}

- (void)removeButtonClicked:(id)sender
{
    NSString *msg;
    if ([self.selectedIndexPaths count] == 1) {
        msg = @"Are you sure to remove one torrent?";
    } else {
        msg = [NSString stringWithFormat:@"Are you sure to remove %lu torrents?", (unsigned long)[self.selectedIndexPaths count]];
    }

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *removeDataAction = [UIAlertAction actionWithTitle:@"Yes and remove data" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self removeTorrentsTrashData:YES];
    }];
    [actionSheet addAction:removeDataAction];
    
    UIAlertAction *keepDataAction = [UIAlertAction actionWithTitle:@"Yes, but keep data" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self removeTorrentsTrashData:NO];
    }];
    [actionSheet addAction:keepDataAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.selectedIndexPaths = [NSMutableArray array];
    }];
    [actionSheet addAction:cancelAction];
    
    if (actionSheet.popoverPresentationController != nil) {
        actionSheet.popoverPresentationController.sourceView = (UIView *)sender;
    }
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)removeTorrentsTrashData:(BOOL)trashData {
    NSMutableArray *torrents = [NSMutableArray arrayWithCapacity:[self.selectedIndexPaths count]];
    for (NSIndexPath *indexPath in self.selectedIndexPaths) {
        Torrent *t = [self.controller torrentAtIndex:indexPath.row];
        [torrents addObject:t];
    }
    [self.controller removeTorrents:torrents trashData:trashData];
    self.selectedIndexPaths = [NSMutableArray array];
    [self.tableView reloadData];
}

- (void)updateUI
{
    NSArray *visibleCells = [self.tableView visibleCells];

    for (TorrentCell *cell in visibleCells) {
        [self performSelector:@selector(updateCell:) withObject:cell afterDelay:0.0f];
    }
}

- (void)updateCell:(TorrentCell*)c
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:c];
    if (indexPath) {
        Torrent *torrent = [self.controller torrentAtIndex:indexPath.row];
        [self setupCell:c forTorrent:torrent];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addFromURLWithExistingURL:(NSString*)url message:(NSString*)msg
{
    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Add from URL" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *url = dialog.textFields.firstObject.text;
        if (![url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])
            [self addFromURLWithExistingURL:url message:@"Error: The URL provided is malformed!"];
        else {
            [self.controller addTorrentFromURL:url];
        }
    }];
    [dialog addAction:okAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [dialog addAction:cancelAction];
    
    [dialog addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.enablesReturnKeyAutomatically = YES;
        textField.keyboardAppearance = UIKeyboardAppearanceDefault;
        textField.keyboardType = UIKeyboardTypeURL;
        textField.returnKeyType = UIReturnKeyDone;
        textField.secureTextEntry = NO;
    }];
    [self presentViewController:dialog animated:YES completion:nil];
}

- (void)addFromMagnetWithExistingMagnet:(NSString*)magnet message:(NSString*)msg
{
    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Add from magnet" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *magnet = dialog.textFields.firstObject.text;
        NSError *error = [self.controller addTorrentFromManget:magnet];
        if (error) {
            [self addFromMagnetWithExistingMagnet:magnet message:[error localizedDescription]];
        }
    }];
    [dialog addAction:okAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [dialog addAction:cancelAction];
    
    [dialog addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.enablesReturnKeyAutomatically = YES;
        textField.keyboardAppearance = UIKeyboardAppearanceDefault;
        textField.keyboardType = UIKeyboardTypeURL;
        textField.returnKeyType = UIReturnKeyDone;
        textField.secureTextEntry = NO;
    }];
    
    [self presentViewController:dialog animated:YES completion:nil];
}

- (void)activityCounterDidChange:(NSNotification*)notif
{
    NSInteger num = self.controller.activityCounter;
    if (num > 0) {
        self.navigationItem.rightBarButtonItem = self.activityItem;
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        [self.activityCounterBadge setHidden:NO];
        [self.activityCounterBadge setBadgeNumber:[NSString stringWithFormat:@"%li", (long)num]];
        [self.activityCounterBadge setNeedsDisplay];
    }
    else if (num == 0) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        [self.activityCounterBadge setHidden:YES];
    }
}

- (void)newTorrentAdded:(NSNotification*)notif
{
    [self.tableView reloadData];
}

- (void)removedTorrents:(NSNotification*)notif
{
    [self.tableView reloadData];
}

- (void)playAudio:(NSNotification *)notif
{
    // load audio
    NSError *error;
    NSURL *audioURL = [[NSBundle mainBundle] URLForResource:@"phone" withExtension:@"mp3"];
    self.audio = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&error];
    self.audio.numberOfLoops = -1;
    [self.audio setVolume:0.0];
    
    NSLog(@"%@", error.localizedDescription);
    
    // only play if enabled
    NSNumber *value = notif.object;
    if(value.intValue == 1)
    {
        // play audio
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self.audio setDelegate:self];
        [self.audio prepareToPlay];
        [self.audio play];
        NSLog(@"Going to play");
        
    }
    else
    {
        // stop audio
        [self.audio stop];
        NSLog(@"Not going to play");
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
    
    // start timer
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
    [self updateUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // stop update timer
    [self.updateTimer invalidate];
}

- (void)showViewController:(UIViewController *)vc sender:(id)sender {
    if ([vc isKindOfClass:[UIAlertController class]] || [vc isKindOfClass:[SFSafariViewController class]]) {
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([vc isKindOfClass: [DetailViewController class]]) {
        [super showViewController:vc sender:sender];
    } else {
        UINavigationController *navigationControlller = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:navigationControlller animated:YES completion:nil];
    }
}

#pragma mark -

- (void)openMenuAction:(UIBarButtonItem *)sender {
    UIAlertController *menuActionSheetController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Menu", @"Menu action sheet title")
                                                                                       message:nil
                                                                                preferredStyle:UIAlertControllerStyleActionSheet];

    typeof(self) __weak wself = self;

    NSString *sAddTorrentFromWeb = NSLocalizedString(@"Add Torrent from Web", @"Menu action title for adding torrent from the web");


    UIAlertAction *addTorrentFromWeb = [UIAlertAction actionWithTitle:sAddTorrentFromWeb
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) { [wself addTorrentFromWeb]; }];


    [menuActionSheetController addAction:addTorrentFromWeb];

    [menuActionSheetController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Add Torrent from URL", @"Menu action title for adding torrent from the provided URL")
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
        [wself addTorrentFromURL];
    }]];

    [menuActionSheetController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Preferences", @"Menu action title for opening preferences screen")
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_Storyboard" bundle:nil];
        UIViewController *preferencesViewController = [storyboard instantiateViewControllerWithIdentifier:@"pref"];
        [wself showViewController:preferencesViewController sender:preferencesViewController];
    }]];

    [menuActionSheetController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Menu action title for canceling the menu")
                                                                  style:UIAlertActionStyleCancel
                                                                handler:nil]];

    UIPopoverPresentationController *popoverPresentationController = menuActionSheetController.popoverPresentationController;
    popoverPresentationController.barButtonItem = sender;

    [self showViewController:menuActionSheetController sender:menuActionSheetController];
}

- (void)addTorrentFromWeb {
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://lostfilm.tv"]];
    [self showViewController:safariViewController sender:safariViewController];
}

- (void)addTorrentFromURL {
    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Add from magnet" message:@"Please input torrent or magnet" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *data = dialog.textFields.firstObject.text;
        NSString *magnetSubstring = [data substringWithRange:NSMakeRange(0,6)];
        NSLog(@"Magnet substring: %@", magnetSubstring);
        if([magnetSubstring isEqualToString:@"magnet"])
        {
            // add torrent from magnet
            NSError *error = [self.controller addTorrentFromManget:data];
            if (error) {
                NSLog(@"Error adding magnet");
            }
        }
    }];
    [dialog addAction:okAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [dialog addAction:cancelAction];

    [dialog addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.enablesReturnKeyAutomatically = YES;
        textField.keyboardAppearance = UIKeyboardAppearanceDefault;
        textField.keyboardType = UIKeyboardTypeURL;
        textField.returnKeyType = UIReturnKeyDone;
        textField.secureTextEntry = NO;
    }];

    [self showViewController:dialog sender:dialog];
}

@end
