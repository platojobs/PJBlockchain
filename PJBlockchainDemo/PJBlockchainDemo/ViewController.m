//
//  ViewController.m
//  PJBlockchainDemo
//
//  Created by PlatoJobs on 2019/3/4.
//  Copyright © 2019 David. All rights reserved.
//

#import "ViewController.h"
#import "PJBlockChain.h"
#import "PJBlock.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (int i=0; i<2; i++) {
        PJBlock*block=[PJBlock new];
        if (i==0) {
            block.index=0;
            
        }
        [[[PJBlockChain alloc]init]pj_instantiationWithBlock:block];
        
    }
    
    // Do any additional setup after loading the view, typically from a nib.
}


@end
