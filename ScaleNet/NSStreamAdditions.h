//
//  NSStreamAdditions.h
//  giftexchange
//
//  Created by Donald Wilson on 5/21/11.
//  Copyright 2011 wilsonware.com. All rights reserved.
//
//#import 

@interface NSStream (MyAdditions)

+ (void)getStreamsToHostNamed:(NSString *)hostName 
                         port:(NSInteger)port 
                  inputStream:(NSInputStream **)inputStreamPtr 
                 outputStream:(NSOutputStream **)outputStreamPtr;

@end