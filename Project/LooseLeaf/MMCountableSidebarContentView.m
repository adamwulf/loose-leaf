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
#import "MMCountableSidebarButton.h"
#import <JotUI/JotUI.h>
#import "Constants.h"

#define kColumnSideMargin 10.0
#define kColumnTopMargin 10.0

typedef struct RowOfViewsInSidebar {
    CGFloat topY;
    CGFloat height;
} RowOfViewsInSidebar;


@implementation MMCountableSidebarContentView {
    NSInteger columnCount;
    MMTrashButton* trashButton;

    UIView* deleteAllScrapsWarningView;
    UILabel* deleteCountLabel;

    int countOfStoredRowData;
    RowOfViewsInSidebar* rowData;
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
    CheckMainThread;

    // determine how many rows of scraps that we'll need
    NSArray* allViews = [self.delegate viewsInSidebar];
    int rowCount = ceilf((float)[allViews count] / self.columnCount);
    CGFloat maxDimOfView = (self.bounds.size.width - kColumnSideMargin) / self.columnCount;

    // make sure we have data to store the attributes per row
    if (rowCount > countOfStoredRowData) {
        if (rowData) {
            free(rowData);
        }
        countOfStoredRowData = rowCount;
        rowData = malloc(countOfStoredRowData * sizeof(RowOfViewsInSidebar));
    }

    // calculate the height we'll need for each
    // scrap in the sidebar as we scroll
    CGFloat currentYOffset = 5 * kColumnTopMargin;
    for (int row = 0; row < rowCount; row++) {
        // determine the index and scrap objects
        CGFloat maxHeightOfViewsInRow = 0;
        for (int index = row * (int)self.columnCount; index < row * self.columnCount + self.columnCount; index++) {
            if (index < [allViews count]) {
                UIView<MMUUIDView>* currentView = [allViews objectAtIndex:index];
                CGSize sizeOfCellForView = [[self.delegate sidebarButtonClass] sizeOfRowForView:currentView forWidth:maxDimOfView];
                CGFloat heightOfCurrView = sizeOfCellForView.height + kColumnTopMargin;
                if (heightOfCurrView > maxHeightOfViewsInRow) {
                    maxHeightOfViewsInRow = heightOfCurrView;
                }
            }
        }
        rowData[row].height = maxHeightOfViewsInRow;
        rowData[row].topY = currentYOffset;
        currentYOffset += maxHeightOfViewsInRow;
    }

    // set our content offset and make sure it's still valid
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, [self contentHeight]);
    if (scrollView.contentOffset.y + scrollView.bounds.size.height > [self contentHeight]) {
        CGFloat newOffset = [self contentHeight] - scrollView.bounds.size.height;
        if (newOffset < 0)
            newOffset = 0;
        scrollView.contentOffset = CGPointMake(0, newOffset);
    }

    if (!trashButton) {
        trashButton = [[MMTrashButton alloc] initWithFrame:CGRectMake(0, 0, kHeightOfImportTypeButton, kHeightOfImportTypeButton)];
        [trashButton addTarget:self action:@selector(tappedOnTrashButton:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:trashButton];
    }

    trashButton.center = CGPointMake(CGRectGetWidth(scrollView.bounds) / 2, scrollView.contentSize.height - 50);

    [self scrollViewDidScroll:scrollView];
}

- (void)viewDidHide {
    for (MMCountableSidebarButton* subview in [[scrollView subviews] copy]) {
        if ([subview isKindOfClass:[self.delegate sidebarButtonClass]]) {
            [subview removeFromSuperview];
        }
    }
}

#pragma mark - Actions

