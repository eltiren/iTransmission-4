//
//  Controller.m
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <iTransmission-Swift.h>
#import "Controller.h"
#import "Torrent.h"
#import "Notifications.h"
#import "_TorrentViewController.h"
#import "ALAlertBanner.h"
#import <AVFoundation/AVFoundation.h>
#import <UserNotifications/UserNotifications.h>
#import "libtransmission/transmission.h"
#import "libtransmission/tr-getopt.h"
#import "libtransmission/log.h"
#import "libtransmission/utils.h"
#import "libtransmission/variant.h"
#import "libtransmission/version.h"
#include <stdlib.h> // setenv()

#define APP_NAME "iTrans"

static void
printMessage(int level, const char * name, const char * message, const char * file, int line )
{
    char timestr[64];
    tr_logGetTimeStr (timestr, sizeof (timestr));
}

static void pumpLogMessages()
{
    const tr_log_message * l;
    tr_log_message * list = tr_logGetQueue( );
    
    for( l=list; l!=NULL; l=l->next )
        printMessage(l->level, l->name, l->message, l->file, l->line );
    
    tr_logFreeQueue( list );
}

/*
static void signal_handler(int sig) {
    if (sig == SIGUSR1) {
        NSLog(@"Possibly entering background.");
        [[NSUserDefaults standardUserDefaults] synchronize];
        [(Controller*)[[UIApplication sharedApplication] delegate] updateTorrentHistory];
    }
    return;
}
 */

@interface Controller() <TorrentFetcherDelegate>

@end

@implementation Controller {
    UIWindow *window;
    NSUserDefaults *fDefaults;
    tr_session *fLib;
    NSMutableArray * fTorrents;
    NSMutableArray * fActivities;
    BOOL fPauseOnLaunch;
    BOOL fUpdateInProgress;
    tr_variant settings;
    
    UINavigationController *navController;
    TorrentViewController *torrentViewController;
    NSInteger activityCounter;
    
    NSArray *fInstalledApps;
    
    CGFloat fGlobalSpeedCached[2];
    
    NSTimer *fLogMessageTimer;
    
    UIBackgroundTaskIdentifier backgroundTask;
}

@synthesize window;
@synthesize navController;
@synthesize torrentViewController;
@synthesize activityCounter;
@synthesize logMessageTimer = fLogMessageTimer;
@synthesize installedApps = fInstalledApps;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // story board and LGSideMenu Controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_Storyboard" bundle:nil];
    
    // init torrent view controller
    self.torrentViewController = [storyboard instantiateViewControllerWithIdentifier:@"torrent_view"];
    self.torrentViewController.controller = self;
    
    
    // enable notifications on iOS 9
    [application registerUserNotificationSettings:[UIUserNotificationSettings
                                                   settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|
                                                   UIUserNotificationTypeSound categories:nil]];
    application.applicationIconBadgeNumber = 0;
    
    [self fixDocumentsDirectory];
	[self transmissionInitialize];

    return YES;
}

- (id)infoValueForKey:(NSString *)key
{
    // fetch objects from our bundle based on keys in our Info.plist
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
}

- (void)pumpLogMessages
{
    pumpLogMessages();
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    if ([[url scheme] isEqualToString:@"magnet"]) {
        [self addTorrentFromManget:[url absoluteString]];
        return YES;
    } else {
        [self addTorrentFromURL:[url absoluteString]];
        return YES;
    }
    return NO;
}

