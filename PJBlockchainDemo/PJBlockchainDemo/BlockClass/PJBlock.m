//
//  PJBlock.m
//  PJBlockchainDemo
//
//  Created by PlatoJobs on 2019/3/4.
//  Copyright © 2019 David. All rights reserved.
//

#import "PJBlock.h"

@implementation PJBlock

- (NSString *)key{
    return [NSString stringWithFormat:
            @"%d%@%@%@%d",self.index,self.dateCreated,self.previousHash,self.data,self.nonce];
}

- (instancetype)init{
    if (self = [super init]) {
        self.dateCreated = [self dateDescription];
        self.nonce = 0;
        self.data = @"";
    }
    return self;
}

- (NSString *)dateDescription{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter stringFromDate:[NSDate date]];
}


@end
