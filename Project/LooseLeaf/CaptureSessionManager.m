#import "CaptureSessionManager.h"


@implementation CaptureSessionManager{
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureSession *captureSession;
}

@synthesize captureSession;
@synthesize previewLayer;

#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
		[self setCaptureSession:[[AVCaptureSession alloc] init]];
        [self addVideoInput];
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]];
        [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	}
	return self;
}

- (void)addVideoInput {
	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];	
	if (videoDevice) {
		NSError *error;
		AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		if (!error) {
			if ([[self captureSession] canAddInput:videoIn])
				[[self captureSession] addInput:videoIn];
			else
				NSLog(@"Couldn't add video input");		
		}
		else
			NSLog(@"Couldn't create video input");
	}
	else
		NSLog(@"Couldn't create video capture device");
}

-(void) addPreviewLayerTo:(CALayer*)layer{
    CGRect layerRect = [layer bounds];
	[[self previewLayer] setBounds:layerRect];
	[[self previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
	[layer addSublayer:[self previewLayer]];
}

- (void)dealloc {
	[[self captureSession] stopRunning];
}

@end
