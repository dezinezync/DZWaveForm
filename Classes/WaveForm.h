//
//  WaveForm.h
//  DZWaveForm
//
//  Created by Nikhil Nigade on 18/11/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface WaveForm : NSObject

//-(id)initWithUrl:(NSURL*)url;
-(NSData *)renderPNGAudioPictogramLogForAsset:(AVURLAsset *)songAsset;

@end
