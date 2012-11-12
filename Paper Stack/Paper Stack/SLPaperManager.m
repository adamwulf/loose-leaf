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
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(save) userInfo:nil repeats:NO];

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
    NSString* filePath = [SLPaperManager pathToSavedData];
    NSLog(@"saving %d %f", [visiblePages count] + [inflightPages count] + [hiddenPages count], time);
    NSLog(@"to %@", filePath);
    
    NSMutableDictionary* dataToSave = [NSMutableDictionary dictionary];
    [dataToSave setObject:visiblePages forKey:@"visiblePages"];
    [dataToSave setObject:inflightPages forKey:@"inflightPages"];
    [dataToSave setObject:hiddenPages forKey:@"hiddenPages"];
    
    [dataToSave writeToFile:filePath atomically:YES];

    NSLog(@"saving data: %@", dataToSave);
}


-(void) load{
    NSDictionary* dataFromDisk = [NSDictionary dictionaryWithContentsOfFile:[SLPaperManager pathToSavedData]];
    NSLog(@"loading data: %@", dataFromDisk);
    if(dataFromDisk){
        for(NSString* uuid in [dataFromDisk objectForKey:@"visiblePages"]){
            SLPaperView* paper = [[SLPaperView alloc] initWithFrame:idealBounds andUUID:uuid];
            [stackView pushPaperToTopOfStack:paper];
        }
        for(NSString* uuid in [dataFromDisk objectForKey:@"hiddenPages"]){
            SLPaperView* paper = [[SLPaperView alloc] initWithFrame:idealBounds andUUID:uuid];
            [stackView pushPaperToTopOfHiddenStack:paper];
        }
        for(NSString* uuid in [[dataFromDisk objectForKey:@"inflightPages"] reverseObjectEnumerator]){
            SLPaperView* paper = [[SLPaperView alloc] initWithFrame:idealBounds andUUID:uuid];
            [stackView pushPaperToTopOfHiddenStack:paper];
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
    return [[[SLPaperView alloc] initWithFrame:self.idealBounds] autorelease];
}



@end
