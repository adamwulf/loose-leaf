//
//  SYUnitTestController.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 22/08/12.
//
//

#import "SYUnitTestController.h"
#import <TouchShape/TouchShape.h>
#import "SYUnitPreview.h"
#import "SYTableBase.h"

@interface SYUnitTestController () {

    NSMutableArray *pfObjects;
    
}

@end


@implementation SYUnitTestController

@synthesize unitTestCell;

- (void) awakeFromNib
{
    // Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveFromNotification:) name:@"saveListPoints" object:nil];
    
}// awakeFromNib


- (void) dealloc
{
    pfObjects = nil;
    
    myTableView = nil;
    closeButton = nil;
    
}// dealloc


#pragma mark - Notifications Methods


- (void) saveFromNotification:(NSNotification *) note
{
    NSDictionary *d = [note userInfo];
    
    NSString *name = [d valueForKey:@"name"];
    NSArray *allpoints = [d valueForKey:@"allPoints"];
    
    [self saveListPoints:allpoints withName:name];
    
}// saveFromNotification


#pragma mark - Save/Load Operations

-(void) importPointsStored:(PFObject *) pfObject
{    
    // List point convert
    NSMutableArray *listPoints = [NSMutableArray array];
    NSMutableArray *listPointStored = [pfObject objectForKey:@"allPoints"];
    for (NSDictionary *dictPoint in listPointStored) {
        CGPoint point = CGPointMake([[dictPoint valueForKey:@"x"]floatValue], [[dictPoint valueForKey:@"y"]floatValue]);
        [listPoints addObject:[NSValue valueWithCGPoint:point]];
    }
    
    [_delegate importCase:listPoints];

}// importPointsStored


- (void) saveListPoints:(NSArray *) allPoints withName:(NSString *) name
{
    // Convert NSValue Array in NSDictionary Array
    // because PFObject doesn't work with NSValue
    NSMutableArray *listPointToStore = [NSMutableArray array];
    for (NSValue *pointValue in allPoints) {
        NSDictionary *dictPoint = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:[pointValue CGPointValue].x], @"x",
                                                                             [NSNumber numberWithFloat:[pointValue CGPointValue].y], @"y", nil];
        [listPointToStore addObject:dictPoint];
    }
        
    PFObject *testObject = [PFObject objectWithClassName:@"ListPoints"];
    [testObject setObject:name forKey:@"name"];
    [testObject setObject:listPointToStore forKey:@"allPoints"];
    [testObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
            [self updateListPointStored];
        else {
            // Avisa del error obtenido
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[error domain] capitalizedString]
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"Accept"
                                                  otherButtonTitles:nil];
            [alert show];

        }
    }];
    
}// saveListPoints


- (void) updateListPointStored
{
    PFQuery *query = [PFQuery queryWithClassName:@"ListPoints"];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            pfObjects = [[NSMutableArray alloc]initWithArray:objects];
            [myTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            pfObjects = nil;
        }
    }];
    
}// updateListPointStored


#pragma mark - Other Table Methods

- (IBAction) switchShowTable:(id)sender
{
    if ([tableBase isHidden]) {
        [tableBase setHidden:NO];
        [UIView animateWithDuration:0.2 animations:^{
            [tableBase setAlpha:1.0];
        }];
    }
    else {
        [UIView animateWithDuration:0.2 animations:^{
            [tableBase setAlpha:.0];
        }completion:^(BOOL finished){
            [tableBase setHidden:YES];
        }];
    }
    
}// switchShowTable


#pragma mark - UITableViewDelegate Protocol

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Data
    PFObject *pfObject = [pfObjects objectAtIndex:indexPath.row];
    [self importPointsStored:pfObject];
    
}// tableView:didSelectRowAtIndexPath:


- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete from server
        PFObject *testObject = [pfObjects objectAtIndex:indexPath.row];
        [testObject deleteInBackground];

        // Delete from tableview
        [pfObjects removeObject:testObject];
        [tableView reloadData];
        
        // If it's the last case, close tableview
        if ([pfObjects count] == 0)
            [self switchShowTable:nil];
    }
    
}// tableView:commitEditingStyle:forRowAtIndexPath:


- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
    
}// tableView:editingStyleForRowAtIndexPath:


- (void) tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // Take the preview view from that cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    SYUnitPreview *preview = (SYUnitPreview *)[cell viewWithTag:3];
    
    // Hide preview view
    [UIView animateWithDuration:0.2 animations:^{
        [preview setAlpha:.0];
    }];
    
    // Hide close button background
    [closeButton setHidden:YES];
    
    return;
    
}// tableView:willBeginEditingRowAtIndexPath:


- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // Take the preview view from that cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    SYUnitPreview *preview = (SYUnitPreview *)[cell viewWithTag:3];
    
    // Show preview view
    [UIView animateWithDuration:0.2 animations:^{
        [preview setAlpha:1.0];
    }completion:^(BOOL finished){
        // Show close button background
        [closeButton setHidden:NO];
    }];
    
}// tableView:didEndEditingRowAtIndexPath:


#pragma mark - UITableViewDataSource Protocol

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}// numberOfSectionsInTableView:


- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
    
}// tableView:titleForHeaderInSection:


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [pfObjects count];
    
}// tableView:numberOfRowsInSection:


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"TestTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"UnitTestCell" owner:self options:nil];
        cell = unitTestCell;
        self.unitTestCell = nil;
    }
    
    // Data
    PFObject *pfObject = [pfObjects objectAtIndex:indexPath.row];
    NSArray *list = [pfObject objectForKey:@"allPoints"];

    // Day
    UILabel *day = (UILabel *)[cell viewWithTag:1];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    day.text = [dateFormatter stringFromDate:[pfObject createdAt]];
    
    // Month
    UILabel *month = (UILabel *)[cell viewWithTag:2];
    [dateFormatter setDateFormat:@"MMM"];
    month.text = [[dateFormatter stringFromDate:[pfObject createdAt]]uppercaseString];

    // Preview
    SYUnitPreview *preview = (SYUnitPreview *)[cell viewWithTag:3];
    [preview setPoints:list];
    [preview setAlpha:1.0];
    [preview setNeedsDisplay];

    // Name
    UILabel *name = (UILabel *)[cell viewWithTag:4];
    name.text = [[pfObject objectForKey:@"name"]capitalizedString];

    // Number of points
    UILabel *points = (UILabel *)[cell viewWithTag:5];
    points.text = [NSString stringWithFormat:@"%u points", [list count]];
    
    return cell;
    
}// tableView:cellForRowAtIndexPath:


@end
