//
//  PaintingSampleViewController.m
//  PaintingSample
//
//  Created by Sean Christmann on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaintingSampleViewController.h"
#import "PaintView.h"
#import "NSThread+BlockAdditions.h"

@implementation PaintingSampleViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    // setup container for other views
    UIView* container = [[UIView alloc] initWithFrame:self.view.bounds];
    UIView* otherviews = [[UIView alloc] initWithFrame:self.view.bounds];
    UIImageView* mars = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mars.jpeg"]];
    [container addSubview:otherviews];
    [otherviews addSubview:mars];
    
    //
    // create the paint view, clear by default
    PaintView *paint = [[PaintView alloc] initWithFrame:self.view.bounds];
    [container addSubview:paint];
    [self.view addSubview:container];
    [paint release];
    
    [NSThread performBlockInBackground:^{
        //
        // create the background image to put behind
        // the paint view
        UIGraphicsBeginImageContextWithOptions(otherviews.bounds.size, otherviews.opaque, 0.0);
        [otherviews.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [NSThread performBlockOnMainThread:^{
            [paint setBackgroundColor:[UIColor colorWithPatternImage:snapshot]];
        }];
    }];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
