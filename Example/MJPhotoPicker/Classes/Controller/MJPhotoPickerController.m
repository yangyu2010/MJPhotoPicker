//
//  MJPhotoPickerController.m
//  YYImagePickerController
//
//  Created by Yang Yu on 2017/12/27.
//  Copyright © 2017年 Yang Yu. All rights reserved.
//

#import "MJPhotoPickerController.h"
#import "PhotoCollectionCell.h"
#import "MJImageManager.h"
#import "NSObject+Utils.h"
#import "MJPhotoPreviewController.h"
#import "MJAlbumModel.h"
#import "MJImagePickerController.h"
#import "PhotoPickerToolView.h"
#import "UIView+Sugar.h"

#define kPhotoCollectionCellID      @"PhotoCollectionCell.h"

#define kPhotoCollectionRowCount    4

#define kPhotoCollectionCellMargin  5.0f

#define kPhotoBottomViewHeight      49.0f

@interface MJPhotoPickerController () <UICollectionViewDelegate, UICollectionViewDataSource, PhotoPickerToolViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionPhoto;

@property (nonatomic, strong) PhotoPickerToolView *viewBottomTool;


@property (nonatomic, strong) NSArray <MJAssetModel *> *arrAssets;

@property (nonatomic, weak) MJImagePickerController *navPicker;

@end

@implementation MJPhotoPickerController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self viewConfig];
    [self dataConfig];
    

}

- (void)dealloc {
    NSLog(@"MJPhotoPickerController dealloc");
}

#pragma mark- Data

- (void)dataConfig {
   
    _arrAssets = self.modelAlbum.arrModels;
    [_collectionPhoto reloadData];
    
    MJImagePickerController *navPicker = (MJImagePickerController *)self.navigationController;
    if ([navPicker isKindOfClass:[MJImagePickerController class]]) {
        self.navPicker = navPicker;
    }

//    _viewBottomTool.countSelected = self.navPicker.arrSelectedModels.count;
//    if ((_arrAssets.count > 0) && (_arrAssets.count == self.navPicker.arrSelectedModels.count)) {
//        [_viewBottomTool setSelectedAll];
//    }
    
}

#pragma mark- View

- (void)viewConfig {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancle" style:UIBarButtonItemStyleDone target:self action:@selector(actionCancle)];
    self.title = _modelAlbum.name;
    
    _collectionPhoto = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    _collectionPhoto.backgroundColor = [UIColor whiteColor];
    _collectionPhoto.allowsMultipleSelection = YES;
    _collectionPhoto.delegate = self;
    _collectionPhoto.dataSource = self;
    [self.view addSubview:_collectionPhoto];
    _collectionPhoto.contentInset = UIEdgeInsetsMake(kPhotoCollectionCellMargin, kPhotoCollectionCellMargin, kPhotoCollectionCellMargin, kPhotoCollectionCellMargin);
    [_collectionPhoto registerClass:[PhotoCollectionCell class] forCellWithReuseIdentifier:kPhotoCollectionCellID];
    
    
    _viewBottomTool = [[PhotoPickerToolView alloc] init];
    _viewBottomTool.delegate = self;
    [self.view addSubview:_viewBottomTool];
    
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_collectionPhoto.collectionViewLayout invalidateLayout];
    
    CGFloat safeBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeBottom = self.view.safeAreaInsets.bottom;
        _viewBottomTool.frame = CGRectMake(0, self.view.bounds.size.height - kPhotoBottomViewHeight - self.view.safeAreaInsets.bottom, self.view.bounds.size.width, kPhotoBottomViewHeight + self.view.safeAreaInsets.bottom);
    } else {
        _viewBottomTool.frame = CGRectMake(0, self.view.bounds.size.height - kPhotoBottomViewHeight, self.view.bounds.size.width, kPhotoBottomViewHeight);
    }
    
    _collectionPhoto.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - kPhotoBottomViewHeight - safeBottom);
    
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionPhoto.collectionViewLayout;
    
    CGFloat margin = 10;     // 两个item中间的间距
    CGFloat padding = 15.0f;   // item右边距离边框的距离默认都是0
    
    CGFloat maxWidth = 160.0f;
    
    NSInteger row = 4;
    CGFloat itemWidth = (self.view.width - (row - 1) * margin - 2 * padding) / row;
    
    if (itemWidth > maxWidth) {
        /// pad上
        itemWidth = 120;
        row = (self.view.width - 2 * margin) / itemWidth;
        margin = (self.view.width - row * itemWidth) / (row + 1);
        padding = margin;
    }
    
    
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = margin;
    
    [self.collectionPhoto setCollectionViewLayout:layout];
    
    [self.collectionPhoto setContentInset:UIEdgeInsetsMake(0, margin, 0, margin)];
    
}


#pragma mark- Action

- (void)actionCancle {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/// 滚到最底部
- (void)actionCollectionViewScrollBottom {
    if (_arrAssets.count == 0) {
        return ;
    }
    
    NSInteger count = [_collectionPhoto numberOfItemsInSection:0];
    if (count > 0) {
        count -= 1;
    }
    
    [_collectionPhoto scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:count inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
}

/// 点击cell, 添加或者删除Model
- (void)actionAddSelectedModelAtIndexPath:(NSIndexPath *)indexPath {

    if (self.navPicker == nil) {
        return ;
    }

    MJAssetModel *model = _arrAssets[indexPath.item];

    if (model.isSelected) {
        [self.navPicker.arrSelectedModels removeObject:model];
        model.isSelected = NO;
    } else {
        [self.navPicker.arrSelectedModels addObject:model];
        model.isSelected = YES;
    }
    self.viewBottomTool.countSelected = self.navPicker.arrSelectedModels.count;
}


#pragma mark- DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _arrAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCollectionCellID forIndexPath:indexPath];
    cell.model = _arrAssets[indexPath.item];
    return cell;
}

#pragma mark- Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self actionAddSelectedModelAtIndexPath:indexPath];
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self actionAddSelectedModelAtIndexPath:indexPath];
}

#pragma mark- Bottom ToolView Delegate
/// 选中所有
- (void)photoPickerToolViewSelectAllClick:(BOOL)isSelected {
    
    if (self.navPicker == nil) {
        return ;
    }
    
    [self.navPicker.arrSelectedModels removeAllObjects];

    // 是选择就全部加进来, 返选就直接删除就行
    for (MJAssetModel *model in self.modelAlbum.arrModels) {
        model.isSelected = isSelected;
        if (isSelected) {
            [self.navPicker.arrSelectedModels addObject:model];
        }
    }
    
    self.viewBottomTool.countSelected = self.navPicker.arrSelectedModels.count;
    [_collectionPhoto reloadData];
}

/// 预览
- (void)photoPickerToolViewPreviewClick {
    
    if (self.navPicker == nil) {
        return ;
    }
    
    if (self.navPicker.arrSelectedModels.count == 0) {
        return ;
    }
    
    MJPhotoPreviewController *previewVc = [[MJPhotoPreviewController alloc] init];
    previewVc.arrAssetModels = self.navPicker.arrSelectedModels.copy;
    [self.navigationController pushViewController:previewVc animated:YES];
}

/// 完成
- (void)photoPickerToolViewDoneClick {
    
}

@end
