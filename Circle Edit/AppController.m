//
//  ViewController.m
//  Circle Edit
//
//  Created by kyab on 2017/04/12.
//  Copyright © 2017年 kyab. All rights reserved.
//

#import "AppController.h"
#import "MainView.h"

#import <AudioToolbox/AudioToolbox.h>

@implementation AppController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)awakeFromNib{
    NSLog(@"AppController awaken");
    [_waveView becomeFirstResponder];
    
    [(MainView *)[self view] setDragDrop:self action:@selector(onDragDrop:) tryAction:@selector(onTryDragDrop:)];
    
}

- (Boolean)onDragDrop:(NSString *)path{
    return [self loadFile:path];
}

- (Boolean)onTryDragDrop:(NSString *)path{
    return [self tryLoadFile:path];
}



- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (Boolean)tryLoadFile:(NSString *)path {
    OSStatus ret = noErr;
    ExtAudioFileRef extAudioFile;
    
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    CFURLRef urlRef = CFBridgingRetain(fileURL);
    ret = ExtAudioFileOpenURL(urlRef,&extAudioFile);
    if (FAILED(ret)){
        NSError *err = [NSError errorWithDomain:NSOSStatusErrorDomain code:ret userInfo:nil];
        NSLog(@"Failed ExtAudioFileOpenURL err=%d(%@)", ret, [err description]);
        return NO;
    }
    if (extAudioFile == 0){
        NSError *err = [NSError errorWithDomain:NSOSStatusErrorDomain code:ret userInfo:nil];
        NSLog(@"Failed to open file err=%d(%@)", ret, [err description]);
        return NO;
    }
    
    ret = ExtAudioFileSeek(extAudioFile, 0);
    if (FAILED(ret)){
        NSError *err = [NSError errorWithDomain:NSOSStatusErrorDomain code:ret userInfo:nil];
        NSLog(@"Failed to get format err=%d(%@)", ret, [err description]);
        return NO;
    }
    return YES;
}


-(Boolean)loadFile:(NSString *)path{
    OSStatus ret = noErr;
    ExtAudioFileRef extAudioFile;

    NSURL *fileURL = [NSURL fileURLWithPath:path];
    CFURLRef urlRef = CFBridgingRetain(fileURL);
    ret = ExtAudioFileOpenURL(urlRef,&extAudioFile);
    if (FAILED(ret)){
        NSError *err = [NSError errorWithDomain:NSOSStatusErrorDomain code:ret userInfo:nil];
        NSLog(@"Failed ExtAudioFileOpenURL err=%d(%@)", ret, [err description]);
        return NO;
    }
    if (extAudioFile == 0){
        NSError *err = [NSError errorWithDomain:NSOSStatusErrorDomain code:ret userInfo:nil];
        NSLog(@"Failed to open file err=%d(%@)", ret, [err description]);
        return NO;
    }
    
    ret = ExtAudioFileSeek(extAudioFile, 0);
    if (FAILED(ret)){
        NSError *err = [NSError errorWithDomain:NSOSStatusErrorDomain code:ret userInfo:nil];
        NSLog(@"Failed to get format err=%d(%@)", ret, [err description]);
        return NO;
    }
    
    AudioStreamBasicDescription inputFormat = {0};
    UInt32 size = sizeof(AudioStreamBasicDescription);
    ret = ExtAudioFileGetProperty(extAudioFile, kExtAudioFileProperty_FileDataFormat, &size, &inputFormat);
    if (FAILED(ret)){
        NSError *err = [NSError errorWithDomain:NSOSStatusErrorDomain code:ret userInfo:nil];
        NSLog(@"Failed to get format err=%d(%@)", ret, [err description]);
        return NO;
    }
    AudioStreamBasicDescription asbd = {0};
    asbd.mSampleRate = 44100.0;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
    asbd.mBytesPerPacket = 4;
    asbd.mFramesPerPacket = 1;
    asbd.mBytesPerFrame = 4;
    asbd.mChannelsPerFrame = 2;
    asbd.mBitsPerChannel = 32;
    
    ret = ExtAudioFileSetProperty(extAudioFile,
                                  kExtAudioFileProperty_ClientDataFormat, size, &asbd);
    
    if (FAILED(ret)){
        NSError *err = [NSError errorWithDomain:NSOSStatusErrorDomain code:ret userInfo:nil];
        NSLog(@"Failed to get format err=%d(%@)", ret, [err description]);
        return NO;
    }
    
    //from RecordAudioToFile sample.
    AudioBufferList *bufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList) +  sizeof(AudioBuffer)); // for 2 buffers for left and right
    bufferList->mNumberBuffers = 2;
    bufferList->mBuffers[0].mDataByteSize = 32 * 4096;
    bufferList->mBuffers[1].mDataByteSize = 32 * 4096;
    bufferList->mBuffers[0].mNumberChannels = 1;
    bufferList->mBuffers[1].mNumberChannels = 1;
    
    size = sizeof(SInt64);
    SInt64 totalFrame = 0;
    SInt64 currentFrame = 0;
    ret = ExtAudioFileGetProperty(extAudioFile, kExtAudioFileProperty_FileLengthFrames, &size, &totalFrame);
    
    _buffer_len = 0;
    
    while(true){
        UInt32 readSampleLen = 4096;
        bufferList->mBuffers[0].mData = &(_leftBuf[_buffer_len]);
        bufferList->mBuffers[1].mData = &(_rightBuf[_buffer_len]);
        ret = ExtAudioFileRead(extAudioFile, &readSampleLen, bufferList);
        _buffer_len += readSampleLen;
        if (readSampleLen == 0){
            NSLog(@"readed sample = %u", (unsigned int)_buffer_len);
            break;
        }else{
            ret = ExtAudioFileTell(extAudioFile, &currentFrame);
            NSLog(@"loaded :%% %f", currentFrame/(float)totalFrame);
        }
    }
    free(bufferList);
    
    [_waveView setBuffer:_leftBuf right:_rightBuf len:_buffer_len];
    
    
    NSLog(@"load file OK : %@", path);
    return YES;
}




@end
