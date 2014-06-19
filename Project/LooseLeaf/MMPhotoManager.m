//
//  MMPhotoManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPhotoManager.h"
#import "NSThread+BlockAdditions.h"
#import "Constants.h"

@implementation MMPhotoManager{
    BOOL hasEverInitailized;
    ALAssetsLibrary* assetsLibrary;
    
    NSArray* faces;
    NSArray* events;
    NSArray* albums;
    MMPhotoAlbum* cameraRoll;
}

@synthesize delegate;

static MMPhotoManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        _instance = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(libraryChanged:)
                                                     name:ALAssetsLibraryChangedNotification
                                                   object:[self assetsLibrary]];
    }
    return _instance;
}

+(MMPhotoManager*) sharedInstace{
    if(!_instance){
        _instance = [[MMPhotoManager alloc]init];
    }
    return _instance;
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}

#pragma mark - Properties

-(ALAssetsLibrary*) assetsLibrary{
    if(!assetsLibrary){
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return assetsLibrary;
}

-(NSUInteger) countOfAlbums{
    NSUInteger count = 0;
    @synchronized(self){
        count = [albums count] + [events count] + [faces count];
    }
    return count;
}

-(NSArray*) albums{
    NSArray* ret = nil;
    @synchronized(self){
        ret = albums;
    }
    return ret;
}

-(NSArray*) events{
    NSArray* ret = nil;
    @synchronized(self){
        ret = events;
    }
    return ret;
}

-(NSArray*) faces{
    NSArray* ret = nil;
    @synchronized(self){
        ret = faces;
    }
    return ret;
}

-(MMPhotoAlbum*) cameraRoll{
    MMPhotoAlbum* ret = nil;
    @synchronized(self){
        ret = cameraRoll;
    }
    return ret;
}

#pragma mark - Notifications

-(void) libraryChanged:(NSNotification*)note{
    NSDictionary* info = [note userInfo];
    NSLog(@"library changed: %@", info);
    NSSet *updatedAssetGroup = [info objectForKey:ALAssetLibraryUpdatedAssetGroupsKey];
    NSSet *deletedAssetGroup = [info objectForKey:ALAssetLibraryDeletedAssetGroupsKey];
    NSSet *insertedAssetGroup = [info objectForKey:ALAssetLibraryInsertedAssetGroupsKey];
    for(NSURL* url in updatedAssetGroup){
        [self albumUpdated:url];
    }
    for(NSURL* url in deletedAssetGroup){
        [self albumDeleted:url];
    }
    for(NSURL* url in insertedAssetGroup){
        [self albumAdded:url];
    }
}

-(void) resortAlbums{
    // name may have changed, resort
    @synchronized(self){
        albums = [self sortArrayByAlbumName:albums];
        events = [self sortArrayByAlbumName:events];
        faces = [self sortArrayByAlbumName:faces];
    }
    [self.delegate performSelectorOnMainThread:@selector(doneLoadingPhotoAlbums) withObject:nil waitUntilDone:NO];
}

NSArray*(^arrayByRemovingObjectWithURL)(NSArray* arr, NSURL* url) = ^NSArray*(NSArray* arr, NSURL* url){
    NSMutableArray* retArr = [NSMutableArray array];
    for(MMPhotoAlbum* obj in arr){
        if(![url isEqual:obj.assetURL]){
            [retArr addObject:obj];
        }
    }
    return [NSArray arrayWithArray:retArr];
};

-(void) albumAdded:(NSURL*)urlOfUpdatedAlbum{
    [[self assetsLibrary] groupForURL:urlOfUpdatedAlbum
                          resultBlock:^(ALAssetsGroup *group) {
                              MMPhotoAlbum* addedAlbum = [[MMPhotoAlbum alloc] initWithAssetGroup:group];
                              @synchronized(self){
                                  if(addedAlbum.type == ALAssetsGroupAlbum){
                                      albums = [self sortArrayByAlbumName:[albums arrayByAddingObject:addedAlbum]];
                                  }else if(addedAlbum.type == ALAssetsGroupEvent){
                                      events = [self sortArrayByAlbumName:[events arrayByAddingObject:addedAlbum]];
                                  }else if(addedAlbum.type == ALAssetsGroupFaces){
                                      faces = [self sortArrayByAlbumName:[faces arrayByAddingObject:addedAlbum]];
                                  }else if(addedAlbum.type == ALAssetsGroupSavedPhotos){
                                      cameraRoll = addedAlbum;
                                  }
                              }
                              [self.delegate performSelectorOnMainThread:@selector(doneLoadingPhotoAlbums) withObject:nil waitUntilDone:NO];
                          }
                         failureBlock:^(NSError *error) {
                             [self processError:error];
                         }];
}

-(void) albumUpdated:(NSURL*)urlOfUpdatedAlbum{
    [[self assetsLibrary] groupForURL:urlOfUpdatedAlbum
                          resultBlock:^(ALAssetsGroup *group) {
                              MMPhotoAlbum* updatedAlbum = [self albumWithURL:group.url];
                              [updatedAlbum refreshAlbumContentsWithGroup:group];
                              [self resortAlbums];
                              [self.delegate albumUpdated:updatedAlbum];
                          }
                         failureBlock:^(NSError *error) {
                             [self processError:error];
                         }];
}

-(void) albumDeleted:(NSURL*)urlOfUpdatedAlbum{
    @synchronized(self){
        albums = arrayByRemovingObjectWithURL(albums, urlOfUpdatedAlbum);
        events = arrayByRemovingObjectWithURL(events, urlOfUpdatedAlbum);
        faces = arrayByRemovingObjectWithURL(faces, urlOfUpdatedAlbum);
    }
    [self.delegate performSelectorOnMainThread:@selector(doneLoadingPhotoAlbums) withObject:nil waitUntilDone:NO];
}


#pragma mark - Initialization

-(NSArray*) sortArrayByAlbumName:(NSArray*)arrayToSort{
    NSComparisonResult (^sortByName)(id obj1, id obj2) = ^NSComparisonResult(id obj1, id obj2){
        return [[obj1 name] compare:[obj2 name] options:NSCaseInsensitiveSearch | NSNumericSearch];
    };
    return [arrayToSort sortedArrayUsingComparator:sortByName];
}

-(MMPhotoAlbum*) albumWithURL:(NSURL*)url{
    if([cameraRoll.assetURL isEqual:url]){
        return cameraRoll;
    }
    NSArray* allItems = nil;
    @synchronized(self){
        allItems = [[albums arrayByAddingObjectsFromArray:events] arrayByAddingObjectsFromArray:faces];
    }
    for (MMPhotoAlbum* album in allItems) {
        if([album.assetURL isEqual:url]){
            return album;
        }
    }
//    [[self assetsLibrary] groupForURL:url resultBlock:^(ALAssetsGroup *group) {
//        <#code#>
//    } failureBlock:^(NSError *error) {
//        <#code#>
//    }];
    return nil;
}

/**
 * initialize the repository of photo albums
 */
-(void) initializeAlbumCache{
    if(hasEverInitailized){
        return;
    }
    NSMutableArray* updatedAlbumsList = [NSMutableArray array];
    NSMutableArray* updatedEventsList = [NSMutableArray array];
    NSMutableArray* updatedFacesList = [NSMutableArray array];
    __block MMPhotoAlbum* updatedCameraRoll = nil;
    
    [NSThread performBlockInBackground:^{
        @autoreleasepool {
            [[self assetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos
                                                usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                                    if(!group){
                                                        // there is no group if we're all done iterating.
                                                        // sort our results and create an array of all our albums
                                                        // from albums -> events -> faces order
                                                        @synchronized(self){
                                                            albums = [self sortArrayByAlbumName:updatedAlbumsList];
                                                            events = [self sortArrayByAlbumName:updatedEventsList];
                                                            faces = [self sortArrayByAlbumName:updatedFacesList];
                                                            cameraRoll = updatedCameraRoll;
                                                        }
                                                        hasEverInitailized = YES;
                                                        [self.delegate performSelectorOnMainThread:@selector(doneLoadingPhotoAlbums) withObject:nil waitUntilDone:NO];
                                                    }else if ([group numberOfAssets] > 0 || group.type == ALAssetsGroupSavedPhotos){
                                                        MMPhotoAlbum* addedAlbum = [self albumWithURL:group.url];
                                                        if(!addedAlbum){
                                                            addedAlbum = [[MMPhotoAlbum alloc] initWithAssetGroup:group];
                                                        }
                                                        if(group.type == ALAssetsGroupAlbum){
                                                            [updatedAlbumsList addObject:addedAlbum];
                                                        }else if(group.type == ALAssetsGroupEvent){
                                                            [updatedEventsList addObject:addedAlbum];
                                                        }else if(group.type == ALAssetsGroupFaces){
                                                            [updatedFacesList addObject:addedAlbum];
                                                        }else if(group.type == ALAssetsGroupSavedPhotos){
                                                            updatedCameraRoll = addedAlbum;
                                                        }
                                                    }
                                                }
                                              failureBlock:^(NSError *error) {
                                                  [self processError:error];
                                              }];
        }
        
    }];
}


-(NSError*) processError:(NSError*)error{
    NSString *errorMessage = nil;
    switch ([error code]) {
        case ALAssetsLibraryAccessUserDeniedError:
        case ALAssetsLibraryAccessGloballyDeniedError:
            @synchronized(self){
                hasEverInitailized = YES;
            }
            errorMessage = @"The user has declined access to it.";
            break;
        default:
            @synchronized(self){
                hasEverInitailized = NO;
            }
            errorMessage = @"Reason unknown.";
            break;
    }
    @synchronized(self){
        faces = nil;
        events = nil;
        albums = nil;
        cameraRoll = nil;
    }

    [self showErrorAboutUserNeedingToGivePermission];
    return [NSError errorWithDomain:@"com.milestonemade.looseleaf" code:kPermissionDeniedError userInfo:nil];
}



-(void) showErrorAboutUserNeedingToGivePermission{
    debug_NSLog(@"user needs to grant permission to photo library");
}

@end
