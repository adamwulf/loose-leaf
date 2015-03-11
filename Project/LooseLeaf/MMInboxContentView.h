//
//  MMPDFInboxContentView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMAbstractSidebarContentView.h"
#import "MMPDF.h"

@interface MMInboxContentView : MMAbstractSidebarContentView

-(void) switchToPDFView:(MMPDF*)pdf;

@end
