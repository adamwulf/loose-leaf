//
//  NSURL+UTI.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface NSURL (UTI)

+(NSString*) UTIForExtension:(NSString*)fileExtension;

-(NSString*) universalTypeID;

+(NSString*) mimeForExtension:(NSString*)fileExtension;

-(NSString*) fileExtension;

-(NSString*) mimeType;

@end
