//
//  MMImmutableScrapState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/30/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMImmutableScrapsOnPaperState.h"
#import "MMScrapView.h"

@implementation MMImmutableScrapsOnPaperState{
    NSArray* scraps;
}

-(id) initWithScrapIDsPath:(NSString *)scrapIDsPath andScraps:(NSArray*)_scraps{
    if(self = [super initWithScrapIDsPath:scrapIDsPath]){
        scraps = [_scraps copy];
    }
    return self;
}

-(BOOL) isStateLoaded{
    return YES;
}

-(NSArray*) scraps{
    return scraps;
}

-(BOOL) saveToDisk{
    __block BOOL hadAnyEditsToSaveAtAll = NO;
    if([scraps count]){
        dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);

        __block NSInteger savedScraps = 0;
        void(^doneSavingScrapBlock)(BOOL) = ^(BOOL hadEditsToSave){
            savedScraps ++;
            hadAnyEditsToSaveAtAll = hadAnyEditsToSaveAtAll || hadEditsToSave;
            if(savedScraps == [scraps count]){
                // just saved the last scrap, signal
                dispatch_semaphore_signal(sema1);
            }
        };

        NSMutableArray* scrapUUIDs = [NSMutableArray array];
        for(MMScrapView* scrap in scraps){
            NSMutableDictionary* properties = [NSMutableDictionary dictionary];
            [properties setObject:scrap.uuid forKey:@"uuid"];
            [properties setObject:[NSNumber numberWithFloat:scrap.center.x] forKey:@"center.x"];
            [properties setObject:[NSNumber numberWithFloat:scrap.center.y] forKey:@"center.y"];
            [properties setObject:[NSNumber numberWithFloat:scrap.rotation] forKey:@"rotation"];
            [properties setObject:[NSNumber numberWithFloat:scrap.scale] forKey:@"scale"];
            
            [scrap saveToDisk:doneSavingScrapBlock];
            
            // save scraps
            [scrapUUIDs addObject:properties];
        }
        [scrapUUIDs writeToFile:self.scrapIDsPath atomically:YES];
        
        dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
        dispatch_release(sema1);
        NSLog(@"done saving %d scraps", [scraps count]);
    }else{
        [[NSFileManager defaultManager] removeItemAtPath:self.scrapIDsPath error:nil];
    }
    NSLog(@"done saving immutable scraps on paper state");
    return hadAnyEditsToSaveAtAll;
}

-(void) unload{
    if([self isStateLoaded]){
        [self saveToDisk];
    }
    [super unload];
}

@end
