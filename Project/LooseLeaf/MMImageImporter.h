//
//  MMImageImporter.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/21/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMImageImporter : NSObject

+(MMImageImporter*) sharedInstace;

+(NSString*) UTIForExtension:(NSString*)fileExtension;

-(UIImage*) imageForURL:(NSURL*)url maxDim:(int)maxDim;

@end
