//
//  SLPageManager.m
//  scratchpaper
//
//  Created by Adam Wulf on 11/12/12.
//
//

#import "SLPaperManager.h"
#import "NSThread+BlockAdditions.h"

@implementation SLPaperManager

@synthesize stackView;
@synthesize idealBounds;

static SLPaperManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((_instance = [super init])){
        opQueue = [[NSOperationQueue alloc] init];
        opQueue.maxConcurrentOperationCount = 1;
        opQueue.name = @"SLPaperManager Queue";
        cacheOfPagesByUUID = [[NSMutableDictionary alloc] init];
    }
    return _instance;
}

+(SLPaperManager*) sharedInstace{
    if(!_instance){
        _instance = [[SLPaperManager alloc] init];
    }
    return _instance;
}


+(NSString*) pathToSavedData{
    // get documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    // add the data file name
    return [basePath stringByAppendingPathComponent:@"data.dat"];
}


/**
 * TODO
 *
 * this currently synchronizes on the view itself, which means
 * that running this in the background doesn't have a fantastic effect.
 *
 * instead, i should have the StackView also contain a backing model view
 * and all modifications to the subviews of each stack will be done
 * in order in a background thread on the model arrays.
 *
 * this way, i can sync/save/etc on the model, which will always be modified on
 * a background thread, and will not block the UI views or subview arrays.
 */
-(void) save{
    if(opQueue.operationCount < 2){
        [opQueue addOperationWithBlock:^{
            NSMutableArray* visiblePages = [NSMutableArray array];
            NSMutableArray* inflightPages = [NSMutableArray array];
            NSMutableArray* hiddenPages = [NSMutableArray array];
            @synchronized(self){
                for(SLPaperView* page in stackView.visibleViews){
                    [visiblePages addObject:[page uuid]];
                }
                for(SLPaperView* page in stackView.inflightViews){
                    [inflightPages addObject:[page uuid]];
                }
                for(SLPaperView* page in stackView.hiddenViews){
                    [hiddenPages addObject:[page uuid]];
                }
            }
            NSString* filePath = [SLPaperManager pathToSavedData];
            
            NSMutableDictionary* dataToSave = [NSMutableDictionary dictionary];
            [dataToSave setObject:visiblePages forKey:@"visiblePages"];
            [dataToSave setObject:inflightPages forKey:@"inflightPages"];
            [dataToSave setObject:hiddenPages forKey:@"hiddenPages"];
            
            [dataToSave writeToFile:filePath atomically:YES];
        }];
    }
}


-(void) load{
    NSDictionary* dataFromDisk = [NSDictionary dictionaryWithContentsOfFile:[SLPaperManager pathToSavedData]];
    if(dataFromDisk){
        for(NSString* uuid in [[dataFromDisk objectForKey:@"visiblePages"] reverseObjectEnumerator]){
            [stackView addPaperToBottomOfStack:[self createPageForUUID:uuid]];
        }
        for(NSString* uuid in [dataFromDisk objectForKey:@"hiddenPages"]){
            [stackView pushPaperToTopOfHiddenStack:[self createPageForUUID:uuid]];
        }
        for(NSString* uuid in [[dataFromDisk objectForKey:@"inflightPages"] reverseObjectEnumerator]){
            [stackView pushPaperToTopOfHiddenStack:[self createPageForUUID:uuid]];
        }
    }else{
        SLPaperView* paper = [[SLPaperManager sharedInstace] createNewBlankPage];
        [stackView addPaperToBottomOfStack:paper];
        paper = [[SLPaperManager sharedInstace] createNewBlankPage];
        [stackView addPaperToBottomOfHiddenStack:paper];
    }
}




#pragma mark - Create Pages

-(SLPaperView*) createNewBlankPage{
    SLPaperView* paper = [[[SLPaperView alloc] initWithFrame:self.idealBounds] autorelease];
    [cacheOfPagesByUUID setObject:paper forKey:paper.uuid];
    return paper;
}

-(SLPaperView*) createPageForUUID:(NSString*)uuid{
    SLPaperView* paper = [[[SLPaperView alloc] initWithFrame:idealBounds andUUID:uuid] autorelease];
    [cacheOfPagesByUUID setObject:paper forKey:paper.uuid];
    return paper;
}

#pragma mark - Fetch Pages

-(SLPaperView*) pageForUUID:(NSString*)uuid{
    return [cacheOfPagesByUUID objectForKey:uuid];
}

@end
