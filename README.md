# PJBlockchain
iOS 中实现区块链
```objc

@interface PJBlock : NSObject

/**
 区块位于区块链中的位置。index 为 0 则表示该区块是区块链中的第一个区块。index 为 1 则表示区块链中的第二个区块……以此类推！
 */

@property (nonatomic, assign) int index;
/**
 区块创建的日期
 */
@property (nonatomic,copy) NSString *dateCreated;
/**
 前一个区块的哈希值
 */
@property (nonatomic, copy) NSString *previousHash;
/**
 当前区块的哈希值
 */
@property (nonatomic, copy) NSString *blockHash;
/**
 递增的数字，对生成哈希值很关键
 */
@property (nonatomic, assign) int nonce;
/**
 任意有价值的信息。可以是金钱、医疗信息和房地产信息等等
 */
@property (nonatomic, copy) NSString *data;
/**
 计算属性，提供给产生哈希值的函数
 */
@property (nonatomic, copy,readonly) NSString *key;



```

```objc

//区块链（Blockchain）类需要用一个区块的实例来初始化自己。这个区块也被称为创世区块（genesis block），正因为它是区块链的第一个区块

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

```


![样例结果](https://github.com/PlatoJobs/PJBlockchain/blob/master/打印结果.png）

