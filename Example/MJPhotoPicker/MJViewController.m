//
//  MJViewController.m
//  MJPhotoPicker
//
//  Created by yangyu2010@aliyun.com on 04/19/2018.
//  Copyright (c) 2018 yangyu2010@aliyun.com. All rights reserved.
//

#import "MJViewController.h"
//#import <MJPhotoPicker/MJImagePickerController.h>
#import "MJImagePickerController.h"

@interface MJViewController ()

@end

@implementation MJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    

    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
        MJImagePickerController *vc = [[MJImagePickerController alloc] initWithMaxImagesCount:0 columnNumber:0 delegate:nil pushPhotoPickerVc:YES];
        [self presentViewController:vc animated:YES completion:nil];

}
@end
