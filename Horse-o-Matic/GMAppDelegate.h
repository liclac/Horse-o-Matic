//
//  GMAppDelegate.h
//  Horse-o-Matic
//
//  Created by Johannes Ekberg on 2013-05-02.
//  Copyright (c) 2013 MacaroniCode. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GMAppDelegate : NSObject <NSApplicationDelegate, NSURLConnectionDelegate, NSSpeechSynthesizerDelegate>

@property (retain) NSStatusItem *statusItem;
@property (assign) IBOutlet NSMenu *menu, *voiceMenu;
@property (assign) IBOutlet NSMenuItem *startMenuItem, *stopMenuItem;

@property (retain) NSSpeechSynthesizer *synthesizer;
@property (assign) BOOL isHorsing;

@property (retain) NSURLConnection *connection;
@property (retain) NSMutableData *buffer;
@property (retain) NSMutableArray *paragraphs;

- (void)setupStatusItem;
- (void)setupVoice;

- (void)fetch;

- (IBAction)startHorsing:(id)sender;
- (IBAction)stopHorsing:(id)sender;

@end
