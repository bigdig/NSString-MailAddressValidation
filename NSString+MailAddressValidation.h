//
//  NSString+MailAddressValidation.h
//
//  Created by @peace3884 on 12/10/29.
//

#import <Foundation/Foundation.h>

@interface NSString (MailAddressValidation)

- (BOOL)isMailAddress;
- (BOOL)isOnlyHalf;
- (NSString *)stringByURLEncoding:(NSStringEncoding)encoding;

@end
