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

#import "AccountViewController.h"

#import <AccountsAlphaKit/AccountsAlpha.h>

@implementation AccountViewController
{
  AccountsAlpha *_accounts;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  if (!_accounts) {
    _accounts = [[AccountsAlpha alloc] initWithDelegate:nil];
    [_accounts requestAccount:^(AAAccount *account, NSError *error) {
      self.accountIDLabel.text = account.accountID;
      if ([account.emailAddress length]) {
        self.titleLabel.text = @"Email Address";
        self.valueLabel.text = account.emailAddress;
      } else if ([account.phoneNumber length]) {
        self.titleLabel.text = @"Phone Number";
        self.valueLabel.text = account.phoneNumber;
      }
    }];
  }
}

- (void)logOut:(id)sender
{
  [_accounts logOut];
  [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
