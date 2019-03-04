//
//  PJSecurity.h
//  PJBlockchainDemo
//
//  Created by PlatoJobs on 2019/3/4.
//  Copyright © 2019 David. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSException.h>
#import <CommonCrypto/CommonDigest.h>
@interface PJSecurityResult : NSObject

@property (strong, nonatomic, readonly) NSData *data;
@property (strong, nonatomic, readonly) NSString *utf8String;
@property (strong, nonatomic, readonly) NSString *hex;
@property (strong, nonatomic, readonly) NSString *hexLower;
@property (strong, nonatomic, readonly) NSString *base64;

- (id)initWithBytes:(unsigned char[])initData length:(NSUInteger)length;

@end


NS_ASSUME_NONNULL_BEGIN



@interface PJSecurity : NSObject

#pragma mark - AES Encrypt
+ (PJSecurityResult *)aesEncrypt:(NSString *)data key:(NSString *)key;
+ (PJSecurityResult *)aesEncrypt:(NSString *)data hexKey:(NSString *)key hexIv:(NSString *)iv;
+ (PJSecurityResult *)aesEncrypt:(NSString *)data key:(NSData *)key iv:(NSData *)iv;
+ (PJSecurityResult *)aesEncryptWithData:(NSData *)data key:(NSData *)key iv:(NSData *)iv;
#pragma mark AES Decrypt
+ (PJSecurityResult *)aesDecryptWithBase64:(NSString *)data key:(NSString *)key;
+ (PJSecurityResult *)aesDecryptWithBase64:(NSString *)data hexKey:(NSString *)key hexIv:(NSString *)iv;
+ (PJSecurityResult *)aesDecryptWithBase64:(NSString *)data key:(NSData *)key iv:(NSData *)iv;
+ (PJSecurityResult *)aesDecryptWithData:(NSData *)data key:(NSData *)key iv:(NSData *)iv;

#pragma mark - MD5
+ (PJSecurityResult *)md5:(NSString *)hashString;
+ (PJSecurityResult *)md5WithData:(NSData *)hashData;
#pragma mark HMAC-MD5
+ (PJSecurityResult *)hmacMd5:(NSString *)hashString hmacKey:(NSString *)key;
+ (PJSecurityResult *)hmacMd5WithData:(NSData *)hashData hmacKey:(NSString *)key;

#pragma mark - SHA
+ (PJSecurityResult *)sha1:(NSString *)hashString;
+ (PJSecurityResult *)sha1WithData:(NSData *)hashData;
+ (PJSecurityResult *)sha224:(NSString *)hashString;
+ (PJSecurityResult *)sha224WithData:(NSData *)hashData;
+ (PJSecurityResult *)sha256:(NSString *)hashString;
+ (PJSecurityResult *)sha256WithData:(NSData *)hashData;
+ (PJSecurityResult *)sha384:(NSString *)hashString;
+ (PJSecurityResult *)sha384WithData:(NSData *)hashData;
+ (PJSecurityResult *)sha512:(NSString *)hashString;
+ (PJSecurityResult *)sha512WithData:(NSData *)hashData;
#pragma mark HMAC-SHA
+ (PJSecurityResult *)hmacSha1:(NSString *)hashString hmacKey:(NSString *)key;
+ (PJSecurityResult *)hmacSha1WithData:(NSData *)hashData hmacKey:(NSString *)key;
+ (PJSecurityResult *)hmacSha224:(NSString *)hashString hmacKey:(NSString *)key;
+ (PJSecurityResult *)hmacSha224WithData:(NSData *)hashData hmacKey:(NSString *)key;
+ (PJSecurityResult *)hmacSha256:(NSString *)hashString hmacKey:(NSString *)key;
+ (PJSecurityResult *)hmacSha256WithData:(NSData *)hashData hmacKey:(NSString *)key;
+ (PJSecurityResult *)hmacSha384:(NSString *)hashString hmacKey:(NSString *)key;
+ (PJSecurityResult *)hmacSha384WithData:(NSData *)hashData hmacKey:(NSString *)key;
+ (PJSecurityResult *)hmacSha512:(NSString *)hashString hmacKey:(NSString *)key;
+ (PJSecurityResult *)hmacSha512WithData:(NSData *)hashData hmacKey:(NSString *)key;
@end


#pragma mark - PJSecurityEncoder
@interface PJSecurityEncoder : NSObject
- (NSString *)base64:(NSData *)data;
- (NSString *)hex:(NSData *)data useLower:(BOOL)isOutputLower;
@end


#pragma mark - PJSecurityDecoder
@interface PJSecurityDecoder : NSObject
- (NSData *)base64:(NSString *)data;
- (NSData *)hex:(NSString *)data;

@end

NS_ASSUME_NONNULL_END
