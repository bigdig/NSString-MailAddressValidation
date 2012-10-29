//
//  NSString+MailAddressValidation.m
//
//  Created by @peace3884 on 12/10/29.
//

#import "NSString+MailAddressValidation.h"

@implementation NSString (MailAddressValidation)

- (BOOL)isMailAddress {
    
    //1.｢@｣が含まれている
    if ( [self rangeOfString:@"@"].location != NSNotFound ) {
        
        //2.「@」が1個だけ含まれている
        NSMutableArray *resultArray = [NSMutableArray array];
        NSError *error = nil;
        
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"@"
                                                                                options:0
                                                                                  error:&error];
        
        NSArray *matchs = [regexp matchesInString:self
                                          options:0
                                            range:NSMakeRange(0,
                                                              self.length)];
        
        if ( !error ) {
            
            for ( NSTextCheckingResult *result in matchs ) {
                
                [resultArray addObject:[self substringWithRange:result.range]];
            }
        }
        
        if ( resultArray.count == 1 ) {
            
            //3.最初の文字が「@」ではない
            if ( ![self hasPrefix:@"@"] ) {
                
                //4.最後の文字が「@」ではない
                if ( ![self hasSuffix:@"@"] ) {
                    
                    //5.2byte 文字が含まれていない
                    if ( [self isOnlyHalf] ) {
                        
                        //6.「@」以降に必ず一つは「.」が含まれている
                        NSString *temp = [self substringFromIndex:[self rangeOfString:@"@"].location];
                        
                        if ( [temp rangeOfString:@"."].location != NSNotFound ) {
                            
                            //7.「@」以降の「.」が最後の文字ではない
                            if ( ![[self substringFromIndex:[self rangeOfString:@"@"].location] hasSuffix:@"."] ) {
                                
                                //8.「@」直後が「.」ではない
                                if ( [self rangeOfString:@"@."].location == NSNotFound ) {
                                    
                                    //9.「@」より前が「a-zA-Z0-9」と「./_?-」で構成されている
                                    temp = [self substringToIndex:[self rangeOfString:@"@"].location];
                                    
                                    regexp = [NSRegularExpression regularExpressionWithPattern:@"[-\\./_\\?a-zA-Z0-9]+"
                                                                                       options:0
                                                                                         error:&error];
                                    
                                    NSTextCheckingResult *match = [regexp firstMatchInString:temp
                                                                                     options:0
                                                                                       range:NSMakeRange(0, temp.length)];
                                    
                                    if ( !error ) {
                                        
                                        if ( match.numberOfRanges != 0 ) {
                                            
                                            //10.最初の文字が「.」ではない
                                            if ( ![self hasSuffix:@"."] ) {
                                                
                                                //11.「@」以降が「a-zA-Z0-9」と「._-」で構成されている
                                                temp = [self substringFromIndex:[self rangeOfString:@"@"].location];
                                                
                                                regexp = [NSRegularExpression regularExpressionWithPattern:@"@[-_\\.a-zA-Z0-9]+"
                                                                                                   options:0
                                                                                                     error:&error];
                                                
                                                NSTextCheckingResult *match = [regexp firstMatchInString:temp
                                                                                                 options:0
                                                                                                   range:NSMakeRange(0, temp.length)];
                                                
                                                if ( !error ) {
                                                    
                                                    if ( match.numberOfRanges != 0 ) {
                                                        
                                                        //12.「@」以降が「.」と数字のみで構成されていない
                                                        regexp = [NSRegularExpression regularExpressionWithPattern:@"@[\\.0-9]+"
                                                                                                           options:0
                                                                                                             error:&error];
                                                        
                                                        NSTextCheckingResult *match = [regexp firstMatchInString:temp
                                                                                                         options:0
                                                                                                           range:NSMakeRange(0, temp.length)];
                                                        
                                                        if ( !error ) {
                                                            
                                                            if ( match.numberOfRanges == 0 ) {
                                                                
                                                                //13.「@」以降「a-zA-Z0-9」以外の文字が連続していない
                                                                if ( [temp rangeOfString:@".."].location == NSNotFound &&
                                                                     [temp rangeOfString:@"__"].location == NSNotFound &&
                                                                     [temp rangeOfString:@"--"].location == NSNotFound ) {
                                                                    
                                                                    //メールアドレスとして正当である
                                                                    return YES;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //メールアドレスとして正当ではない
    return NO;
}

- (BOOL)isOnlyHalf {
    
    for( int i=0; i < [self length]; i++ ) {
        
        NSString *aChar = [self substringWithRange:NSMakeRange(i, 1)];
        NSString *encodedChar = [aChar stringByURLEncoding:NSUTF8StringEncoding];
        
        if ( [encodedChar length] < 4 ) {
            
            //1byte文字
            continue;
            
        }else if ( [encodedChar length] > 4  && [encodedChar isEqualToString:@"\""] ) {
            
            //2byte文字だが｢"｣は除外する
            continue;
            
        }else {
            
            //2byte文字が含まれている
            return NO;
        }
    }
    
    //1byte文字だけである
    return YES;
}

- (NSString *)stringByURLEncoding:(NSStringEncoding)encoding {
    
    //記号のエスケープを行う
    
    NSArray *escapeChars = [NSArray arrayWithObjects:
                            @";" ,@"/" ,@"?" ,@":"
                            ,@"@" ,@"&" ,@"=" ,@"+"
                            ,@"$" ,@"," ,@"[" ,@"]"
                            ,@"#" ,@"!" ,@"'" ,@"("
                            ,@")" ,@"*"
                            ,nil];
    
    NSArray *replaceChars = [NSArray arrayWithObjects:
                             @"%3B" ,@"%2F" ,@"%3F"
                             ,@"%3A" ,@"%40" ,@"%26"
                             ,@"%3D" ,@"%2B" ,@"%24"
                             ,@"%2C" ,@"%5B" ,@"%5D"
                             ,@"%23" ,@"%21" ,@"%27"
                             ,@"%28" ,@"%29" ,@"%2A"
                             ,nil];
    
    NSMutableString *encodedString = [[self stringByAddingPercentEscapesUsingEncoding:encoding] mutableCopy];
    
    for( int i=0; i < [escapeChars count]; i++ ) {
        
        [encodedString replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
                                       withString:[replaceChars objectAtIndex:i]
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, [encodedString length])];
    }
    
    return [NSString stringWithString: encodedString];
}

@end
