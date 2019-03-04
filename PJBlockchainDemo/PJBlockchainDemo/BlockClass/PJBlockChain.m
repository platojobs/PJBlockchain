//
//  PJBlockChain.m
//  PJBlockchainDemo
//
//  Created by PlatoJobs on 2019/3/4.
//  Copyright © 2019 David. All rights reserved.
//

#import "PJBlockChain.h"
#import "PJBlock.h"
#import "PJSecurity.h"
@implementation PJBlockChain

- (void)pj_instantiationWithBlock:(PJBlock *)block{
    
    if (_pj_blocks == nil) {
        // 添加创世区块
        // 第一个区块没有 previous hash
        block.previousHash = @"0";
        block.blockHash = [self pj_generateHashForblock:block];
    }else{
        PJBlock *previousBlock = [self pj_getPreviousBlock];
        block.previousHash = previousBlock.blockHash;
        block.index = @(self.blocks.count).intValue;
        block.blockHash = [self pj_generateHashForblock:block];
    }
    [self.blocks addObject:block];
    [self pj_displayBlock:block];
    
    
}

- (PJBlock *)pj_getPreviousBlock{
    return self.blocks[self.blocks.count - 1];
}

- (void)pj_displayBlock:(PJBlock *)block{
    NSLog(@"%@", [NSString stringWithFormat:@"------ 第 (%d) 个区块 --------",block.index]);
    NSLog(@"%@", [NSString stringWithFormat:@"创建日期：%@",block.dateCreated]);
    NSLog(@"%@", [NSString stringWithFormat:@"数据：%@",block.data]);
    NSLog(@"%@", [NSString stringWithFormat:@"Nonce：%d",block.nonce]);
    NSLog(@"%@", [NSString stringWithFormat:@"前一个区块的哈希值：%@",block.previousHash]);
    NSLog(@"%@", [NSString stringWithFormat:@"哈希值：%@",block.blockHash]);
}

- (NSString *)pj_generateHashForblock:(PJBlock *)block{
    
//    NSString *hash=[PJSecurity sha1:block.key].utf8String;
//
//    while (![hash hasPrefix:@"00"]) {
//        block.nonce += 1;
//        hash = [PJSecurity sha1:block.key].utf8String;
//    }
//    return hash;
    NSString *hash = [self sha1Hash:block.key];
    while (![hash hasPrefix:@"00"]) {
        block.nonce += 1;
        hash = [self sha1Hash:block.key];
    }
    return hash;
}
- (NSString *)sha1Hash:(NSString *)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

- (NSMutableArray<PJBlock *> *)blocks{
    if (_pj_blocks == nil) {
        _pj_blocks = [NSMutableArray array];
    }
    return _pj_blocks;
}


@end
