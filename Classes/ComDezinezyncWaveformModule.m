//
//
//  DZWaveForm
//
//  Created by Nikhil Nigade on 18/11/13.
//
//

#import "ComDezinezyncWaveformModule.h"

#define absX(x) (x<0?0-x:x)
#define minMaxX(x,mn,mx) (x<=mn?mn:(x>=mx?mx:x))
#define noiseFloor (-50.0)
#define decibel(amplitude) (20.0 * log10(absX(amplitude)/32767.0))
#define imgExt @"png"
#define imageToData(x) UIImagePNGRepresentation(x)

@implementation ComDezinezyncWaveformModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"2c95c5b0-2655-4f7d-8332-02b520865064";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.dezinezync.waveform";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
    NSLog(@"Deallocating");
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs

-(id)example:(id)args
{
	// example method
	return @"hello world";
}

-(id)exampleProp
{
	// example property getter
	return @"hello world";
}

-(void)setExampleProp:(id)value
{
	// example property setter
}

//URL is the file's url. In Ti, do file.resolve() and pass that as the param.
-(id)analyze:(id)url
{
    NSString *theString = [TiUtils stringValue:[url objectAtIndex:0]];
    
    NSLog(theString);
    
    NSURL *theURL = [NSURL fileURLWithPath:theString];
    
    AVURLAsset *urlA = [AVURLAsset URLAssetWithURL:theURL options:nil];
    
    UIImage *theImage = [self renderPNGAudioPictogramLogForAsset:urlA];
    
    if(theImage != nil)
    {
        TiBlob *theBlob = [[TiBlob alloc] initWithImage:theImage];
        
        if(theBlob != nil)
        {
            //[theString release];
            //[theURL release];
           
            return theBlob;
        }
        else
        {
            //[theString release];
            //[theURL release];

            return [NSNull null];
        }
    }
    else
    {
        //[theString release];
        //[theURL release];
        
        return [NSNull null];
    }
    
}

-(UIImage *)audioImageLogGraph:(Float32 *) samples
                  normalizeMax:(Float32) normalizeMax
                   sampleCount:(NSInteger) sampleCount
                  channelCount:(NSInteger) channelCount
                   imageHeight:(float) imageHeight {
    
    CGSize imageSize = CGSizeMake(sampleCount, imageHeight);
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetAlpha(context,1.0);
    CGRect rect;
    rect.size = imageSize;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    CGColorRef leftcolor = [[UIColor whiteColor] CGColor];
    CGColorRef rightcolor = [[UIColor redColor] CGColor];
    
    CGContextFillRect(context, rect);
    
    CGContextSetLineWidth(context, 1.0);
    
    float halfGraphHeight = (imageHeight / 2) / (float) channelCount ;
    float centerLeft = halfGraphHeight;
    float centerRight = (halfGraphHeight*3) ;
    float sampleAdjustmentFactor = (imageHeight/ (float) channelCount) / (normalizeMax - noiseFloor) / 2;
    
    for (NSInteger intSample = 0 ; intSample < sampleCount ; intSample ++ ) {
        Float32 left = *samples++;
        float pixels = (left - noiseFloor) * sampleAdjustmentFactor;
        CGContextMoveToPoint(context, intSample, centerLeft-pixels);
        CGContextAddLineToPoint(context, intSample, centerLeft+pixels);
        CGContextSetStrokeColorWithColor(context, leftcolor);
        CGContextStrokePath(context);
        
        if (channelCount==2) {
            Float32 right = *samples++;
            float pixels = (right - noiseFloor) * sampleAdjustmentFactor;
            CGContextMoveToPoint(context, intSample, centerRight - pixels);
            CGContextAddLineToPoint(context, intSample, centerRight + pixels);
            CGContextSetStrokeColorWithColor(context, rightcolor);
            CGContextStrokePath(context);
        }
    }
    
    // Create new image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Tidy up
    UIGraphicsEndImageContext();
    
    return newImage;
}



