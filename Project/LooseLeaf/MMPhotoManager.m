//
//  MMPhotoManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPhotoManager.h"

@implementation MMPhotoManager{
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
        albums = [[NSMutableArray alloc] init];
    }
    return _instance;
}

+(MMPhotoManager*) sharedInstace{
    if(!_instance){
        _instance = [[MMPhotoManager alloc]init];
    }
    return _instance;
}

-(ALAssetsLibrary*) assetsLibrary{
    if(!assetsLibrary){
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return assetsLibrary;
}

-(NSUInteger) countOfAlbums{
    return [albums count] + [events count] + [faces count];
}

-(NSArray*) albums{
    return [NSArray arrayWithArray:albums];
}

-(NSArray*) events{
    return [NSArray arrayWithArray:events];
}

-(NSArray*) faces{
    return [NSArray arrayWithArray:faces];
}

-(MMPhotoAlbum*) cameraRoll{
    return cameraRoll;
}



-(void) refreshAlbumCache:(NSError**)err{
    NSMutableArray* updatedAlbumsList = [NSMutableArray array];
    NSMutableArray* updatedEventsList = [NSMutableArray array];
    NSMutableArray* updatedFacesList = [NSMutableArray array];
    __block MMPhotoAlbum* savedPhotos = nil;
    
    [[self assetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                     [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                     if(!group){
                                         NSComparisonResult (^sortByName)(id obj1, id obj2) = ^NSComparisonResult(id obj1, id obj2){
                                             return [[obj1 name] compare:[obj2 name] options:NSCaseInsensitiveSearch | NSNumericSearch];
                                         };
                                         albums = [updatedAlbumsList sortedArrayUsingComparator:sortByName];
                                         events = [updatedEventsList sortedArrayUsingComparator:sortByName];
                                         faces = [updatedFacesList sortedArrayUsingComparator:sortByName];
                                         cameraRoll = savedPhotos;
                                         [self.delegate doneLoadingPhotoAlbums];
                                     }else if ([group numberOfAssets] > 0){
                                         if(group.type == ALAssetsGroupAlbum){
                                             [updatedAlbumsList addObject:[[MMPhotoAlbum alloc] initWithAssetGroup:group]];
                                         }else if(group.type == ALAssetsGroupEvent){
                                             [updatedEventsList addObject:[[MMPhotoAlbum alloc] initWithAssetGroup:group]];
                                         }else if(group.type == ALAssetsGroupFaces){
                                             [updatedFacesList addObject:[[MMPhotoAlbum alloc] initWithAssetGroup:group]];
                                         }else if(group.type == ALAssetsGroupSavedPhotos){
                                             savedPhotos = [[MMPhotoAlbum alloc] initWithAssetGroup:group];
                                         }
                                     }
                                 }
                               failureBlock:^(NSError *error) {
                                   NSString *errorMessage = nil;
                                   switch ([error code]) {
                                       case ALAssetsLibraryAccessUserDeniedError:
                                       case ALAssetsLibraryAccessGloballyDeniedError:
                                           errorMessage = @"The user has declined access to it.";
                                           break;
                                       default:
                                           errorMessage = @"Reason unknown.";
                                           break;
                                   }
                                   *err = [NSError errorWithDomain:@"com.milestonemade.looseleaf" code:kPermissionDeniedError userInfo:nil];
                               }];
}



@end
