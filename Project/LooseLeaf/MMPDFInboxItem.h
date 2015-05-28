//
//  MMPDF.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMInboxItem.h"

@interface MMPDFInboxItem : MMInboxItem

@property (readonly) BOOL isEncrypted;

-(BOOL) attemptToDecrypt:(NSString*)password;

-(id) init NS_UNAVAILABLE;

-(id) initWithURL:(NSURL*)pdfURL;

@end
