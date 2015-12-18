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

#import "LoginViewController.h"

#import "EmailLoginViewController.h"
#import "PhoneLoginViewController.h"

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  self.emailTextField.text = nil;
  self.phoneTextField.text = nil;
  [self.emailTextField becomeFirstResponder];
}

- (IBAction)login:(id)sender
{
  NSString *email = self.emailTextField.text;
  NSString *phone = self.phoneTextField.text;
  if ([email length]) {
    [self performSegueWithIdentifier:@"emailLoginSegue" sender:sender];
  } else if ([phone length]) {
    [self performSegueWithIdentifier:@"phoneLoginSegue" sender:sender];
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  [super prepareForSegue:segue sender:sender];

  UIViewController *destinationViewController = segue.destinationViewController;
  if ([destinationViewController isKindOfClass:[EmailLoginViewController class]]) {
    ((EmailLoginViewController *)destinationViewController).emailAddress = self.emailTextField.text;
  } else if ([destinationViewController isKindOfClass:[PhoneLoginViewController class]]) {
    ((PhoneLoginViewController *)destinationViewController).phoneNumber = self.phoneTextField.text;
  }
}

@end
