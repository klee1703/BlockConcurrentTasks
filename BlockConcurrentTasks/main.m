//
//  main.m
//  BlockConcurrentTasks
//
//  Created by Keith Lee on 4/28/13.
//  Copyright (c) 2013 Keith Lee. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//   1. Redistributions of source code must retain the above copyright notice, this list of
//      conditions and the following disclaimer.
//
//   2. Redistributions in binary form must reproduce the above copyright notice, this list
//      of conditions and the following disclaimer in the documentation and/or other materials
//      provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY Keith Lee ''AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Keith Lee OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Keith Lee.

#import <Foundation/Foundation.h>
#define YahooURL       @"http://www.yahoo.com/index.html"
#define ApressURL      @"http://www.apress.com/index.html"

typedef void (^DownloadURL)(void);

/* Retrieve a block used to download a URL */
DownloadURL getDownloadURLBlock(NSString *url)
{
  NSString *urlString = url;
  return ^{
    // Downloads a URL
    NSURLRequest *request = [NSURLRequest
                             requestWithURL:[NSURL URLWithString:urlString]];
    NSError *error;
    NSDate *startTime = [NSDate date];
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:nil
                                                     error:&error];
    if (data == nil)
    {
      NSLog(@"Error loading request %@", [error localizedDescription]);
    }
    else
    {
      NSDate *endTime = [NSDate date];
      NSTimeInterval timeInterval = [endTime timeIntervalSinceDate:startTime];
      NSLog(@"Time taken to download %@ = %f seconds", urlString, timeInterval);
    }
  };
}

int main(int argc, const char * argv[])
{
  @autoreleasepool
  {
    // Create queues for tasks
    dispatch_queue_t queue1 =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t queue2 =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // Create a task group
    dispatch_group_t group = dispatch_group_create();
    
    // Get current time for metrics
    NSDate *startTime = [NSDate date];
    
    // Now create and dispatch async tasks
    dispatch_group_async(group, queue1, getDownloadURLBlock(YahooURL));
    dispatch_group_async(group, queue2, getDownloadURLBlock(ApressURL));
    
    // Block until all tasks from group are completed
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    // Retrieve time taken for concurrent execution and log
    NSDate *endTime = [NSDate date];
    NSTimeInterval timeInterval = [endTime timeIntervalSinceDate:startTime];
    NSLog(@"Time taken to download URLs concurrently = %f seconds", timeInterval);
  }
  return 0;
}

