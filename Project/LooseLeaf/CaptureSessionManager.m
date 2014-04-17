#import "CaptureSessionManager.h"
#import <AssetsLibrary/AssetsLibrary.h>


@implementation CaptureSessionManager{
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureSession *captureSession;
    AVCaptureStillImageOutput* stillImageOutput;
    AVCaptureDevice* currDevice;
    CALayer* previewLayerHolder;
}

@synthesize captureSession;
@synthesize previewLayer;
@synthesize delegate;

dispatch_queue_t sessionQueue;

+(dispatch_queue_t) sessionQueue{
    if(!sessionQueue){
        sessionQueue = dispatch_queue_create("CaptureSessionManager.session.queue", DISPATCH_QUEUE_SERIAL);
    }
    return sessionQueue;
}

#pragma mark Capture Session Configuration

- (id)initWithPosition:(AVCaptureDevicePosition)preferredPosition{
	if ((self = [super init])) {
		captureSession = [[AVCaptureSession alloc] init];
        captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        
        [captureSession addObserver:self forKeyPath:@"isInterrupted" options:NSKeyValueObservingOptionNew context:nil];
        
        previewLayerHolder = [[CALayer alloc] init];
        
        dispatch_async([CaptureSessionManager sessionQueue], ^{
            stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
            if ([captureSession canAddOutput:stillImageOutput]){
                NSLog(@"adding picture file output");
                [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
                [captureSession addOutput:stillImageOutput];
            }
            
            [self changeCameraToDevice:[self deviceForPosition:preferredPosition]];

            [captureSession startRunning];
            [self sessionStarted];
        });
	}
	return self;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"isInterrupted"]){
        NSLog(@"interrupted!");
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void) sessionStarted{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(previewLayer){
            [previewLayer removeFromSuperlayer];
        }
        previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
        [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        CGRect layerRect = [previewLayerHolder bounds];
        layerRect.size.width = floorf(layerRect.size.width);
        layerRect.size.height = floorf(layerRect.size.height);
        [previewLayer setBounds:layerRect];
        [previewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
        [previewLayerHolder addSublayer:previewLayer];
    });
    [delegate sessionStarted];
}

#pragma mark - Public Interface

-(void) changeCamera{
    dispatch_async([CaptureSessionManager sessionQueue], ^{
        NSArray* currentInputs = [[self captureSession] inputs];
        AVCaptureDeviceInput* currInput = [currentInputs firstObject];
        if([currentInputs count]){
            // remove if we have one
            [[self captureSession] removeInput:currInput];
        }
        AVCaptureDevice* nextDevice = [self oppositeDeviceFrom:currDevice];
        [self changeCameraToDevice:nextDevice];
    });
}

-(void) changeCameraToDevice:(AVCaptureDevice*)nextDevice{
    if (nextDevice) {
        NSError *error;
        AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:nextDevice error:&error];
        if(!error){
            if ([[self captureSession] canAddInput:videoIn]){
                currDevice = nextDevice;
                [[self captureSession] addInput:videoIn];
                [self.delegate didChangeCameraTo:videoIn.device.position];
            }else{
                NSLog(@"Couldn't create video input");
                currDevice = nil;
            }
        }else{
            NSLog(@"Couldn't create video input");
            currDevice = nil;
        }
    }else{
        NSLog(@"Couldn't create video capture device");
        currDevice = nil;
    }
}


-(void) addPreviewLayerTo:(CALayer*)layer{
    CGRect layerRect = [layer bounds];
	[previewLayerHolder setBounds:layerRect];
	[previewLayerHolder setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
	[layer addSublayer:previewLayerHolder];
}

-(void) snapPicture{
	dispatch_async([CaptureSessionManager sessionQueue], ^{
		// Update the orientation on the still image output video connection before capturing.
		[[stillImageOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[self previewLayer] connection] videoOrientation]];
		
		// Flash set to Auto for Still Capture
		[CaptureSessionManager setFlashMode:AVCaptureFlashModeAuto forDevice:currDevice];
		
		// Capture a still image.
		[stillImageOutput captureStillImageAsynchronouslyFromConnection:[stillImageOutput connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
			
			if (imageDataSampleBuffer)
			{
				NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
				UIImage *image = [[UIImage alloc] initWithData:imageData];
                
                NSLog(@"gotcha %p", image);
                
                [delegate didTakePicture:image];
                
				[[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
			}
		}];
	});
}

#pragma mark - Private

-(AVCaptureDevice*) oppositeDeviceFrom:(AVCaptureDevice*)currentDevice{
    AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionBack;
    switch (currentDevice.position)
    {
        case AVCaptureDevicePositionUnspecified:
            preferredPosition = AVCaptureDevicePositionBack;
            break;
        case AVCaptureDevicePositionBack:
            preferredPosition = AVCaptureDevicePositionFront;
            break;
        case AVCaptureDevicePositionFront:
            preferredPosition = AVCaptureDevicePositionBack;
            break;
    }
    
    return [self deviceForPosition:preferredPosition];
}

-(AVCaptureDevice*) deviceForPosition:(AVCaptureDevicePosition)preferredPosition{
    return [CaptureSessionManager deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
}


+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];
	
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == position)
		{
			captureDevice = device;
			break;
		}
	}
	
	return captureDevice;
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
	if ([device hasFlash] && [device isFlashModeSupported:flashMode])
	{
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			[device setFlashMode:flashMode];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	}
}

- (void)dealloc {
	[[self captureSession] stopRunning];
    [captureSession removeObserver:self forKeyPath:@"isInterrupted"];
}

@end
