//
//  PJSecurity.m
//  PJBlockchainDemo
//
//  Created by PlatoJobs on 2019/3/4.
//  Copyright © 2019 David. All rights reserved.
//

#import "PJSecurity.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import "Base64.h"


#pragma mark - PJSecurityResult
@implementation PJSecurityResult

@synthesize data = _data;

#pragma mark - Init
- (id)initWithBytes:(unsigned char[])initData length:(NSUInteger)length
{
    self = [super init];
    if (self) {
        _data = [NSData dataWithBytes:initData length:length];
    }
    return self;
}

#pragma mark UTF8 String
// convert PJSecurityResult to UTF8 string
- (NSString *)utf8String
{
    NSString *result = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    return result;
}

#pragma mark HEX
// convert PJSecurityResult to HEX string
- (NSString *)hex
{
    PJSecurityEncoder *encoder = [PJSecurityEncoder new];
    return [encoder hex:_data useLower:false];
}
- (NSString *)hexLower
{
    PJSecurityEncoder *encoder = [PJSecurityEncoder new];
    return [encoder hex:_data useLower:true];
}

#pragma mark Base64
// convert PJSecurityResult to Base64 string
- (NSString *)base64
{
    PJSecurityEncoder *encoder = [PJSecurityEncoder new];
    return [encoder base64:_data];
}

@end



@implementation PJSecurity

#pragma mark - AES Encrypt
// default AES Encrypt, key -> SHA384(key).sub(0, 32), iv -> SHA384(key).sub(32, 16)
+ (PJSecurityResult *)aesEncrypt:(NSString *)data key:(NSString *)key
{
    PJSecurityResult * sha = [self sha384:key];
    NSData *aesKey = [sha.data subdataWithRange:NSMakeRange(0, 32)];
    NSData *aesIv = [sha.data subdataWithRange:NSMakeRange(32, 16)];
    
    return [self aesEncrypt:data key:aesKey iv:aesIv];
}
#pragma mark AES Encrypt 128, 192, 256
+ (PJSecurityResult *)aesEncrypt:(NSString *)data hexKey:(NSString *)key hexIv:(NSString *)iv
{
    PJSecurityDecoder *decoder = [PJSecurityDecoder new];
    NSData *aesKey = [decoder hex:key];
    NSData *aesIv = [decoder hex:iv];
    
    return [self aesEncrypt:data key:aesKey iv:aesIv];
}
+ (PJSecurityResult *)aesEncrypt:(NSString *)data key:(NSData *)key iv:(NSData *)iv
{
    return [self aesEncryptWithData:[data dataUsingEncoding:NSUTF8StringEncoding] key:key iv:iv];
}
+ (PJSecurityResult *)aesEncryptWithData:(NSData *)data key:(NSData *)key iv:(NSData *)iv
{
    // check length of key and iv
    if ([iv length] != 16) {
        @throw [NSException exceptionWithName:@"PJSecurity"
                                       reason:@"Length of iv is wrong. Length of iv should be 16(128bits)"
                                     userInfo:nil];
    }
    if ([key length] != 16 && [key length] != 24 && [key length] != 32 ) {
        @throw [NSException exceptionWithName:@"PJSecurity"
                                       reason:@"Length of key is wrong. Length of iv should be 16, 24 or 32(128, 192 or 256bits)"
                                     userInfo:nil];
    }
    
    // setup output buffer
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    // do encrypt
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          [key bytes],     // Key
                                          [key length],    // kCCKeySizeAES
                                          [iv bytes],       // IV
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    if (cryptStatus == kCCSuccess) {
        PJSecurityResult *result = [[PJSecurityResult alloc] initWithBytes:buffer length:encryptedSize];
        free(buffer);
        
        return result;
    }
    else {
        free(buffer);
        @throw [NSException exceptionWithName:@"PJSecurity"
                                       reason:@"Encrypt Error!"
                                     userInfo:nil];
        return nil;
    }
}
#pragma mark - AES Decrypt
// default AES Decrypt, key -> SHA384(key).sub(0, 32), iv -> SHA384(key).sub(32, 16)
+ (PJSecurityResult *)aesDecryptWithBase64:(NSString *)data key:(NSString *)key
{
    PJSecurityResult * sha = [self sha384:key];
    NSData *aesKey = [sha.data subdataWithRange:NSMakeRange(0, 32)];
    NSData *aesIv = [sha.data subdataWithRange:NSMakeRange(32, 16)];
    
    return [self aesDecryptWithBase64:data key:aesKey iv:aesIv];
}
#pragma mark AES Decrypt 128, 192, 256
+ (PJSecurityResult *)aesDecryptWithBase64:(NSString *)data hexKey:(NSString *)key hexIv:(NSString *)iv
{
    PJSecurityDecoder *decoder = [PJSecurityDecoder new];
    NSData *aesKey = [decoder hex:key];
    NSData *aesIv = [decoder hex:iv];
    
    return [self aesDecryptWithBase64:data key:aesKey iv:aesIv];
}
+ (PJSecurityResult *)aesDecryptWithBase64:(NSString *)data key:(NSData *)key iv:(NSData *)iv
{
    PJSecurityDecoder *decoder = [PJSecurityDecoder new];
    return [self aesDecryptWithData:[decoder base64:data] key:key iv:iv];
}
+ (PJSecurityResult *)aesDecryptWithData:(NSData *)data key:(NSData *)key iv:(NSData *)iv
{
    // check length of key and iv
    if ([iv length] != 16) {
        @throw [NSException exceptionWithName:@"PJSecurity"
                                       reason:@"Length of iv is wrong. Length of iv should be 16(128bits)"
                                     userInfo:nil];
    }
    if ([key length] != 16 && [key length] != 24 && [key length] != 32 ) {
        @throw [NSException exceptionWithName:@"PJSecurity"
                                       reason:@"Length of key is wrong. Length of iv should be 16, 24 or 32(128, 192 or 256bits)"
                                     userInfo:nil];
    }
    
    // setup output buffer
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    // do encrypt
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          [key bytes],     // Key
                                          [key length],    // kCCKeySizeAES
                                          [iv bytes],       // IV
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    if (cryptStatus == kCCSuccess) {
        PJSecurityResult *result = [[PJSecurityResult alloc] initWithBytes:buffer length:encryptedSize];
        free(buffer);
        
        return result;
    }
    else {
        free(buffer);
        @throw [NSException exceptionWithName:@"PJSecurity"
                                       reason:@"Decrypt Error!"
                                     userInfo:nil];
        return nil;
    }
}