-(UIImage *)renderPNGAudioPictogramLogForAsset:(AVURLAsset *)songAsset {
    
    NSError *error = nil;
    
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
    
    if(error != nil)
    {
        NSLog(@"Error: %@", error.localizedDescription);
        return;
    }
    
    if([songAsset.tracks count] == 0)
    {
        NSLog(@"No tracks found in the song asset");
        return;
    }
    
    AVAssetTrack *songTrack = [[songAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    NSDictionary *outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                        //     [NSNumber numberWithInt:44100.0],AVSampleRateKey, /*Not Supported*/
                                        //     [NSNumber numberWithInt: 2],AVNumberOfChannelsKey,    /*Not Supported*/
                                        
                                        [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                                        
                                        nil];
    
    
    AVAssetReaderTrackOutput* output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
    
    [reader addOutput:output];
    [output release];
    
    UInt32 sampleRate,channelCount;
    
    NSArray* formatDesc = songTrack.formatDescriptions;
    for(unsigned int i = 0; i < [formatDesc count]; ++i) {
        CMAudioFormatDescriptionRef item = (CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription (item);
        if(fmtDesc ) {
            
            sampleRate = fmtDesc->mSampleRate;
            channelCount = fmtDesc->mChannelsPerFrame;
            
            //    NSLog(@"channels:%u, bytes/packet: %u, sampleRate %f",fmtDesc->mChannelsPerFrame, fmtDesc->mBytesPerPacket,fmtDesc->mSampleRate);
        }
    }
    
    UInt32 bytesPerSample = 2 * channelCount;
    Float32 normalizeMax = noiseFloor;
    NSLog(@"normalizeMax = %f",normalizeMax);
    NSMutableData * fullSongData = [[NSMutableData alloc] init];
    [reader startReading];
    
    UInt64 totalBytes = 0;
    
    Float64 totalLeft = 0;
    Float64 totalRight = 0;
    Float32 sampleTally = 0;
    
    NSInteger samplesPerPixel = sampleRate / 50;
    
    while (reader.status == AVAssetReaderStatusReading){
        
        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        
        if (sampleBufferRef){
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            totalBytes += length;
            
            
            NSAutoreleasePool *wader = [[NSAutoreleasePool alloc] init];
            
            NSMutableData * data = [NSMutableData dataWithLength:length];
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes);
            
            
            SInt16 * samples = (SInt16 *) data.mutableBytes;
            int sampleCount = length / bytesPerSample;
            for (int i = 0; i < sampleCount ; i ++) {
                
                Float32 left = (Float32) *samples++;
                left = decibel(left);
                left = minMaxX(left,noiseFloor,0);
                
                totalLeft  += left;
                
                
                
                Float32 right;
                if (channelCount==2) {
                    right = (Float32) *samples++;
                    right = decibel(right);
                    right = minMaxX(right,noiseFloor,0);
                    
                    totalRight += right;
                }
                
                sampleTally++;
                
                if (sampleTally > samplesPerPixel) {
                    
                    left  = totalLeft / sampleTally;
                    if (left > normalizeMax) {
                        normalizeMax = left;
                    }
                    // NSLog(@"left average = %f, normalizeMax = %f",left,normalizeMax);
                    
                    [fullSongData appendBytes:&left length:sizeof(left)];
                    
                    if (channelCount==2) {
                        right = totalRight / sampleTally;
                        
                        
                        if (right > normalizeMax) {
                            normalizeMax = right;
                        }
                        
                        [fullSongData appendBytes:&right length:sizeof(right)];
                    }
                    
                    totalLeft   = 0;
                    totalRight  = 0;
                    sampleTally = 0;
                    
                }
            }
            
            [wader drain];
            
            CMSampleBufferInvalidate(sampleBufferRef);
            
            CFRelease(sampleBufferRef);
        }
    }
    
    UIImage *finalImage = nil;
    
    if (reader.status == AVAssetReaderStatusFailed || reader.status == AVAssetReaderStatusUnknown){
        // Something went wrong. Handle it.
        NSLog(@"Image rendering failed");
    }
    
    if (reader.status == AVAssetReaderStatusCompleted){
        // You're done. It worked.
        
        finalImage = [self audioImageLogGraph:(Float32 *) fullSongData.bytes
                                    normalizeMax:normalizeMax
                                     sampleCount:fullSongData.length / (sizeof(Float32) * 2)
                                    channelCount:2
                                     imageHeight:100];
        
    }
    
    [fullSongData release];
    [reader release];
    
    return finalImage;
}

@end
