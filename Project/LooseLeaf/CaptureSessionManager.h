#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>


@interface CaptureSessionManager : NSObject

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;

-(void) changeCamera;
-(void) snapPicture;
-(void) addPreviewLayerTo:(CALayer*)layer;

@end
