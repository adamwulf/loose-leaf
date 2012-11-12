//
//  SLPageManager.m
//  scratchpaper
//
//  Created by Adam Wulf on 11/12/12.
//
//

#import "SLPageManager.h"
#import "NSThread+BlockAdditions.h"

@implementation SLPageManager

@synthesize stackView;
@synthesize idealBounds;

static SLPageManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((_instance = [super init])){

    }
    return _instance;
}

+(SLPageManager*) sharedInstace{
    if(!_instance){
        _instance = [[SLPageManager alloc] init];
    }
    return _instance;
}

dispatch_source_t CreateDispatchTimer(uint64_t interval, uint64_t leeway, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}



+(NSString*) pathToSavedData{
    // get documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    // add the data file name
    return [basePath stringByAppendingPathComponent:@"data.dat"];
}

-(void) save{
    NSMutableArray* visiblePages = [NSMutableArray array];
    NSMutableArray* inflightPages = [NSMutableArray array];
    NSMutableArray* hiddenPages = [NSMutableArray array];
    CGFloat time = [NSThread timeBlock:^{
        @synchronized(stackView){
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
    }];
    NSString* filePath = [SLPageManager pathToSavedData];
    NSLog(@"saving %d %d %d %f", [visiblePages count], [inflightPages count], [hiddenPages count], time);
    NSLog(@"to %@", filePath);
    
    NSMutableDictionary* dataToSave = [NSMutableDictionary dictionary];
    [dataToSave setObject:visiblePages forKey:@"visiblePages"];
    [dataToSave setObject:inflightPages forKey:@"inflightPages"];
    [dataToSave setObject:hiddenPages forKey:@"hiddenPages"];
    
    [dataToSave writeToFile:filePath atomically:YES];
}


-(void) load{
    NSDictionary* dataFromDisk = [NSDictionary dictionaryWithContentsOfFile:[SLPageManager pathToSavedData]];
    if(dataFromDisk){
        for(NSString* uuid in [[dataFromDisk objectForKey:@"visiblePages"] reverseObjectEnumerator]){
            SLPaperView* paper = [[SLPaperView alloc] initWithFrame:idealBounds andUUID:uuid];
            [stackView addPaperToBottomOfStack:paper];
        }
        for(NSString* uuid in [[dataFromDisk objectForKey:@"hiddenPages"] reverseObjectEnumerator]){
            SLPaperView* paper = [[SLPaperView alloc] initWithFrame:idealBounds andUUID:uuid];
            [stackView addPaperToBottomOfHiddenStack:paper];
        }
    }else{
        SLPaperView* paper = [[SLPaperView alloc] initWithFrame:idealBounds];
        [stackView addPaperToBottomOfStack:paper];
        paper = [[SLPaperView alloc] initWithFrame:idealBounds];
        [stackView addPaperToBottomOfHiddenStack:paper];
    }
    
}


@end
