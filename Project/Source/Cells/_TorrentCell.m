//
//  TorrentCell.m
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <iTransmission-Swift.h>
#import "_TorrentCell.h"
#import "PDColoredProgressView.h"

@implementation _TorrentCell

@synthesize nameLabel;
@synthesize upperDetailLabel;
@synthesize lowerDetailLabel;
@synthesize progressView;
@synthesize controlButton;


- (void)setProgress:(float)progress
{
    [self.progressView setProgress:progress];
    [self setNeedsDisplay];
}

- (IBAction)pausedPressed:(id)sender
{

}

@end
