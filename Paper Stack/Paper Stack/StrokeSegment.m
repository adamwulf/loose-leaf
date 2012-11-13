//
//  StrokeSegment.m
//  scratchpaper
//
//  Created by Adam Wulf on 11/10/12.
//
//

#import "StrokeSegment.h"

@implementation StrokeSegment
@synthesize rectToDisplay;
@synthesize fingerWidth;
@synthesize path;
@synthesize shouldFillInsteadOfStroke;

+(StrokeSegment*) strokeWithFingerWidth:(CGFloat)_fingerWidth andRect:(CGRect)_rectToDisplay andPath:(UIBezierPath*)_path{
    return [[[StrokeSegment alloc] initWithFingerWidth:_fingerWidth andRect:_rectToDisplay andPath:_path andFill:NO] autorelease];
}

+(StrokeSegment*) strokeWithFingerWidth:(CGFloat)_fingerWidth andRect:(CGRect)_rectToDisplay andPath:(UIBezierPath*)_path andFill:(BOOL)_fill{
    return [[[StrokeSegment alloc] initWithFingerWidth:_fingerWidth andRect:_rectToDisplay andPath:_path andFill:_fill] autorelease];
}

-(id) initWithFingerWidth:(CGFloat)_fingerWidth andRect:(CGRect)_rectToDisplay andPath:(UIBezierPath*)_path andFill:(BOOL)_shouldFillInsteadOfStroke{
    if(self = [super init]){
        self.fingerWidth = _fingerWidth;
        self.rectToDisplay = _rectToDisplay;
        self.path = _path;
        self.shouldFillInsteadOfStroke = _shouldFillInsteadOfStroke;
    }
    return self;
}

#pragma mark - NSCoding

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[NSValue valueWithCGRect:rectToDisplay] forKey:@"rectToDisplay"];
    [encoder encodeObject:[NSNumber numberWithFloat:fingerWidth] forKey:@"fingerWidth"];
    [encoder encodeObject:[NSNumber numberWithBool:shouldFillInsteadOfStroke] forKey:@"shouldFillInsteadOfStroke"];
    [encoder encodeObject:path forKey:@"path"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        rectToDisplay = [[decoder decodeObjectForKey:@"rectToDisplay"] CGRectValue];
        fingerWidth = [[decoder decodeObjectForKey:@"fingerWidth"] floatValue];
        shouldFillInsteadOfStroke = [[decoder decodeObjectForKey:@"shouldFillInsteadOfStroke"] boolValue];
        path = [[decoder decodeObjectForKey:@"path"] retain];
    }
    return self;
}

@end