#pragma mark - MD5
+ (PJSecurityResult *)md5:(NSString *)hashString
{
    return [self md5WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding]];
}
+ (PJSecurityResult *)md5WithData:(NSData *)hashData
{
    unsigned char *digest;
    digest = malloc(CC_MD5_DIGEST_LENGTH);
    
    CC_MD5([hashData bytes], (CC_LONG)[hashData length], digest);
    PJSecurityResult *result = [[PJSecurityResult alloc] initWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    free(digest);
    
    return result;
}
#pragma mark - HMAC-MD5
+ (PJSecurityResult *)hmacMd5:(NSString *)hashString hmacKey:(NSString *)key
{
    return [self hmacMd5WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding] hmacKey:key];
}
+ (PJSecurityResult *)hmacMd5WithData:(NSData *)hashData hmacKey:(NSString *)key
{
    unsigned char *digest;
    digest = malloc(CC_MD5_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgMD5, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    PJSecurityResult *result = [[PJSecurityResult alloc] initWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    free(digest);
    cKey = nil;
    
    return result;
}


#pragma mark - SHA1
+ (PJSecurityResult *)sha1:(NSString *)hashString
{
    return [self sha1WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding]];
}
+ (PJSecurityResult *)sha1WithData:(NSData *)hashData
{
    unsigned char *digest;
    digest = malloc(CC_SHA1_DIGEST_LENGTH);
    
    CC_SHA1([hashData bytes], (CC_LONG)[hashData length], digest);
    PJSecurityResult *result = [[PJSecurityResult alloc] initWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    free(digest);
    
    return result;
}
#pragma mark SHA224
+ (PJSecurityResult *)sha224:(NSString *)hashString
{
    return [self sha224WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding]];
}
+ (PJSecurityResult *)sha224WithData:(NSData *)hashData
{
    unsigned char *digest;
    digest = malloc(CC_SHA224_DIGEST_LENGTH);
    
    CC_SHA224([hashData bytes], (CC_LONG)[hashData length], digest);
    PJSecurityResult *result = [[PJSecurityResult alloc] initWithBytes:digest length:CC_SHA224_DIGEST_LENGTH];
    free(digest);
    
    return result;
}
#pragma mark SHA256
+ (PJSecurityResult *)sha256:(NSString *)hashString
{
    return [self sha256WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding]];
}
+ (PJSecurityResult *)sha256WithData:(NSData *)hashData
{
    unsigned char *digest;
    digest = malloc(CC_SHA256_DIGEST_LENGTH);
    
    CC_SHA256([hashData bytes], (CC_LONG)[hashData length], digest);
    PJSecurityResult *result = [[PJSecurityResult alloc] initWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    free(digest);
    
    return result;
}
#pragma mark SHA384
+ (PJSecurityResult *)sha384:(NSString *)hashString
{
    return [self sha384WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding]];
}
+ (PJSecurityResult *)sha384WithData:(NSData *)hashData
{
    unsigned char *digest;
    digest = malloc(CC_SHA384_DIGEST_LENGTH);
    
    CC_SHA384([hashData bytes], (CC_LONG)[hashData length], digest);
    PJSecurityResult *result = [[PJSecurityResult alloc] initWithBytes:digest length:CC_SHA384_DIGEST_LENGTH];
    free(digest);
    
    return result;
}
#pragma mark SHA512
+ (PJSecurityResult *)sha512:(NSString *)hashString
{
    return [self sha512WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding]];
}
+ (PJSecurityResult *)sha512WithData:(NSData *)hashData
{
    unsigned char *digest;
    digest = malloc(CC_SHA512_DIGEST_LENGTH);
    
    CC_SHA512([hashData bytes], (CC_LONG)[hashData length], digest);
    PJSecurityResult *result = [[PJSecurityResult alloc] initWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
    free(digest);
    
    return result;
}


#pragma mark - HMAC-SHA1
+ (PJSecurityResult *)hmacSha1:(NSString *)hashString hmacKey:(NSString *)key
{
    return [self hmacSha1WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding] hmacKey:key];
}
+ (PJSecurityResult *)hmacSha1WithData:(NSData *)hashData hmacKey:(NSString *)key
{
    unsigned char *digest;
    digest = malloc(CC_SHA1_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    PJSecurityResult *result = [[PJSecurityResult alloc] initWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    free(digest);
    cKey = nil;
    
    return result;
}
#pragma mark HMAC-SHA224
+ (PJSecurityResult *)hmacSha224:(NSString *)hashString hmacKey:(NSString *)key
{
    return [self hmacSha224WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding] hmacKey:key];
}
+ (PJSecurityResult *)hmacSha224WithData:(NSData *)hashData hmacKey:(NSString *)key
{
    unsigned char *digest;
    digest = malloc(CC_SHA224_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA224, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    PJSecurityResult *result = [[PJSecurityResult alloc] initWithBytes:digest length:CC_SHA224_DIGEST_LENGTH];
    free(digest);
    cKey = nil;
    
    return result;
}
#pragma mark HMAC-SHA256
+ (PJSecurityResult *)hmacSha256:(NSString *)hashString hmacKey:(NSString *)key
{
    return [self hmacSha256WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding] hmacKey:key];
}
+ (PJSecurityResult *)hmacSha256WithData:(NSData *)hashData hmacKey:(NSString *)key
{
    unsigned char *digest;
    digest = malloc(CC_SHA256_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    PJSecurityResult *result = [[PJSecurityResult alloc] initWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    free(digest);
    cKey = nil;
    
    return result;
}
#pragma mark HMAC-SHA384
+ (PJSecurityResult *)hmacSha384:(NSString *)hashString hmacKey:(NSString *)key
{
    return [self hmacSha384WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding] hmacKey:key];
}
+ (PJSecurityResult *)hmacSha384WithData:(NSData *)hashData hmacKey:(NSString *)key
{
    unsigned char *digest;
    digest = malloc(CC_SHA384_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA384, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    PJSecurityResult *result = [[PJSecurityResult alloc] initWithBytes:digest length:CC_SHA384_DIGEST_LENGTH];
    free(digest);
    cKey = nil;
    
    return result;
}
#pragma mark HMAC-SHA512
+ (PJSecurityResult *)hmacSha512:(NSString *)hashString hmacKey:(NSString *)key
{
    return [self hmacSha512WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding] hmacKey:key];
}
+ (PJSecurityResult *)hmacSha512WithData:(NSData *)hashData hmacKey:(NSString *)key
{
    unsigned char *digest;
    digest = malloc(CC_SHA512_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA512, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    PJSecurityResult *result = [[PJSecurityResult alloc] initWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
    free(digest);
    cKey = nil;
    
    return result;
}

@end





#pragma mark - PJSecurityEncoder
@implementation PJSecurityEncoder

// convert NSData to Base64
- (NSString *)base64:(NSData *)data
{
    return [data base64EncodedString];
}

// convert NSData to hex string
- (NSString *)hex:(NSData *)data useLower:(BOOL)isOutputLower
{
    if (data.length == 0) { return nil; }
    
    static const char HexEncodeCharsLower[] = "0123456789abcdef";
    static const char HexEncodeChars[] = "0123456789ABCDEF";
    char *resultData;
    // malloc result data
    resultData = malloc([data length] * 2 +1);
    // convert imgData(NSData) to char[]
    unsigned char *sourceData = ((unsigned char *)[data bytes]);
    NSUInteger length = [data length];
    
    if (isOutputLower) {
        for (NSUInteger index = 0; index < length; index++) {
            // set result data
            resultData[index * 2] = HexEncodeCharsLower[(sourceData[index] >> 4)];
            resultData[index * 2 + 1] = HexEncodeCharsLower[(sourceData[index] % 0x10)];
        }
    }
    else {
        for (NSUInteger index = 0; index < length; index++) {
            // set result data
            resultData[index * 2] = HexEncodeChars[(sourceData[index] >> 4)];
            resultData[index * 2 + 1] = HexEncodeChars[(sourceData[index] % 0x10)];
        }
    }
    resultData[[data length] * 2] = 0;
    
    // convert result(char[]) to NSString
    NSString *result = [NSString stringWithCString:resultData encoding:NSASCIIStringEncoding];
    sourceData = nil;
    free(resultData);
    
    return result;
}

@end

#pragma mark - PJSecurityDecoder
@implementation PJSecurityDecoder
- (NSData *)base64:(NSString *)string
{
    return [NSData dataWithBase64EncodedString:string];
}
- (NSData *)hex:(NSString *)data
{
    if (data.length == 0) { return nil; }
    
    static const unsigned char HexDecodeChars[] =
    {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //49
        2, 3, 4, 5, 6, 7, 8, 9, 0, 0, //59
        0, 0, 0, 0, 0, 10, 11, 12, 13, 14,
        15, 0, 0, 0, 0, 0, 0, 0, 0, 0,  //79
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 10, 11, 12,   //99
        13, 14, 15
    };
    
    // convert data(NSString) to CString
    const char *source = [data cStringUsingEncoding:NSUTF8StringEncoding];
    // malloc buffer
    unsigned char *buffer;
    NSUInteger length = strlen(source) / 2;
    buffer = malloc(length);
    for (NSUInteger index = 0; index < length; index++) {
        buffer[index] = (HexDecodeChars[source[index * 2]] << 4) + (HexDecodeChars[source[index * 2 + 1]]);
    }
    // init result NSData
    NSData *result = [NSData dataWithBytes:buffer length:length];
    free(buffer);
    source = nil;
    
    return  result;
}


@end
