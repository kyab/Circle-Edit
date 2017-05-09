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
//    [_waveView becomeFirstResponder];
    
    [(MainView *)[self view] setDragDrop:self action:@selector(onDragDrop:) tryAction:@selector(onTryDragDrop:)];
    
    //[_waveView setSelectionUpdateNotify:self action:@selector(onSelectionUpdated:startFrom:end:noLoopPlayFrom:)];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    
    //[_overlayView setFrame:_waveView.frame];
    
    
    //receive scroll view change notification;
    NSClipView *contentView = [_scrollView contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didScroll:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:contentView];
    
    
    [self syncOutline];
    
    [_waveView2 setDelegate:(id<WaveView2Delegate>)self];
    [_outlineView setDelegate:(id<OutlineViewDelegate>)self];
    
    ae = [[AudioEngine alloc] init];
    if ([ae initialize]){
        NSLog(@"AudioEngine initialized");
    }
    
    [ae setRenderDelegate:(id<AudioEngineDelegate>)self];
    
}

- (void)waveView2ZoomChanged{
    [self syncOutline];
    [_waveView2 resetPaths];
    [_waveView2 setNeedsDisplay:YES];
    
}

-(void)outlineViewScrolled{
    _scrollingByOutline = YES;
    
    CGFloat xRateInOutline = [_outlineView currentX] / _outlineView.bounds.size.width;
    NSPoint toPoint = NSMakePoint(xRateInOutline * _waveView2.bounds.size.width , 0);
    [_waveView2 scrollPoint:toPoint];
    
    
}

- (void)syncOutline{

    CGFloat currentXRate = _scrollView.contentView.bounds.origin.x
        / _waveView2.bounds.size.width;         
    CGFloat currentWidthRate = _scrollView.contentView.bounds.size.width
        / _waveView2.bounds.size.width;
    
    [_outlineView setPosition:(CGFloat)currentXRate width:(double)currentWidthRate];
    
}


- (void)didScroll:(NSNotification *)notification{
    //NSClipView *contentView = [notification object];
    //NSLog(@"notification : %f, %f",contentView.bounds.origin.x, contentView.bounds.size.width);
    if (_scrollingByOutline){
        _scrollingByOutline = NO;
    }else{
        [self syncOutline];
    }
}

- (OSStatus) renderOutput:(AudioUnitRenderActionFlags *)ioActionFlags inTimeStamp:(const AudioTimeStamp *) inTimeStamp inBusNumber:(UInt32) inBusNumber inNumberFrames:(UInt32)inNumberFrames ioData:(AudioBufferList *)ioData{
    
    
    {
        static UInt32 count = 0;
        if ((count % 100) == 0){
//            NSLog(@"AppController outCallback inNumberFrames = %u", inNumberFrames);
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
    
    [self onTimer:nil];
    
    return noErr;
}

-(void)onTimer:(NSTimer *)t;
{
    
    if ([ae isPlaying]){
        //[_overlayView setPlayingFrameRate:((double)(_playingFrame))/_buffer_len];
        [_waveView2 setPlayingFrameRate:((double)(_playingFrame))/_buffer_len];
    }
    
}


-(void)onSelectionUpdated:(BOOL)bSelected startFrom:(double)startRatio
                      end:(double)endRatio noLoopPlayFrom:(double)noLoopPlayFromRate{

    NSLog(@"bSelected:%u startFrom:%.3f, end:%.3f", bSelected, startRatio , endRatio);
    _bSelected = bSelected;
    _loopStartFrame = (UInt32)(_buffer_len * startRatio);
    _loopEndFrame = (UInt32)(_buffer_len * endRatio);
    _noLoopStartFrame = (UInt32)(_buffer_len * noLoopPlayFromRate);
}


- (void)waveView2SelectionUpdated:(BOOL)bSelected loopStartXRate:(double)startXRate
                     loopEndXRate:(double)endXRate currentXRate:(double)currentXRate{
    
    _bSelected = bSelected;
    _loopStartFrame = (UInt32)(_buffer_len * startXRate);
    _loopEndFrame = (UInt32)(_buffer_len * endXRate);
    _noLoopStartFrame = (UInt32)(_buffer_len * currentXRate);
    
}


- (BOOL)onDragDrop:(NSString *)path{
    return [self loadFile:path];
}

- (BOOL)onTryDragDrop:(NSString *)path{
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
        [_waveView2 setIsPlaying:NO];
        
    }else{
        if (_bSelected){
            _playingFrame = _loopStartFrame;
        }else{
            _playingFrame = _noLoopStartFrame;
        }
        [_waveView2 setPlayingFrameRate:(double)(_playingFrame)/_buffer_len];
        [_waveView2 setIsPlaying:YES];
        [ae start];
        [_btnStartStop setTitle:@"Stop"];
    }
}

- (BOOL)tryLoadFile:(NSString *)path {
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


-(BOOL)loadFile:(NSString *)path{
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
        }
    }
    free(bufferList);
    
    NSLog(@"load file OK : %@", path);
    
    
    _loopStartFrame = 0;
    _loopEndFrame = 0;
    _noLoopStartFrame = 0;
    _playingFrame = 0;
    _bSelected = 0;
    
    [_waveView2 setBuffer:_leftBuf right:_rightBuf len:_buffer_len];
    
    
    return YES;
}



