//
//  GMAppDelegate.m
//  Horse-o-Matic
//
//  Created by Johannes Ekberg on 2013-05-02.
//  Copyright (c) 2013 MacaroniCode. All rights reserved.
//

#import "GMAppDelegate.h"

@implementation GMAppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self setupStatusItem];
	[self setupVoice];
	[self fetch];
}

- (void)setupStatusItem
{
	NSImage *statusImage = [NSImage imageNamed:@"StatusIcon"];
	[statusImage setSize:NSMakeSize(20, 20)];
	
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	//self.statusItem.title = @"H";
	self.statusItem.image = statusImage;
	self.statusItem.highlightMode = YES;
	self.statusItem.menu = self.menu;
	
	/*for (NSString *voice in [NSSpeechSynthesizer availableVoices]) {
		NSDictionary *dict = [NSSpeechSynthesizer attributesForVoice:voice];
		NSLog(@"%@ (%@, %@)", [dict objectForKey:NSVoiceName],
			  [dict objectForKey:NSVoiceGender], [dict objectForKey:NSVoiceAge]);
	}
	exit(0);*/
}

- (void)setupVoice
{
	self.synthesizer = [[NSSpeechSynthesizer alloc] initWithVoice:[NSSpeechSynthesizer defaultVoice]];
	self.synthesizer.delegate = self;
}

- (void)fetch
{
	self.connection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:
															  [NSURL URLWithString:@"http://horseebooksipsum.com/api/v1/5/"]]
													delegate:self];
	[self.connection start];
}

- (void)speakNext
{
	@synchronized(self.paragraphs)
	{
		[self.synthesizer startSpeakingString:[self.paragraphs lastObject]];
		[self.paragraphs removeLastObject];
		
		if([self.paragraphs count] <= 1) [self fetch];
	}
}

- (void)startHorsing:(id)sender
{
	[self speakNext];
	[self.startMenuItem setHidden:YES];
	[self.stopMenuItem setHidden:NO];
}

- (void)stopHorsing:(id)sender
{
	[self.synthesizer stopSpeaking];
	[self.startMenuItem setHidden:NO];
	[self.stopMenuItem setHidden:YES];
}

#pragma mark -
#pragma mark Connection
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"Received Response (%lld bytes expected)", response.expectedContentLength);
	self.buffer = [[NSMutableData alloc] initWithCapacity:MAX(response.expectedContentLength, 0)];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"Received %ld bytes", data.length);
	[self.buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *string = [[NSString alloc] initWithData:self.buffer encoding:NSUTF8StringEncoding];
	NSArray *newParagraphs = [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@"\n\n"];
	
	if(self.paragraphs) [self.paragraphs addObjectsFromArray:newParagraphs];
	else self.paragraphs = [newParagraphs mutableCopy];
	
	[newParagraphs release];
	
	NSLog(@"%@", self.paragraphs);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self stopHorsing:nil];
}

#pragma mark Synthesizer
- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didFinishSpeaking:(BOOL)finishedSpeaking
{
	[self stopHorsing:nil];
	if(finishedSpeaking) [self startHorsing:nil];
}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didEncounterErrorAtIndex:(NSUInteger)characterIndex ofString:(NSString *)string message:(NSString *)message
{
	[self stopHorsing:nil];
}

@end