- (void)tappedOnViewButton:(MMCountableSidebarButton*)button {
    [self.delegate didTapOnViewFromMenu:button.view withPreferredProperties:nil below:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView*)_scrollView {
    CheckMainThread;
    // just bail if we dont have any scraps
    if (!countOfStoredRowData)
        return;

    // determine the variables that will affect
    // our layout
    NSArray* allViews = [self.delegate viewsInSidebar];
    CGFloat sizeOfView = (self.bounds.size.width - kColumnSideMargin) / self.columnCount;
    int row = [self rowForYOffset:scrollView.contentOffset.y];
    int maxRow = [self rowForYOffset:scrollView.contentOffset.y + scrollView.bounds.size.height] + 1;

    // very basic for now. just remove all old scraps
    NSInteger minVisibleRow = NSIntegerMax;
    NSInteger maxVisibleRow = NSIntegerMin;
    for (MMCountableSidebarButton* subview in [[scrollView subviews] copy]) {
        if ([subview isKindOfClass:[self.delegate sidebarButtonClass]]) {
            if (subview.rowNumber < row || subview.rowNumber > maxRow) {
                [[self delegate] unloadCachedPreviewForView:subview.view];
                [subview removeFromSuperview];
            } else if (subview.rowNumber < minVisibleRow) {
                minVisibleRow = subview.rowNumber;
            } else if (subview.rowNumber > maxVisibleRow) {
                maxVisibleRow = subview.rowNumber;
            }
        }
    }

    while (row < countOfStoredRowData && rowData[row].topY < scrollView.contentOffset.y + scrollView.bounds.size.height) {
        // add views while we have some and while they're visible
        // determine the index and scrap objects
        CGFloat maxHeightOfViewsInRow = 0;
        NSMutableArray* currRow = [NSMutableArray array];
        if (row < minVisibleRow || row > maxVisibleRow) {
            for (int index = row * (int)self.columnCount; index < row * self.columnCount + self.columnCount; index++) {
                if (index < [allViews count]) {
                    UIView<MMUUIDView>* currentView = [allViews objectAtIndex:index];
                    // place the left scrap. it should have 10 px left margin
                    // (left margin already accounted for with our bounds)
                    // and 10px in the middle between it at the right
                    CGFloat x = (index - row * self.columnCount) * (sizeOfView + kColumnSideMargin);
                    MMCountableSidebarButton* leftViewButton = [[[self.delegate sidebarButtonClass] alloc] initWithFrame:CGRectMake(x, rowData[row].topY, sizeOfView, sizeOfView)];
                    leftViewButton.rowNumber = row;
                    [leftViewButton addTarget:self action:@selector(tappedOnViewButton:) forControlEvents:UIControlEventTouchUpInside];
                    leftViewButton.view = currentView;
                    [[self delegate] loadCachedPreviewForView:currentView];
                    [scrollView addSubview:leftViewButton];
                    CGFloat heightOfCurrView = leftViewButton.bounds.size.height + kColumnTopMargin;
                    if (heightOfCurrView > maxHeightOfViewsInRow) {
                        maxHeightOfViewsInRow = heightOfCurrView;
                    }
                    [currRow addObject:leftViewButton];
                }
            }
            // center row items vertically
            for (MMCountableSidebarButton* button in currRow) {
                CGRect fr = button.frame;
                fr.origin.y += (maxHeightOfViewsInRow - fr.size.height) / 2;
                button.frame = fr;
            }
        }
        row++;
    }
}

#pragma mark - Private

- (CGFloat)contentHeight {
    if (rowData) {
        RowOfViewsInSidebar lastRow = rowData[countOfStoredRowData - 1];
        return lastRow.topY + lastRow.height + 4 * kColumnTopMargin + 100; // add 100 for our trash button
    }
    return 0;
}

- (int)rowForYOffset:(CGFloat)yOffset {
    if (!countOfStoredRowData)
        return 0;
    if (yOffset < 0)
        return 0;
    // first, let's take our best guess
    // at which row is showing:
    CGFloat averageRowHeight = [self contentHeight] / countOfStoredRowData;
    int probableRow = floorf(yOffset / averageRowHeight);

    while (rowData[probableRow].topY > yOffset) {
        probableRow--;
    }
    while (rowData[probableRow].topY + rowData[probableRow].height < yOffset) {
        probableRow++;
    }
    return probableRow < 0 ? 0 : probableRow;
}

@end