- (void)resetToDefaultPreferences
{
    [NSUserDefaults resetStandardUserDefaults];
    fDefaults = [NSUserDefaults standardUserDefaults];
    [fDefaults setBool:YES forKey:@"SpeedLimitAuto"];
    [fDefaults setBool:NO forKey:@"AutoStartDownload"];
    [fDefaults setBool:YES forKey:@"DHTGlobal"];
    [fDefaults setInteger:0 forKey:@"DownloadLimit"];
    [fDefaults setInteger:0 forKey:@"UploadLimit"];
    [fDefaults setBool:NO forKey:@"DownloadLimitEnabled"];
    [fDefaults setBool:NO forKey:@"UploadLimitEnabled"];
    [fDefaults setObject:[[NSFileManager defaultManager] downloadsPath] forKey:@"DownloadFolder"];
    [fDefaults setObject:[[NSFileManager defaultManager] downloadsPath] forKey:@"IncompleteDownloadFolder"];
    [fDefaults setBool:NO forKey:@"UseIncompleteDownloadFolder"];
    [fDefaults setBool:YES forKey:@"LocalPeerDiscoveryGlobal"];
    [fDefaults setInteger:30 forKey:@"PeersTotal"];
    [fDefaults setInteger:20 forKey:@"PeersTorrent"];
    [fDefaults setBool:NO forKey:@"RandomPort"];
    [fDefaults setInteger:30901 forKey:@"BindPort"];
    [fDefaults setInteger:0 forKey:@"PeerSocketTOS"];
    [fDefaults setBool:YES forKey:@"PEXGlobal"];
    [fDefaults setBool:YES forKey:@"NatTraversal"];
    [fDefaults setBool:NO forKey:@"Proxy"];
    [fDefaults setInteger:0 forKey:@"ProxyPort"];
    [fDefaults setFloat:0.0f forKey:@"RatioLimit"];
    [fDefaults setBool:NO forKey:@"RatioCheck"];
    [fDefaults setBool:YES forKey:@"RenamePartialFiles"];
    [fDefaults setBool:NO forKey:@"RPCAuthorize"];
    [fDefaults setBool:NO forKey:@"RPC"];
	[fDefaults setObject:@"" forKey:@"RPCUsername"];
    [fDefaults setObject:@"" forKey:@"RPCPassword"];
	[fDefaults setInteger:9091 forKey:@"RPCPort"];
    [fDefaults setBool:NO forKey:@"RPCUseWhitelist"];
    [fDefaults setBool:NO forKey:@"BackgroundDownloading"];
    [fDefaults setBool:YES forKey:@"UseMicrophone"];
	[fDefaults synchronize];
}