-(BOOL)saveFile:(NSURL *)fileURL{
    OSStatus ret = noErr;
    ExtAudioFileRef extAudioFile;

    
    AudioStreamBasicDescription fileformat = {0};
    fileformat.mFormatID = kAudioFormatLinearPCM;
    fileformat.mSampleRate = 44100.0;
    fileformat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    fileformat.mBytesPerPacket = 4;
    fileformat.mFramesPerPacket = 1;
    fileformat.mBytesPerFrame = 4;
    fileformat.mChannelsPerFrame = 2;
    fileformat.mBitsPerChannel=16;
    
    
    
    CFURLRef urlRef = CFBridgingRetain(fileURL);
    ret = ExtAudioFileCreateWithURL(urlRef,
                                    kAudioFileWAVEType,
                                    &fileformat,
                                    NULL,
                                    0,
                                    &extAudioFile);
    if (FAILED(ret)){
        NSError *err = [NSError errorWithDomain:NSOSStatusErrorDomain code:ret userInfo:nil];
        NSLog(@"Failed ExtAudioFileCreateWithURL err=%d(%@)", ret, [err description]);
        return NO;
    }
    if (extAudioFile == 0){
        NSError *err = [NSError errorWithDomain:NSOSStatusErrorDomain code:ret userInfo:nil];
        NSLog(@"Failed to create file err=%d(%@)", ret, [err description]);
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
                                  kExtAudioFileProperty_ClientDataFormat, sizeof(asbd), &asbd);
    
    if (FAILED(ret)){
        NSError *err = [NSError errorWithDomain:NSOSStatusErrorDomain code:ret userInfo:nil];
        NSLog(@"Failed to set client format err=%d(%@)", ret, [err description]);
        return NO;
    }
    
    //from RecordAudioToFile sample.
    AudioBufferList *bufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList) +  sizeof(AudioBuffer)); // for 2 buffers for left and right
    bufferList->mNumberBuffers = 2;
    bufferList->mBuffers[0].mData = &(_leftBuf[_loopStartFrame]);
    bufferList->mBuffers[1].mData = &(_rightBuf[_loopStartFrame]);
    bufferList->mBuffers[0].mNumberChannels = 1;
    bufferList->mBuffers[1].mNumberChannels = 1;
    bufferList->mBuffers[0].mDataByteSize = sizeof(float) * (_loopEndFrame - _loopStartFrame);
    bufferList->mBuffers[1].mDataByteSize = sizeof(float) * (_loopEndFrame - _loopStartFrame);

    ret = ExtAudioFileWrite(extAudioFile, _loopEndFrame - _loopStartFrame, bufferList);
    if (FAILED(ret)){
        NSError *err = [NSError errorWithDomain:NSOSStatusErrorDomain code:ret userInfo:nil];
        NSLog(@"Failed to write wave data err=%d(%@)", ret, [err description]);
        return NO;
    }
    
    
    
    ExtAudioFileDispose(extAudioFile);
    
    NSLog(@"save file OK : %@", fileURL);
    return YES;
}



//save selection as external file
- (IBAction)saveDocumentAs:(id)sender {
    NSLog(@"save as ");

    NSSavePanel *savePanel = [NSSavePanel savePanel];
    NSArray *allowedFileTypes = [NSArray arrayWithObjects:@"wav",@"aiff",nil];
    [savePanel setAllowedFileTypes:allowedFileTypes];
    [savePanel setTitle:@"save selection as.."];
    [savePanel setExtensionHidden:NO];
    NSInteger pressedButton = [savePanel runModal];
    
    
    if (pressedButton == NSFileHandlingPanelOKButton) {
        NSURL *fileURL = [savePanel URL];
        if (![self saveFile:fileURL]){
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"save error"];
            [alert setInformativeText:[NSString stringWithFormat:@"error on save as %@",fileURL.path]];
            [alert setAlertStyle:NSAlertStyleCritical];
            [alert runModal];
        }
    }
}


-(BOOL)validateMenuItem:(NSMenuItem *)item{
    if ([[item identifier] isEqualToString:@"saveAs"]){
        if (_buffer_len > 0){
            if (_bSelected){
                return YES;
            }
        }
    }
    return NO;
}


@end
