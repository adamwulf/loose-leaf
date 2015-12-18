// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "PhoneLoginViewController.h"

#import <AccountsAlphaKit/AccountsAlpha.h>

@interface PhoneLoginViewController () <AAAccountsAlphaPhoneLoginDelegate>
@end

@implementation PhoneLoginViewController
{
  AccountsAlpha *_accounts;
  AAPhoneLoginRequest *_request;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  self.instructionsLabel.text = [NSString stringWithFormat:@"Enter the confirmation code sent to %@.", self.phoneNumber];
  [self.codeTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  if (!_accounts) {
    _accounts = [[AccountsAlpha alloc] initWithDelegate:self];
    [_accounts loginWithPhone:self.phoneNumber];
  }
}

- (void)accountsAlpha:(AccountsAlpha *)accountsAlpha phoneLoginDidFailWithError:(NSError *)error
{
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:[error localizedDescription]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                          [self dismissViewControllerAnimated:NO completion:NULL];
                                                        }];
  [alertController addAction:dismissAction];
  [self presentViewController:alertController animated:YES completion:NULL];
}

- (void)accountsAlpha:(AccountsAlpha *)accountsAlpha phoneLoginDidFinishWithToken:(AAAccessToken *)token
{
  [self performSegueWithIdentifier:@"loginCompleteSegue" sender:nil];
}

- (void)accountsAlpha:(AccountsAlpha *)accountsAlpha phoneLoginStartedWithRequest:(AAPhoneLoginRequest *)request
{
  _request = request;
}

- (void)cancel:(id)sender
{
  [_request cancel];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirm:(id)sender
{
  [_request continueWithCode:self.codeTextField.text];
}

@end
