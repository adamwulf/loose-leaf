/**
 * Copyright 2014 Facebook, Inc.
 *
 * You are hereby granted a non-exclusive, worldwide, royalty-free license to
 * use, copy, modify, and distribute this software in source code or binary
 * form for use in connection with the web and mobile services and APIs
 * provided by Facebook.
 *
 * As with any software that integrates with the Facebook platform, your use
 * of this software is subject to the Facebook Developer Principles and
 * Policies [http://developers.facebook.com/policy/]. This copyright notice
 * shall be included in all copies or substantial portions of the software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 */

#import "TableViewController.h"

#import "NativeAdCell.h"

static NSInteger const kRowForAdCell = 2;
static NSString *const kDefaultCellIdentifier = @"kDefaultCellIdentifier";

@interface TableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) FBNativeAd *_nativeAd;
@property (strong, nonatomic) NSMutableArray *_tableViewContentArray;

@end

@implementation TableViewController

#pragma mark - Lazy Loading

- (NSMutableArray *)tableViewContentArray
{
  if (!self._tableViewContentArray) {
    self._tableViewContentArray = [NSMutableArray array];
    for (int i = 1; i <= 10; i++) {
      [self._tableViewContentArray addObject:[NSString stringWithFormat:@"TableView Cell #%d", i]];
    }
  }

  return self._tableViewContentArray;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  self.tableView.delegate = self;
  self.tableView.dataSource = self;

  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDefaultCellIdentifier];

  [self loadNativeAd];
}

- (IBAction)dismissViewController:(id)sender
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)refresh:(id)sender
{
  [self loadNativeAd];
}

- (void)loadNativeAd
{
  [self.activityIndicator startAnimating];

  // Create a native ad request with a unique placement ID (generate your own on the Facebook app settings).
  // Use different ID for each ad placement in your app.
  FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID:@"YOUR_PLACEMENT_ID"];

  // Set a delegate to get notified when the ad was loaded.
  nativeAd.delegate = self;

  // When testing on a device, add its hashed ID to force test ads.
  // The hash ID is printed to console when running on a device.
  // [FBAdSettings addTestDevice:@"THE HASHED ID AS PRINTED TO CONSOLE"];

  // Initiate a request to load an ad.
  [nativeAd loadAd];
}

#pragma mark - FBNativeAdDelegate implementation

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd
{
  NSLog(@"Native ad was loaded, constructing native UI...");

  if (self._nativeAd) {
    // Since we re-use the same UITableViewCell to show different ads over time, we call
    // unregisterView before registering the same view with a different   instance of FBNativeAd.
    [self._nativeAd unregisterView];
    [self.tableViewContentArray removeObjectAtIndex:kRowForAdCell];
  }
  self._nativeAd = nativeAd;

  NativeAdCell *nativeAdCell = [[[NSBundle mainBundle] loadNibNamed:@"NativeAdCell"
                                                              owner:self
                                                            options:nil] objectAtIndex:0];
  [nativeAdCell populate:nativeAd];

  NSLog(@"Register UIView for impression and click...");

  // Wire up UIView with the native ad; the whole UIView will be clickable.
  [nativeAd registerViewForInteraction:nativeAdCell
                    withViewController:self];

  // Or you can replace above call with following function, so you can specify the clickable areas.
  // NSArray *clickableViews = @[nativeAdCell.adCallToActionButton];
  // [nativeAd registerViewForInteraction:nativeAdCell
  //                   withViewController:self
  //                   withClickableViews:clickableViews];

  [self.tableViewContentArray insertObject:nativeAdCell atIndex:kRowForAdCell];
  [self.tableView reloadData];

  [self.activityIndicator stopAnimating];

}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error
{
  NSLog(@"Native ad failed to load with error: %@", error);
  [self.activityIndicator stopAnimating];

  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Native ad failed to load"
                                                  message:@"Check console for more details"
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd
{
  NSLog(@"Native ad was clicked.");
}

- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd
{
  NSLog(@"Native ad did finish click handling.");
}

- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd
{
  NSLog(@"Native ad impression is being captured.");
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.tableViewContentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  id contectObject = [self.tableViewContentArray objectAtIndex:indexPath.row];
  if ([contectObject isKindOfClass:[NativeAdCell class]]) {
    return contectObject;
  } else {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self.tableViewContentArray objectAtIndex:indexPath.row];
    return cell;
  }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  id contectObject = [self.tableViewContentArray objectAtIndex:indexPath.row];
  return [contectObject isKindOfClass:[NativeAdCell class]] ? 300 : 80;
}

@end
