//
//  PJBlockChain.h
//  PJBlockchainDemo
//
//  Created by PlatoJobs on 2019/3/4.
//  Copyright © 2019 David. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PJBlock;//区块链中的一个区块
NS_ASSUME_NONNULL_BEGIN

@interface PJBlockChain : NSObject

@property (nonatomic, strong) NSMutableArray<PJBlock *> *pj_blocks;

/*区块链（Blockchain）类需要用一个区块的实例来初始化自己。这个区块也被称为创世区块（genesis block），正因为它是区块链的第一个区块*/
- (void)pj_instantiationWithBlock:(PJBlock *)block;

@end

NS_ASSUME_NONNULL_END
