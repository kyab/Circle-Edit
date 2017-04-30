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
    
    [_waveView setSelectionUpdateNotify:self action:@selector(onSelectionUpdated:startFrom:end:)];

    ae = [[AudioEngine alloc] init];
    if ([ae initialize]){
        NSLog(@"AudioEngine initialized");
    }
    
    [ae setRenderDelegate:(id<AudioEngineDelegate>)self];
    
}

- (OSStatus) renderOutput:(AudioUnitRenderActionFlags *)ioActionFlags inTimeStamp:(const AudioTimeStamp *) inTimeStamp inBusNumber:(UInt32) inBusNumber inNumberFrames:(UInt32)inNumberFrames ioData:(AudioBufferList *)ioData{
    
    
    {
        static UInt32 count = 0;
        if ((count % 100) == 0){
            NSLog(@"AppController outCallback inNumberFrames = %u", inNumberFrames);
        }
        count++;
    }
    
    
    if (_buffer_len == 0){
        //zero output
        UInt32 sampleNum = inNumberFrames;
        float *pLeft = (float *)ioData->mBuffers[0].mData;
        float *pRight = (float *)ioData->mBuffers[1].mData;
        bzero(pLeft,sizeof(float)*sampleNum );
        bzero(pRight,sizeof(float)*sampleNum );
        return noErr;
    }
    
    UInt32 firstCopy_num = inNumberFrames;
    UInt32 secondCopy_num = 0;
    if (_bSelected){
        if ( _playingFrame > _loopEndFrame){
            firstCopy_num = 0;
            secondCopy_num = inNumberFrames;
        }else if ( _playingFrame + firstCopy_num > _loopEndFrame ) {
            firstCopy_num = _loopEndFrame - _playingFrame;
            secondCopy_num = inNumberFrames - firstCopy_num;
        }
    }else{
        if ( _playingFrame + firstCopy_num > _buffer_len){
            firstCopy_num = _buffer_len - _playingFrame;
            secondCopy_num = inNumberFrames - firstCopy_num;
        }
    }
    
    memcpy(ioData->mBuffers[0].mData,
               &(_leftBuf[_playingFrame]), firstCopy_num*sizeof(float));
    memcpy(ioData->mBuffers[1].mData,
               &(_rightBuf[_playingFrame]), firstCopy_num*sizeof(float));
    
    if (secondCopy_num > 0){
        UInt32 from = 0;
        if (_bSelected) from = _loopStartFrame;
        memcpy(ioData->mBuffers[0].mData+firstCopy_num*sizeof(float),
               &(_leftBuf[from]), secondCopy_num*sizeof(float));
        memcpy(ioData->mBuffers[1].mData+firstCopy_num*sizeof(float),
               &(_rightBuf[from]), secondCopy_num*sizeof(float));
        
        _playingFrame = from + secondCopy_num;
    }else{
        _playingFrame += firstCopy_num;
    }
    
    
    return noErr;
}



-(void)onSelectionUpdated:(Boolean)bSelected startFrom:(double)startRatio end:(double)endRatio{
    ;
    NSLog(@"bSelected:%u startFrom:%.3f, end:%.3f", bSelected, startRatio , endRatio);
    _bSelected = bSelected;
    _loopStartFrame = (UInt32)(_buffer_len * startRatio);
    _loopEndFrame = (UInt32)(_buffer_len * endRatio);
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

- (IBAction)onStartStop:(id)sender {
    if ([ae isPlaying]){
        [ae stop];
        [_btnStartStop setTitle:@"Play"];
    }else{
        if (_bSelected){
            _playingFrame = _loopStartFrame;
        }else{
            _playingFrame = 0;
        }
        [ae start];
        [_btnStartStop setTitle:@"Stop"];
    }
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
//            NSLog(@"loaded :%% %f", currentFrame/(float)totalFrame);
        }
    }
    free(bufferList);
    
    [_waveView setBuffer:_leftBuf right:_rightBuf len:_buffer_len];
    
    
    NSLog(@"load file OK : %@", path);
    return YES;
}




@end
