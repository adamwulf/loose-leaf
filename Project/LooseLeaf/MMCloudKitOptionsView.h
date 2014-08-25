//
//  MMCloudKitOptionsView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/20/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMShareOptionsView.h"
#import "MMCloudKitManager.h"

@interface MMCloudKitOptionsView : MMShareOptionsView<MMCloudKitManagerDelegate,UITableViewDataSource,UITableViewDelegate>

@end