- (void)transmissionInitialize
{
	fDefaults = [NSUserDefaults standardUserDefaults];
    
    //checks for old version speeds of -1
    if ([fDefaults integerForKey: @"UploadLimit"] < 0)
    {
        [fDefaults removeObjectForKey: @"UploadLimit"];
        [fDefaults setBool: NO forKey: @"CheckUpload"];
    }
    if ([fDefaults integerForKey: @"DownloadLimit"] < 0)
    {
        [fDefaults removeObjectForKey: @"DownloadLimit"];
        [fDefaults setBool: NO forKey: @"CheckDownload"];
    }
    
    if (![fDefaults boolForKey:@"NotFirstRun"]) {
        [self resetToDefaultPreferences];
        [fDefaults setBool:YES forKey:@"NotFirstRun"];
    }
    
    tr_variantInitDict(&settings, 41);
    tr_sessionGetDefaultSettings(&settings);
    
    tr_variantDictAddBool(&settings, TR_KEY_alt_speed_enabled, [fDefaults boolForKey: @"SpeedLimit"]);
    
	tr_variantDictAddBool(&settings, TR_KEY_alt_speed_time_enabled, NO);
    
//	tr_variantDictAddBool(&settings, TR_KEY_START, [fDefaults boolForKey: @"AutoStartDownload"]);
	
    tr_variantDictAddInt(&settings, TR_KEY_speed_limit_down, [fDefaults integerForKey: @"DownloadLimit"]);
    tr_variantDictAddBool(&settings, TR_KEY_speed_limit_down_enabled, [fDefaults boolForKey: @"DownloadLimitEnabled"]);
    tr_variantDictAddInt(&settings, TR_KEY_speed_limit_up, [fDefaults integerForKey: @"UploadLimit"]);
    tr_variantDictAddBool(&settings, TR_KEY_speed_limit_up_enabled, [fDefaults boolForKey: @"UploadLimitEnabled"]);
	
    //	if ([fDefaults objectForKey: @"BindAddressIPv4"])
    //		tr_variantDictAddStr(&settings, TR_KEY_BIND_ADDRESS_IPV4, [[fDefaults stringForKey: @"BindAddressIPv4"] UTF8String]);
    //	if ([fDefaults objectForKey: @"BindAddressIPv6"])
    //		tr_variantDictAddStr(&settings, TR_KEY_BIND_ADDRESS_IPV6, [[fDefaults stringForKey: @"BindAddressIPv6"] UTF8String]);
    
	tr_variantDictAddBool(&settings, TR_KEY_blocklist_enabled, [fDefaults boolForKey: @"Blocklist"]);
	tr_variantDictAddBool(&settings, TR_KEY_dht_enabled, [fDefaults boolForKey: @"DHTGlobal"]);
	tr_variantDictAddStr(&settings, TR_KEY_download_dir, [[[NSFileManager defaultManager] downloadsPath] cStringUsingEncoding:NSASCIIStringEncoding]);
	tr_variantDictAddStr(&settings, TR_KEY_incomplete_dir, [[[fDefaults stringForKey: @"IncompleteDownloadFolder"]
																stringByExpandingTildeInPath] UTF8String]);
	tr_variantDictAddBool(&settings, TR_KEY_incomplete_dir_enabled, [fDefaults boolForKey: @"UseIncompleteDownloadFolder"]);

	tr_variantDictAddBool(&settings, TR_KEY_lpd_enabled, [fDefaults boolForKey: @"LocalPeerDiscoveryGlobal"]);
	tr_variantDictAddInt(&settings, TR_KEY_message_level, TR_LOG_DEBUG);
	tr_variantDictAddInt(&settings, TR_KEY_peer_limit_global, [fDefaults integerForKey: @"PeersTotal"]);
	tr_variantDictAddInt(&settings,  TR_KEY_peer_limit_per_torrent, [fDefaults integerForKey: @"PeersTorrent"]);
	
	const BOOL randomPort = [fDefaults boolForKey: @"RandomPort"];
	tr_variantDictAddBool(&settings, TR_KEY_peer_port_random_on_start, randomPort);
	if (!randomPort)
		tr_variantDictAddInt(&settings, TR_KEY_peer_port, [fDefaults integerForKey: @"BindPort"]);
	
	//hidden pref
	if ([fDefaults objectForKey: @"PeerSocketTOS"])
		tr_variantDictAddInt(&settings, TR_KEY_peer_socket_tos, [fDefaults integerForKey: @"PeerSocketTOS"]);
	
    tr_variantDictAddBool(&settings, TR_KEY_pex_enabled, [fDefaults boolForKey: @"PEXGlobal"]);
    tr_variantDictAddBool(&settings, TR_KEY_port_forwarding_enabled, [fDefaults boolForKey: @"NatTraversal"]);
    tr_variantDictAddReal(&settings, TR_KEY_ratio_limit, [fDefaults floatForKey: @"RatioLimit"]);
    tr_variantDictAddBool(&settings, TR_KEY_ratio_limit, [fDefaults boolForKey: @"RatioCheck"]);
    tr_variantDictAddBool(&settings, TR_KEY_rename_partial_files, [fDefaults boolForKey: @"RenamePartialFiles"]);
    tr_variantDictAddBool(&settings, TR_KEY_rpc_authentication_required,  [fDefaults boolForKey: @"RPCAuthorize"]);
    tr_variantDictAddBool(&settings, TR_KEY_rpc_enabled,  [fDefaults boolForKey: @"RPC"]);
    tr_variantDictAddInt(&settings, TR_KEY_rpc_port, [fDefaults integerForKey: @"RPCPort"]);
    tr_variantDictAddStr(&settings, TR_KEY_rpc_username,  [[fDefaults stringForKey: @"RPCUsername"] UTF8String]);
    tr_variantDictAddBool(&settings, TR_KEY_rpc_whitelist_enabled,  [fDefaults boolForKey: @"RPCUseWhitelist"]);
    tr_variantDictAddBool(&settings, TR_KEY_start_added_torrents, [fDefaults boolForKey: @"AutoStartDownload"]);
    tr_variantDictAddBool(&settings, TR_KEY_script_torrent_done_enabled, [fDefaults boolForKey: @"DoneScriptEnabled"]);
    tr_variantDictAddStr(&settings, TR_KEY_script_torrent_done_filename, [[fDefaults stringForKey: @"DoneScriptPath"] UTF8String]);
    tr_variantDictAddBool(&settings, TR_KEY_utp_enabled, [fDefaults boolForKey: @"UTPGlobal"]);
    
    tr_formatter_size_init(1000, [NSLocalizedString(@"KB", "File size - kilobytes") UTF8String],
                           [NSLocalizedString(@"MB", "File size - megabytes") UTF8String],
                           [NSLocalizedString(@"GB", "File size - gigabytes") UTF8String],
                           [NSLocalizedString(@"TB", "File size - terabytes") UTF8String]);
    
    tr_formatter_speed_init(1000,
                            [NSLocalizedString(@"KB/s", "Transfer speed (kilobytes per second)") UTF8String],
                            [NSLocalizedString(@"MB/s", "Transfer speed (megabytes per second)") UTF8String],
                            [NSLocalizedString(@"GB/s", "Transfer speed (gigabytes per second)") UTF8String],
                            [NSLocalizedString(@"TB/s", "Transfer speed (terabytes per second)") UTF8String]); //why not?
    
    tr_formatter_mem_init(1024, [NSLocalizedString(@"KB", "Memory size - kilobytes") UTF8String],
                          [NSLocalizedString(@"MB", "Memory size - megabytes") UTF8String],
                          [NSLocalizedString(@"GB", "Memory size - gigabytes") UTF8String],
                          [NSLocalizedString(@"TB", "Memory size - terabytes") UTF8String]);
	
	fLib = tr_sessionInit([[[NSFileManager defaultManager] configPath] cStringUsingEncoding:NSASCIIStringEncoding], YES, &settings);
	tr_variantFree(&settings);
    
    NSString *webDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"web"];
    if (setenv("TRANSMISSION_WEB_HOME", [webDir cStringUsingEncoding:NSUTF8StringEncoding], 1)) {
        NSLog(@"Failed to set \"TRANSMISSION_WEB_HOME\" environmental variable. ");
    }
	
	fTorrents = [[NSMutableArray alloc] init];	
    fActivities = [[NSMutableArray alloc] init];
    
	fUpdateInProgress = NO;
	
	fPauseOnLaunch = YES;
