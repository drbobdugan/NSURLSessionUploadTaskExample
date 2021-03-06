//
//  ViewController.m
//  NSURLSessionUploadTaskExample
//
//  Created by Bob Dugan on 10/16/15.
//  Copyright © 2015 Bob Dugan. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "BackgroundTimeRemainingUtility.h"

@interface ViewController ()

@end

@implementation ViewController 

//
// From UIViewController
//
- (void)viewDidLoad {
    [super viewDidLoad];
}

//
// From UIViewController
//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//
// From UIViewController
//
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

//
// Start Button UI event handler
//
- (IBAction)buttonPressed:(id)sender
{
    static Boolean first=TRUE;
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Initialize start time to compute duration later
    _startTime = [NSDate date];
    
    // Initialize UI fields
    self.state.text = @"Uploading";
    self.time.text = @"0";
    self.uploadPercentage.text = @"0";
    
    // Execute this initialization code one time only
    if (first)
    {
        first = FALSE;
        
        // Generate a unique id for the session
        NSString * uniqueId = [NSString stringWithFormat:@"stonehill.edu.NSURLSessionUploadTaskExample:%f",[[NSDate date] timeIntervalSince1970] * 1000];

        // Initialize BACKGROUND session by constructing a NSURLSessionConfiguration
        NSURLSessionConfiguration *configuration =  [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:uniqueId];
        configuration.allowsCellularAccess = NO;
        
        // Create the session
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    
    //
    // Configure upload task
    // NOTE: You need an HTTP server to respond to the upload task request.  My server is a very basic python script that is waiting for a POST.
    //
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@", self.domainIP.text, self.port.text]];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    
    // The file that is being upload is hardcoded here and is part of the project.  To add your own file:
    // - use the Finder to drag the file to the xcode project
    // - Target -> Build Phases -> Copy Bundle Resources -> +
    // - change -> pathForResource:@"sailing" ofType:@"pdf" to the filename and type of your file
    NSString *filePath = [NSString stringWithFormat:@"file://%@", [[NSBundle mainBundle] pathForResource:@"sailing" ofType:@"pdf"]];
    NSURLSessionUploadTask* uploadTask = [self.session uploadTaskWithRequest:urlRequest fromFile:[NSURL URLWithString:filePath]];
    
    // Start upload task
    [uploadTask resume];
}


//
// Delegate of NSURLSessionDelegate (NOT CALLED IN THIS EXAMPLE)
//
- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition,
                             NSURLCredential *credential))completionHandler
{
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

//
// Delegate of NSURLSessionDelegate
//
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

//
// Delegate of NSURLSessionDelegate
//
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.backgroundCompletionHandler) {
        appDelegate.backgroundCompletionHandler();
        appDelegate.backgroundCompletionHandler = nil;
    }
    
    // If we are not in the "active" or foreground then log some background information to the console
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive)
    {
        [BackgroundTimeRemainingUtility NSLog];
    }
}

//
// Delegate of NSURLSessionDataDelegate (NOT CALLED IN THIS EXAMPLE)
//
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    //Tells the delegate that the data task received the initial reply (headers) from the server.
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

//
// Delegate of NSURLSessionDataDelegate (NOT CALLED IN THIS EXAMPLE)
//
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    // Called when task switches to a download task (not applicable for this upload example)
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

//
// Delegate of NSURLSessionDataDelegate
//
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    // Called when data task has received some data (not applicable for straight upload?)
    if (data != NULL)
    {
        NSLog(@"%s: %@", __PRETTY_FUNCTION__,[[NSString alloc]  initWithBytes:[data bytes] length:[data length] encoding: NSASCIIStringEncoding]);
    }
    else
    {
        NSLog(@"%s: but no actual data received.", __PRETTY_FUNCTION__);
    }
    
    // If we are not in the "active" or foreground then log some background information to the console
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive)
    {
        [BackgroundTimeRemainingUtility NSLog];
    }
}

//
// Delegate of NSURLSessionTaskDelegate
//
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        NSLog(@"%s %@ failed: %@", __PRETTY_FUNCTION__, task.originalRequest.URL, error);
    }
    else
    {
        NSLog(@"%s succeeded with response: %@",  __PRETTY_FUNCTION__, task.response);
    }
    
    // If we are not in the "active" or foreground then log some background information to the console
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive)
    {
        [BackgroundTimeRemainingUtility NSLog];
    }
}

//
// Delegate of NSURLSessionTaskDelegate (NOT CALLED IN THIS EXAMPLE)
//
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition,
                             NSURLCredential *credential))completionHandler
{
    // Requests credentials from the delegate in response to an authentication request from the remote server.
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

//
// Delegate of NSURLSessionTaskDelegate (NOT CALLED IN THIS EXAMPLE)
//
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    // Called when data task has the option to cache some data (not applicable to straight upload?)
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

//
// Delegate of NSURLSessionTaskDelegate
//
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    // Periodically informs the delegate of the progress of sending body content to the server.
    
    // Compute progress percentage
    float progress = (float)totalBytesSent / (float)totalBytesExpectedToSend;
    
    // Compute time executed so far
    NSDate *stopTime = [NSDate date];
    NSTimeInterval executionTime = [stopTime timeIntervalSinceDate:_startTime];
    
    // Send info to console
    NSLog(@"%s bytesSent = %lld, totalBytesSent: %lld, totalBytesExpectedToSend: %lld, progress %.3f, time (s): %.1f", __PRETTY_FUNCTION__, bytesSent, totalBytesSent, totalBytesExpectedToSend, progress*100, executionTime);
    
    // Update UI
    dispatch_block_t work_to_do = ^{
        self.uploadPercentage.text = [NSString stringWithFormat:@"%.3f", progress*100];
        self.time.text = [NSString stringWithFormat:@"%.1f",executionTime];
    };
    
    if ([NSThread isMainThread])
    {
        work_to_do();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), work_to_do);
    }
    
    // If we are not in the "active" or foreground then log some background information to the console
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive)
    {
        [BackgroundTimeRemainingUtility NSLog];
    }
}

//
// Delegate of NSURLSessionTaskDelegate  (NOT CALLED IN THIS EXAMPLE)
//
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
    //
    //This delegate method is called under two circumstances:
    //- To provide the initial request body stream if the task was created with uploadTaskWithStreamedRequest:
    //- To provide a replacement request body stream if the task needs to resend a request that has a body stream because of an authentication challenge or other recoverable serve error.
    //
     NSLog(@"%s", __PRETTY_FUNCTION__);
}


//
// Delegate of NSURLSessionTaskDelegate  (NOT CALLED IN THIS EXAMPLE)
//
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    // This method is called only for tasks in default and ephemeral sessions. Tasks in background sessions automatically follow redirects.
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end