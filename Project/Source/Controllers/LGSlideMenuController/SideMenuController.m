//
//  SideMenuController.m
//  iTransmission
//
//  Created by Beecher Adams on 5/2/17.
//
//

#import "SideMenuController.h"
#import "LeftMenuController.h"

@implementation SideMenuController

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)setTransmission:(Controller *)transmission torrentView:(TorrentViewController *)torrentView
{
    LeftMenuController *menu = (LeftMenuController *)self.leftViewController;
    [menu setData:transmission transView:torrentView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // init LG Side Menu Controller
    UIColor *greenCoverColor = [UIColor colorWithRed:0.0 green:0.1 blue:0.0 alpha:0.3];
    
    self.leftViewPresentationStyle = LGSideMenuPresentationStyleScaleFromBig;
    self.rootViewCoverColorForLeftView = greenCoverColor;
}


- (void)leftViewWillLayoutSubviewsWithSize:(CGSize)size {
    [super leftViewWillLayoutSubviewsWithSize:size];
    
    if (!self.isLeftViewStatusBarHidden) {
        self.leftView.frame = CGRectMake(0.0, 20.0, size.width, size.height-20.0);
    }
}

- (void)rightViewWillLayoutSubviewsWithSize:(CGSize)size {
    [super rightViewWillLayoutSubviewsWithSize:size];
    
    if (!self.isRightViewStatusBarHidden ||
        (self.rightViewAlwaysVisibleOptions & LGSideMenuAlwaysVisibleOnPadLandscape &&
         UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&
         UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation))) {
            self.rightView.frame = CGRectMake(0.0, 20.0, size.width, size.height-20.0);
        }
}

@end
