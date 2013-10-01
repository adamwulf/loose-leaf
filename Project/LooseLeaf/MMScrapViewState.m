//
//  MMScrapViewState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/1/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapViewState.h"
#import "NSThread+BlockAdditions.h"

@implementation MMScrapViewState{
    NSString* uuid;
    // the path where we store our data
    NSString* scrapPath;
    
    NSUInteger lastSavedUndoHash;
    UIView* contentView;
    JotView* drawableView;
    UIBezierPath* bezierPath;
    
    // private vars
    NSString* plistPath;
    NSString* inkImageFile;
    NSString* thumbImageFile;
    NSString* stateFile;
    
    CGSize originalSize;
    CGRect drawableBounds;
}

@synthesize bezierPath;
@synthesize contentView;
@synthesize drawableBounds;

-(id) initWithUUID:(NSString*)_uuid{
    if(self = [super init]){
        
        // save our UUID, everything depends on this
        uuid = _uuid;
        
        if([[NSFileManager defaultManager] fileExistsAtPath:self.plistPath]){
            NSDictionary* properties = [NSDictionary dictionaryWithContentsOfFile:self.plistPath];
            bezierPath = [NSKeyedUnarchiver unarchiveObjectWithData:[properties objectForKey:@"bezierPath"]];
            return [self initWithUUID:uuid andBezierPath:bezierPath];
        }else{
            // we don't have a file that we should have, so don't load the scrap
            return nil;
        }
    }
    return self;
}


-(id) initWithUUID:(NSString*)_uuid andBezierPath:(UIBezierPath*)_path{
    if(self = [super init]){
        
        // save our UUID, everything depends on this
        uuid = _uuid;

        if(!bezierPath){
            CGRect originalBounds = _path.bounds;
            [_path applyTransform:CGAffineTransformMakeTranslation(-originalBounds.origin.x + 4, -originalBounds.origin.y + 4)];
            bezierPath = _path;
        }

        // find drawable view bounds
        drawableBounds = bezierPath.bounds;
        drawableBounds = CGRectInset(drawableBounds, -4, -4);
        drawableBounds.origin = CGPointMake(0, 0);
        
        // this content view will be used by the MMScrapView to show
        // the scrap's contents. we'll use this to swap between
        // a UIImageView that holds a cached image of the contents and
        // the editable JotView
        contentView = [[UIView alloc] initWithFrame:drawableBounds];
        [contentView setClipsToBounds:YES];
        [contentView setBackgroundColor:[UIColor clearColor]];
        
        // create a blank drawable view
        drawableView = [[JotView alloc] initWithFrame:drawableBounds];
        lastSavedUndoHash = -1;
        
        // add our drawable view to our contents
        [contentView addSubview:drawableView];
        
        // load state, if we have any.
        // TODO: make this async later when possible
        if([[NSFileManager defaultManager] fileExistsAtPath:self.stateFile]){
            
            // load drawable view information here
            JotViewState* state = [[JotViewState alloc] initWithImageFile:self.inkImageFile
                                                             andStateFile:self.stateFile
                                                              andPageSize:[drawableView pagePixelSize]
                                                             andGLContext:[drawableView context]];
            
            [drawableView loadState:state];
            
            lastSavedUndoHash = [drawableView undoHash];
        }
    }
    return self;
}

-(CGSize) originalSize{
    if(CGSizeEqualToSize(originalSize, CGSizeZero)){
        originalSize = self.bezierPath.bounds.size;
    }
    return originalSize;
}

-(void) saveToDisk{
    if(lastSavedUndoHash != [drawableView undoHash]){
        dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
        [NSThread performBlockOnMainThread:^{
            // save path
            // this needs to be saved at the exact same time as the drawable view
            // so that we can guarentee that there is no race condition
            // for saving state vs content
            NSMutableDictionary* savedProperties = [NSMutableDictionary dictionary];
            [savedProperties setObject:[NSKeyedArchiver archivedDataWithRootObject:bezierPath] forKey:@"bezierPath"];
            [savedProperties writeToFile:self.plistPath atomically:YES];
            
            // now export the drawn content
            [drawableView exportImageTo:self.inkImageFile andThumbnailTo:self.thumbImageFile andStateTo:self.stateFile onComplete:^(UIImage* ink, UIImage* thumb, JotViewImmutableState* state){
                dispatch_semaphore_signal(sema1);
                lastSavedUndoHash = [state undoHash];
            }];
        }];
        dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
    }
}


-(void) loadStateAsynchronously:(BOOL)async{
    
}

-(void) unloadState{
    
}



#pragma mark - TODO

-(void) addElement:(AbstractBezierPathElement*)element{
    [drawableView addElement:element];
}


#pragma mark - Paths

-(NSString*)plistPath{
    if(!plistPath){
        plistPath = [self.scrapPath stringByAppendingPathComponent:[@"info" stringByAppendingPathExtension:@"plist"]];
    }
    return plistPath;
}

-(NSString*)inkImageFile{
    if(!inkImageFile){
        inkImageFile = [self.scrapPath stringByAppendingPathComponent:[@"ink" stringByAppendingPathExtension:@"png"]];
    }
    return inkImageFile;
}

-(NSString*) thumbImageFile{
    if(!thumbImageFile){
        thumbImageFile = [self.scrapPath stringByAppendingPathComponent:[@"thumb" stringByAppendingPathExtension:@"png"]];
    }
    return thumbImageFile;
}

-(NSString*) stateFile{
    if(!stateFile){
        stateFile = [self.scrapPath stringByAppendingPathComponent:[@"state" stringByAppendingPathExtension:@"plist"]];
    }
    return stateFile;
}


#pragma mark - Private

+(NSString*) scrapDirectoryPathForUUID:(NSString*)uuid{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsPath = [paths objectAtIndex:0];
    NSString* scrapPath = [[documentsPath stringByAppendingPathComponent:@"Scraps"] stringByAppendingPathComponent:uuid];
    return scrapPath;
}

-(NSString*) scrapPath{
    if(!scrapPath){
        scrapPath = [MMScrapViewState scrapDirectoryPathForUUID:uuid];
        if(![[NSFileManager defaultManager] fileExistsAtPath:scrapPath]){
            [[NSFileManager defaultManager] createDirectoryAtPath:scrapPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return scrapPath;
}



@end
