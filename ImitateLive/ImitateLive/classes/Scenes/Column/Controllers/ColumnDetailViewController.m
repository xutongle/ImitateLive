//
//  ColumnDetailViewController.m
//  ImitateLive
//
//  Created by ssx on 16/7/12.
//  Copyright © 2016年 SJH. All rights reserved.
//

#import "ColumnDetailViewController.h"
#import "ColumnDetailCollectionViewCell.h"
#import "ColumnRequest.h"
#import "ColumnDetailModel.h"
#import "LiveDetailViewController.h"
#import "ListModel.h"
#import "TalentShowViewController.h"

#define header_Identifier @"header_Identifier"
#define footer_identifier @"footer_Identifier"

@interface ColumnDetailViewController ()
<
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
>

@property (nonatomic, strong) UICollectionView *columnDetailView;
@property (nonatomic, strong) NSMutableArray *allVideoArr;
@property (nonatomic, assign) NSInteger page;
@end

@implementation ColumnDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.model.name;
    
    
    
    // 创建collectionView
    [self creatColumnDetailView];
    self.allVideoArr = [NSMutableArray array];
    [self loadMore];
    // 下拉刷新
    
    self.columnDetailView.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        [self loadTop];
    }];
    // 上拉刷新
    self.columnDetailView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingBlock:^{
        [self loadMore];
    }];
    // 注册头视图
    [self.columnDetailView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:header_Identifier];
    // 注册尾视图
    [self.columnDetailView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footer_identifier];
}
// 创建collectionView
- (void)creatColumnDetailView
{
    // 创建UICollerctionView
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.columnDetailView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 0, WindownWidth, WindowHeight - 64) collectionViewLayout:flowLayout];
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.minimumLineSpacing = 5;
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    self.columnDetailView.backgroundColor = [UIColor whiteColor];
    self.columnDetailView.delegate = self;
    self.columnDetailView.dataSource = self;
    // 可以下拉
    self.columnDetailView.alwaysBounceVertical = YES;
    
    [self.columnDetailView registerNib:[UINib nibWithNibName:@"ColumnDetailCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:ColumnDetailCollectionViewCell_Identifier];
    
    [self.view addSubview:self.columnDetailView];
}

// 判断是否是顶部
- (void)loadTop
{
    self.page = 1;
    [self loadDataPageIndex:self.page top:YES];
}

- (void)loadMore
{
    self.page += 1;
    [self loadDataPageIndex:self.page top:NO];
}
// 判断请求的方式
- (void)loadDataPageIndex:(NSInteger)page top:(BOOL)isTop
{
    NSString *ID = [NSString stringWithFormat:@"%@/20-%ld",self.model.gameID,page];
    
    if (isTop) {
        [self.allVideoArr removeAllObjects];
        [self requestColumnData:ID];
        
    }else{
        [self requestColumnData:ID];
    }
    
}



// 请求数据
- (void)requestColumnData:(NSString *)ID
{
    

    
    __weak typeof(self) weakSelf = self;
    NSDictionary *parmar = [NSDictionary dictionaryWithObject:ID forKey:@"id"];
    ColumnRequest *columnRequest = [[ColumnRequest alloc] init];
    [columnRequest columnRequestWithParameter:parmar success:^(NSDictionary *dic) {
//        NSLog(@"%@",dic);
        
        NSDictionary *tempDict = [dic objectForKey:@"data"];
        NSArray *tempArr = [tempDict objectForKey:@"rooms"];
        for (NSDictionary *tempdic in tempArr) {
            // item数组赋值
//            ColumnDetailModel *model = [[ColumnDetailModel alloc] init];
            LiveModel *model = [[LiveModel alloc] init];
            [model setValuesForKeysWithDictionary:tempdic];
            [weakSelf.allVideoArr addObject:model];
//            NSLog(@"%@",weakSelf.allVideoArr);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.columnDetailView.mj_header endRefreshing];
            [weakSelf.columnDetailView.mj_footer endRefreshing];
            [weakSelf.columnDetailView reloadData];

        });
        
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}
#pragma mark -- 代理方法
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = WindownWidth / 2.0 - 15;
    CGFloat height = WindowHeight / 4.0 - 20;
    return CGSizeMake(width, height);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    NSLog(@"%ld",self.allVideoArr.count);
    return self.allVideoArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ColumnDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ColumnDetailCollectionViewCell_Identifier forIndexPath:indexPath];
    cell.model = self.allVideoArr[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    LiveDetailViewController *liveDetail = [[LiveDetailViewController alloc] init];
    TalentShowViewController *talentShowVC = [[TalentShowViewController alloc] init];
    LiveModel *model = self.allVideoArr[indexPath.row];
    if ([model.verscr isEqualToString:@"1"]) {
        talentShowVC.liveModel = model;
        [self presentViewController:talentShowVC animated:YES completion:nil];
    }else{
        
        liveDetail.liveModel = model;
        [self.navigationController presentViewController:liveDetail animated:YES completion:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
