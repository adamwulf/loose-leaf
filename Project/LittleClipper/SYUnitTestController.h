//
//  SYUnitTestController.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 22/08/12.
//
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"


@protocol SYUnitTestDelegate <NSObject>

- (void) importCase:(NSArray *) allPoints;

@end


@class TCViewController;
@class SYTableBase;

@interface SYUnitTestController : NSObject <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UITableView *myTableView;
    IBOutlet UIButton *closeButton;
    IBOutlet SYTableBase *tableBase;
    
}

@property (nonatomic, assign) IBOutlet UITableViewCell *unitTestCell;
@property (nonatomic, assign) IBOutlet id<SYUnitTestDelegate> delegate;

// Save/Load Operations
- (void) importPointsStored:(PFObject *) listPointStored;
- (void) saveListPoints:(NSArray *) allPoints withName:(NSString *) name;
- (void) updateListPointStored;

// Show Table
- (IBAction) switchShowTable:(id)sender;

@end
