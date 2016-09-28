//
//  MMCountableSidebarContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/27/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMCountableSidebarContentView.h"
#import "MMCountableSidebarContainerView.h"
#import "MMTrashButton.h"
#import "UIImage+MMColor.h"
#import "MMRotationManager.h"
#import "MMAppDelegate.h"
#import "MMPresentationWindow.h"
#import "Constants.h"


@implementation MMCountableSidebarContentView {
    NSInteger columnCount;
    MMTrashButton* trashButton;

    UIView* deleteAllScrapsWarningView;
    UILabel* deleteCountLabel;
}

@synthesize delegate;
@synthesize columnCount;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.opaque = NO;
        scrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.contentSize = CGSizeMake(self.bounds.size.width, 500);
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(6, 0, 6, 0);
        scrollView.alwaysBounceVertical = YES;
        scrollView.delegate = self;
        [self addSubview:scrollView];

        deleteAllScrapsWarningView = [[UIView alloc] initWithFrame:CGRectSquare(CGRectGetWidth(self.bounds))];

        deleteCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds) * 4 / 5, 100)];
        [deleteCountLabel setNumberOfLines:2];
        [deleteCountLabel setTextColor:[UIColor whiteColor]];
        [deleteCountLabel setFont:[UIFont systemFontOfSize:24]];
        [deleteCountLabel setTextAlignment:NSTextAlignmentCenter];
        [deleteCountLabel setText:@"15 scraps have been deleted."];

        UIButton* undoDeleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds) * 4 / 5, 50)];
        [undoDeleteButton addTarget:self action:@selector(undoDeleteAllScraps:) forControlEvents:UIControlEventTouchUpInside];
        [undoDeleteButton setTitle:@"Undo" forState:UIControlStateNormal];
        [undoDeleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [undoDeleteButton setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithWhite:1 alpha:.5]] forState:UIControlStateNormal];
        [undoDeleteButton setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithWhite:1 alpha:.7]] forState:UIControlStateHighlighted];
        [undoDeleteButton setClipsToBounds:YES];
        [[undoDeleteButton layer] setBorderColor:[[UIColor colorWithWhite:0 alpha:.6] CGColor]];
        [[undoDeleteButton layer] setBorderWidth:2];
        [[undoDeleteButton layer] setCornerRadius:8];

        CGFloat midpoint = CGRectGetWidth(self.bounds) / 2;

        [deleteAllScrapsWarningView addSubview:undoDeleteButton];
        undoDeleteButton.center = CGPointMake(midpoint, midpoint + 60);

        [deleteCountLabel sizeToFit];
        deleteCountLabel.center = CGPointMake(midpoint, midpoint - 60);
        [deleteAllScrapsWarningView addSubview:deleteCountLabel];

        CGPoint messageLocation = CGRectGetMidPoint(self.bounds);
        messageLocation.y -= 130;
        deleteAllScrapsWarningView.center = messageLocation;
        [self addSubview:deleteAllScrapsWarningView];

        columnCount = 2;

        // for clarity
        self.clipsToBounds = YES;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (NSArray*)itemViews {
    return [[scrollView subviews] copy];
}

- (void)setRotation:(CGFloat)radians {
    [trashButton setRotation:radians];
    [trashButton setTransform:CGAffineTransformMakeRotation(radians)];
}

- (void)didRotateToIdealOrientation:(UIInterfaceOrientation)orientation {
    if ([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationPortrait) {
        deleteAllScrapsWarningView.transform = CGAffineTransformIdentity;
    } else if ([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationLandscapeLeft) {
        deleteAllScrapsWarningView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    } else if ([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationLandscapeRight) {
        deleteAllScrapsWarningView.transform = CGAffineTransformMakeRotation(M_PI_2);
    } else {
        deleteAllScrapsWarningView.transform = CGAffineTransformMakeRotation(M_PI);
    }
}

- (void)setColumnCount:(NSInteger)_columnCount {
    columnCount = _columnCount;
    if ([self.delegate isVisible]) {
        [self prepareContentView];
    }
}

- (void)viewWillShow {
    scrollView.alpha = 1;
    deleteAllScrapsWarningView.alpha = 0;
}

- (void)viewWillHide {
    if ([deleteAllScrapsWarningView alpha] == 1) {
        // if the undo delete-all option is still showing,
        // then the user doesn't want to undo deleting
        // all scraps, so tell our delegate to commit to
        // deleting all scraps
        [self.delegate deleteAllViewsFromSidebar];
    }
}

- (void)flashScrollIndicators {
    [scrollView flashScrollIndicators];
}

- (void)tappedOnTrashButton:(MMTrashButton*)button {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete All Scraps" message:@"Do you want to delete all scraps from the sidebar?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* _Nonnull action) {
        deleteCountLabel.frame = CGRectFromSize(CGSizeMake(CGRectGetWidth(self.bounds) * 4 / 5, 100));
        [deleteCountLabel setText:[NSString stringWithFormat:@"%ld scraps have been deleted.", (unsigned long)[self.delegate.viewsInSidebar count]]];
        [deleteCountLabel sizeToFit];
        deleteCountLabel.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetWidth(self.bounds) / 2 - 60);

        deleteAllScrapsWarningView.alpha = 1;
        scrollView.alpha = 0;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    MMPresentationWindow* presentationWindow = [(MMAppDelegate*)[[UIApplication sharedApplication] delegate] presentationWindow];
    [[presentationWindow rootViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)undoDeleteAllScraps:(UIButton*)button {
    scrollView.alpha = 1;
    deleteAllScrapsWarningView.alpha = 0;
}

#pragma mark - Subclasses

- (void)prepareContentView {
    if (!trashButton) {
        trashButton = [[MMTrashButton alloc] initWithFrame:CGRectMake(0, 0, kHeightOfImportTypeButton, kHeightOfImportTypeButton)];
        [trashButton addTarget:self action:@selector(tappedOnTrashButton:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:trashButton];
    }

    trashButton.center = CGPointMake(CGRectGetWidth(scrollView.bounds) / 2, scrollView.contentSize.height - 50);
}

- (void)viewDidHide {
    @throw kAbstractMethodException;
}

@end