//    tr_sessionSaveSettings(fLib, [[self configDir] cStringUsingEncoding:NSUTF8StringEncoding], &settings);
    
    [self loadTorrentHistory];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(torrentFinished:) name:@"TorrentFinishedDownloading" object:nil];
    [self postFinishMessage:@"Initialization finished."];
}

- (tr_session*)rawSession
{
    return fLib;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    /*
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    UIApplication  *app = [UIApplication sharedApplication];
    backgroundTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{});
    
    [app endBackgroundTask:backgroundTask];
    backgroundTask = UIBackgroundTaskInvalid;
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self addTorrentsFromDocuments];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[self updateTorrentHistory];
    tr_sessionClose(fLib);
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (BOOL)isSessionActive
{
	return [self isStartingTransferAllowed];
}

- (BOOL)isStartingTransferAllowed
{
	return YES;
}

- (void)postError:(NSString *)err_msg
{
    // TODO: post local notification
    // fix alertbanner getting stuck
    UIApplication *application = [UIApplication sharedApplication];
    UIApplicationState appCurrentState = [application applicationState];
    if(appCurrentState == UIApplicationStateActive)
    {
        ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.window style:ALAlertBannerStyleFailure position:ALAlertBannerPositionUnderNavBar title:err_msg];
        banner.secondsToShow = 3.5f;
        banner.showAnimationDuration = 0.25f;
        banner.hideAnimationDuration = 0.2f;
        [banner show];
    }
}

- (void)postMessage:(NSString*)msg
{
    // TODO: post local notification
    // fix alertbanner getting stuck
    UIApplication *application = [UIApplication sharedApplication];
    UIApplicationState appCurrentState = [application applicationState];
    if(appCurrentState == UIApplicationStateActive)
    {
        ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.window style:ALAlertBannerStyleNotify position:ALAlertBannerPositionUnderNavBar title:msg];
        banner.secondsToShow = 3.5f;
        banner.showAnimationDuration = 0.25f;
        banner.hideAnimationDuration = 0.2f;
        [banner show];
    }
}

- (void)postFinishMessage:(NSString*)msg
{
    // TODO: post local notification
    // fix alertbanner getting stuck
    UIApplication *application = [UIApplication sharedApplication];
    UIApplicationState appCurrentState = [application applicationState];
    if(appCurrentState == UIApplicationStateActive)
    {
        ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.window style:ALAlertBannerStyleSuccess position:ALAlertBannerPositionUnderNavBar title:msg subtitle:msg];
        [banner show];
    }
}

- (CGFloat)globalDownloadSpeed
{
    return fGlobalSpeedCached[0];
}

- (void)updateGlobalSpeed
{
    [fTorrents makeObjectsPerformSelector: @selector(update)];

    CGFloat dlRate = 0.0, ulRate = 0.0;
    for (Torrent * torrent in fTorrents)
    {
        dlRate += [torrent downloadRate];
        ulRate += [torrent uploadRate];
    }
    
    fGlobalSpeedCached[0] = dlRate;
    fGlobalSpeedCached[1] = ulRate;
}

- (CGFloat)globalUploadSpeed
{
    return fGlobalSpeedCached[1];
}

- (void)fixDocumentsDirectory
{
    BOOL isDir, exists;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSLog(@"Using documents directory %@", [[NSFileManager defaultManager] documentsDirectoryPath]);
    
    NSArray *directories = @[
        [fileManager documentsDirectoryPath],
        [fileManager configPath],
        [fileManager torrentsPath],
        [fileManager downloadsPath]
    ];
    
    for (NSString *d in directories) {
        exists = [fileManager fileExistsAtPath:d isDirectory:&isDir];
        if (exists && !isDir) {
            [fileManager removeItemAtPath:d error:nil];
            [fileManager createDirectoryAtPath:d withIntermediateDirectories:YES attributes:nil error:nil];
            continue;
        }
        if (!exists) {
            [fileManager createDirectoryAtPath:d withIntermediateDirectories:YES attributes:nil error:nil];
            continue;
        }
    }
}

- (void)addTorrentsFromDocuments {
    NSFileManager *fileManager = [[NSFileManager alloc] init];

    for (NSString *file in [fileManager contentsOfDirectoryAtPath:[[NSFileManager defaultManager] documentsDirectoryPath] error:nil]) {
            if ([file hasSuffix:@".torrent"]) {
                NSString *tPath = [[NSFileManager defaultManager] randomTorrentPath];
                NSURL *url = [[[NSFileManager defaultManager] documentsDirectoryURL] URLByAppendingPathComponent:file];
                [fileManager copyItemAtURL:url toURL:[NSURL fileURLWithPath:tPath] error:nil];

                if ([self openFile:tPath addType:ADD_URL forcePath:nil]) {
                    [fileManager removeItemAtURL:url error:nil];
                }
            } else {
                NSLog(@"%@", file);
            }
        }
}


- (void)updateTorrentHistory
{    
    NSMutableArray * history = [NSMutableArray arrayWithCapacity: [fTorrents count]];
    
    for (Torrent * torrent in fTorrents)
        [history addObject: [torrent history]];
    
    [history writeToFile: [[NSFileManager defaultManager] transferPlistPath] atomically: YES];
    
}

- (void)loadTorrentHistory
{
    NSArray * history = [NSArray arrayWithContentsOfFile: [[NSFileManager defaultManager] transferPlistPath]];
        
    if (!history)
    {
        //old version saved transfer info in prefs file
        if ((history = [fDefaults arrayForKey: @"History"]))
            [fDefaults removeObjectForKey: @"History"];
    }
    
    if (history)
    {
        for (NSDictionary * historyItem in history)
        {
            Torrent * torrent;
            if ((torrent = [[Torrent alloc] initWithHistory: historyItem lib: fLib forcePause:NO]))
            {
                [torrent changeDownloadFolderBeforeUsing:[[NSFileManager defaultManager] downloadsPath]];
                [fTorrents addObject: torrent];
            }
        }
    }
}

- (NSInteger)torrentsCount
{
    return (NSInteger)[fTorrents count];
}

- (Torrent*)torrentAtIndex:(NSInteger)index
{
    return [fTorrents objectAtIndex:(NSUInteger)index];
}

- (void)torrentFetcher:(TorrentFetcher *)fetcher fetchedTorrentContent:(NSData *)data fromURL:(NSString *)url
{
    NSError *error = nil;
    [self decreaseActivityCounter];
    NSString *path = [[NSFileManager defaultManager] randomTorrentPath];
    [data writeToFile:path options:0 error:&error];
    error = [self openFile:path addType:ADD_URL forcePath:nil];
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"Add from URL" message:[NSString stringWithFormat:@"Adding from %@ failed. %@", url, [error localizedDescription]]  delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
    [fActivities removeObject:fetcher];
}

- (void)torrentFetcher:(TorrentFetcher *)fetcher failedToFetchFromURL:(NSString *)url withError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add torrent" message:[NSString stringWithFormat:@"Failed to fetch torrent URL: \"%@\". \nError: %@", url, [error localizedDescription]] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
    [fActivities removeObject:fetcher];    
    [self decreaseActivityCounter];
}

- (void)removeTorrents:(NSArray*)torrents trashData:(BOOL)trashData
{
	for (Torrent *torrent in torrents) {
		[torrent stopTransfer];
		[torrent closeRemoveTorrent:trashData];
		[fTorrents removeObject:torrent];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:NotificationTorrentsRemoved object:self userInfo:nil];
}

- (void)removeTorrents:(NSArray *)torrents trashData:(BOOL)trashData afterDelay:(NSTimeInterval)delay
{
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:torrents forKey:@"torrents"];
    [options setObject:[NSNumber numberWithBool:trashData] forKey:@"trashData"];
    [self performSelector:@selector(_removeTorrentsDelayed:) withObject:options afterDelay:delay];
}

- (void)_removeTorrentsDelayed:(NSDictionary*)options
{
    BOOL trashData = [[options objectForKey:@"trashData"] boolValue];
    NSArray *torrents = [options objectForKey:@"torrents"];
    [self removeTorrents:torrents trashData:trashData];
}

- (void)addTorrentFromURL:(NSString*)url
{
    TorrentFetcher *fetcher = [[TorrentFetcher alloc] initWithUrlString:url delegate:self];
    [fActivities addObject:fetcher];
    [self increaseActivityCounter];
}

- (NSError*)addTorrentFromManget:(NSString *)magnet
{
    NSError *err = nil;
    
    tr_torrent * duplicateTorrent;
    if ((duplicateTorrent = tr_torrentFindFromMagnetLink(fLib, [magnet UTF8String])))
    {
        const tr_info * info = tr_torrentInfo(duplicateTorrent);
        NSString * name = (info != NULL && info->name != NULL) ? [NSString stringWithUTF8String: info->name] : nil;
        err = [[NSError alloc] initWithDomain:@"Controller" code:1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Torrent %@ already exists. ", name] forKey:NSLocalizedDescriptionKey]];
        return err;
    }
    
    //determine download location
    NSString * location = nil;
    if ([fDefaults boolForKey: @"DownloadLocationConstant"])
        location = [[fDefaults stringForKey: @"DownloadFolder"] stringByExpandingTildeInPath];
    
    Torrent * torrent;
    if (!(torrent = [[Torrent alloc] initWithMagnetAddress: magnet location: location lib: fLib]))
    {
        err = [[NSError alloc] initWithDomain:@"Controller" code:1 userInfo:[NSDictionary dictionaryWithObject:@"The magnet supplied is invalid." forKey:NSLocalizedDescriptionKey]];
        return err;
    }
    
    [torrent setWaitToStart: [fDefaults boolForKey: @"AutoStartDownload"]];
    [torrent update];
    [fTorrents addObject: torrent];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewTorrentAdded object:self userInfo:nil];
    [self updateTorrentHistory];
    return nil;
}

- (NSError*)openFile:(NSString*)file addType:(AddType)type forcePath:(NSString *)path
{
    NSError *error = nil;
    tr_ctor * ctor = tr_ctorNew(fLib);
    tr_ctorSetMetainfoFromFile(ctor, [file UTF8String]);
    
    tr_info info;
    const tr_parse_result result = tr_torrentParse(ctor, &info);
    tr_ctorFree(ctor);
    
    // TODO: instead of alert view, print errors in activities view. 
    if (result != TR_PARSE_OK)
    {
        if (result == TR_PARSE_DUPLICATE) {
            error = [[NSError alloc] initWithDomain:@"Controller" code:1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Torrent %s already exists. ", info.name] forKey:NSLocalizedDescriptionKey]];
        }
        else if (result == TR_PARSE_ERR)
        {
            error = [[NSError alloc] initWithDomain:@"Controller" code:1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Invalid torrent file. "] forKey:NSLocalizedDescriptionKey]];
        }
        tr_metainfoFree(&info);
        return error;
    }
    
    
    Torrent * torrent;
    if (!(torrent = [[Torrent alloc] initWithPath:file location: [path stringByExpandingTildeInPath] deleteTorrentFile: NO lib: fLib])) {
        error = [[NSError alloc] initWithDomain:@"Controller" code:1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Unknown error. "] forKey:NSLocalizedDescriptionKey]];
        return error;
    }
    
    //verify the data right away if it was newly created
    if (type == ADD_CREATED)
        [torrent resetCache];
    
    [torrent setWaitToStart: [fDefaults boolForKey: @"AutoStartDownload"]];
    [torrent update];
    [fTorrents addObject: torrent];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewTorrentAdded object:self userInfo:nil];
    [self updateTorrentHistory];
    return nil;
}

- (void)increaseActivityCounter
{
    activityCounter += 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationActivityCounterChanged object:self userInfo:nil];
}

- (void)decreaseActivityCounter
{
    if (activityCounter == 0) return;
    activityCounter -= 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationActivityCounterChanged object:self userInfo:nil];
}


- (void)setGlobalUploadSpeedLimit:(NSInteger)kbytes
{
    [fDefaults setInteger:kbytes forKey:@"UploadLimit"];
    [fDefaults synchronize];
    tr_sessionSetSpeedLimit_KBps(fLib, TR_UP, (unsigned int)[fDefaults integerForKey:@"UploadLimit"]);
    NSLog(@"tr_sessionIsSpeedLimited(TR_UP): %d", tr_sessionIsSpeedLimited(fLib, TR_UP));
    NSLog(@"tr_sessionGetSpeedLimit_KBps(TR_UP): %d", tr_sessionGetSpeedLimit_KBps(fLib, TR_UP));
}

- (void)setGlobalDownloadSpeedLimit:(NSInteger)kbytes
{
    [fDefaults setInteger:kbytes forKey:@"DownloadLimit"];
    [fDefaults synchronize];
    tr_sessionSetSpeedLimit_KBps(fLib, TR_DOWN, (unsigned int)[fDefaults integerForKey:@"DownloadLimit"]);
    NSLog(@"tr_sessionIsSpeedLimited(TR_DOWN): %d", tr_sessionIsSpeedLimited(fLib, TR_DOWN));
    NSLog(@"tr_sessionGetSpeedLimit_KBps(TR_DOWN): %d", tr_sessionGetSpeedLimit_KBps(fLib, TR_DOWN));
}

- (void)setGlobalUploadSpeedLimitEnabled:(BOOL)enabled
{
    [fDefaults setBool:enabled forKey:@"UploadLimitEnabled"];
    [fDefaults synchronize];
    tr_sessionLimitSpeed(fLib, TR_UP, [fDefaults boolForKey:@"UploadLimitEnabled"]);
}

- (void)setGlobalDownloadSpeedLimitEnabled:(BOOL)enabled
{
    [fDefaults setBool:enabled forKey:@"DownloadLimitEnabled"];
    [fDefaults synchronize];
    tr_sessionLimitSpeed(fLib, TR_DOWN, [fDefaults boolForKey:@"DownloadLimitEnabled"]);
}

- (NSInteger)globalDownloadSpeedLimit
{
    return tr_sessionGetSpeedLimit_KBps(fLib, TR_DOWN);
}

- (NSInteger)globalUploadSpeedLimit
{
    return tr_sessionGetSpeedLimit_KBps(fLib, TR_UP);
}

- (void)setGlobalMaximumConnections:(uint16_t)c
{
    [fDefaults setInteger:c forKey:@"PeersTotal"];
    [fDefaults synchronize];
    tr_sessionSetPeerLimit(fLib, c);
}

- (NSInteger)globalMaximumConnections
{
    return tr_sessionGetPeerLimit(fLib);
}

- (void)setConnectionsPerTorrent:(uint16_t)c
{
    [fDefaults setInteger:c forKey:@"PeersTorrent"];
    [fDefaults synchronize];
    tr_sessionSetPeerLimitPerTorrent(fLib, c);
}

- (NSInteger)connectionsPerTorrent
{
    return tr_sessionGetPeerLimitPerTorrent(fLib);
}

- (BOOL)globalUploadSpeedLimitEnabled
{
    return tr_sessionIsSpeedLimited(fLib, TR_UP);
}

- (BOOL)globalDownloadSpeedLimitEnabled
{
    return tr_sessionIsSpeedLimited(fLib, TR_DOWN);
}

- (void)torrentFinished:(NSNotification*)notif {
    [self postBGNotif:[NSString stringWithFormat:NSLocalizedString(@"%@ download finished.", nil), [(Torrent *)[notif object] name]]];
    [self postFinishMessage:[NSString stringWithFormat:NSLocalizedString(@"%@ download finished.", nil), [(Torrent *)[notif object] name]]];
}

- (void)postBGNotif:(NSString *)message {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
		UILocalNotification *localNotif = [[UILocalNotification alloc] init];
		if (localNotif == nil)
			return;
		localNotif.fireDate = nil;//Immediately
		
		// Notification details
		localNotif.alertBody = message;
		// Set the action button
		localNotif.alertAction = @"View";
		
		localNotif.soundName = UILocalNotificationDefaultSoundName;
		localNotif.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber]+1;
		
		// Specify custom data for the notification
		//NSDictionary *infoDict = [NSDictionary dictionaryWithObject:file forKey:@"Downloaded"];
		//localNotif.userInfo = infoDict;
		
		// Schedule the notification
		[[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        
        NSLog(@"Notification should've fired");
	}
} 

@end
