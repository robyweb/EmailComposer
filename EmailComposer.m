//
//  EmailComposer.m
// 
//
//  Created by Jesse MacFadyen on 10-04-05.
//  Copyright 2010 Nitobi. All rights reserved.
//

#define RETURN_CODE_EMAIL_CANCELLED 0
#define RETURN_CODE_EMAIL_SAVED 1
#define RETURN_CODE_EMAIL_SENT 2
#define RETURN_CODE_EMAIL_FAILED 3
#define RETURN_CODE_EMAIL_NOTSENT 4

#import "EmailComposer.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface EmailComposer ()

-(void) showEmailComposerWithParameters:(NSDictionary*)parameters;
-(void) returnWithCode:(int)code;

@end

@implementation EmailComposer

- (void) showEmailComposer:(CDVInvokedUrlCommand*)command {
    NSDictionary *parameters = [command.arguments objectAtIndex:0];
    [self showEmailComposerWithParameters:parameters];
}

-(void) showEmailComposerWithParameters:(NSDictionary*)parameters {
    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    
	// set subject
    @try {
        NSString* subject = [parameters objectForKey:@"subject"];
        if (subject) {
            [mailComposer setSubject:subject];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EmailComposer - Cannot set subject; error: %@", exception);
    }
    
    // set body
    @try {
        NSString* body = [parameters objectForKey:@"body"];
        BOOL isHTML = [[parameters objectForKey:@"bIsHTML"] boolValue];
        if(body) {
            [mailComposer setMessageBody:body isHTML:isHTML];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EmailComposer - Cannot set body; error: %@", exception);
    }
    
	// Set recipients
    @try {
        NSArray* toRecipientsArray = [parameters objectForKey:@"toRecipients"];
        if(toRecipientsArray) {
            [mailComposer setToRecipients:toRecipientsArray];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EmailComposer - Cannot set TO recipients; error: %@", exception);
    }
    
    @try {
        NSArray* ccRecipientsArray = [parameters objectForKey:@"ccRecipients"];
        if(ccRecipientsArray) {
            [mailComposer setCcRecipients:ccRecipientsArray];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EmailComposer - Cannot set CC recipients; error: %@", exception);
    }
    
    @try {
        NSArray* bccRecipientsArray = [parameters objectForKey:@"bccRecipients"];
        if(bccRecipientsArray) {
            [mailComposer setBccRecipients:bccRecipientsArray];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EmailComposer - Cannot set BCC recipients; error: %@", exception);
    }
    
    if (mailComposer != nil) {
        [self.viewController presentModalViewController:mailComposer animated:YES];
    } else {
        [self returnWithCode:RETURN_CODE_EMAIL_NOTSENT];
    }
    //[mailComposer release];
}

// Dismisses the email composition interface when users tap Cancel or Send.
// Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    // Notifies users about errors associated with the interface
	int webviewResult = 0;
    
    switch (result) {
        case MFMailComposeResultCancelled:
			webviewResult = RETURN_CODE_EMAIL_CANCELLED;
            break;
        case MFMailComposeResultSaved:
			webviewResult = RETURN_CODE_EMAIL_SAVED;
            break;
        case MFMailComposeResultSent:
			webviewResult =RETURN_CODE_EMAIL_SENT;
            break;
        case MFMailComposeResultFailed:
            webviewResult = RETURN_CODE_EMAIL_FAILED;
            break;
        default:
			webviewResult = RETURN_CODE_EMAIL_NOTSENT;
            break;
    }
    
    [controller dismissModalViewControllerAnimated:YES];
    [self returnWithCode:webviewResult];
}

// Call the callback with the specified code
-(void) returnWithCode:(int)code {
    [self writeJavascript:[NSString stringWithFormat:@"window.plugins.emailComposer._didFinishWithResult(%d);", code]];
}

@end



