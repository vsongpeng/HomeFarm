//
//  DCGoodBaseViewController.m
//  CDDMall
//
//  Created by apple on 2017/6/21.
//  Copyright © 2017年 RocketsChen. All rights reserved.
//

#import "DCGoodBaseViewController.h"

// Controllers
#import "DCFootprintGoodsViewController.h"
#import "DCShareToViewController.h"
#import "DCToolsViewController.h"
#import "DCFeatureSelectionViewController.h"
#import "DCFillinOrderViewController.h"
#import "DCLoginViewController.h"

// Models


// Views
#import "DCLIRLButton.h"

#import "DCDetailShufflingHeadView.h" //头部轮播
#import "DCDetailGoodReferralCell.h"  //商品标题价格介绍
#import "DCDetailShowTypeCell.h"      //种类
#import "DCShowTypeOneCell.h"
#import "DCShowTypeTwoCell.h"
#import "DCShowTypeThreeCell.h"
#import "DCShowTypeFourCell.h"
#import "DCDetailServicetCell.h"      //服务
#import "DCDetailLikeCell.h"          //猜你喜欢
#import "DCDetailOverFooterView.h"    //尾部结束
#import "DCDetailPartCommentCell.h"   //部分评论
#import "DCDeatilCustomHeadView.h"    //自定义头部
// Vendors
#import "AddressPickerView.h"
#import <WebKit/WebKit.h>
// Categories
#import "XWDrawerAnimator.h"
#import "UIViewController+XWTransition.h"
// Others

@interface DCGoodBaseViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,WKNavigationDelegate>
{
    //商品个数 初始默认是1
    int _numAll;
}
@property (strong, nonatomic) UIScrollView *scrollerView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) WKWebView *webView;
/* 选择地址弹框 */
@property (strong , nonatomic)AddressPickerView *adPickerView;
/* 滚回顶部按钮 */
@property (strong , nonatomic)UIButton *backTopButton;
/* 通知 */
@property (weak ,nonatomic) id dcObj;

@end

//header
static NSString *DCDetailShufflingHeadViewID = @"DCDetailShufflingHeadView";
static NSString *DCDeatilCustomHeadViewID = @"DCDeatilCustomHeadView";
//cell
static NSString *DCDetailGoodReferralCellID = @"DCDetailGoodReferralCell";

static NSString *DCShowTypeOneCellID = @"DCShowTypeOneCell";
static NSString *DCShowTypeTwoCellID = @"DCShowTypeTwoCell";
static NSString *DCShowTypeThreeCellID = @"DCShowTypeThreeCell";
static NSString *DCShowTypeFourCellID = @"DCShowTypeFourCell";

static NSString *DCDetailServicetCellID = @"DCDetailServicetCell";
static NSString *DCDetailLikeCellID = @"DCDetailLikeCell";
static NSString *DCDetailPartCommentCellID = @"DCDetailPartCommentCell";
//footer
static NSString *DCDetailOverFooterViewID = @"DCDetailOverFooterView";


static NSString *lastNum_;
static NSArray *lastSeleArray_;

@implementation DCGoodBaseViewController

#pragma mark - LazyLoad
- (UIScrollView *)scrollerView
{
    if (!_scrollerView) {
        _scrollerView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollerView.frame = self.view.bounds;
        _scrollerView.contentSize = CGSizeMake(kScreen_Width, (kScreen_Height - 50) * 2);
        _scrollerView.pagingEnabled = YES;
        _scrollerView.scrollEnabled = NO;
        [self.view addSubview:_scrollerView];
    }
    return _scrollerView;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = 0; //Y
        layout.minimumInteritemSpacing = 0; //X
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height - DCTopNavH);
        _collectionView.showsVerticalScrollIndicator = NO;
        [self.scrollerView addSubview:_collectionView];
        
        //注册header
        [_collectionView registerClass:[DCDetailShufflingHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DCDetailShufflingHeadViewID];
        [_collectionView registerClass:[DCDeatilCustomHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DCDeatilCustomHeadViewID];
        //注册Cell
        [_collectionView registerClass:[DCDetailGoodReferralCell class] forCellWithReuseIdentifier:DCDetailGoodReferralCellID];
        [_collectionView registerClass:[DCShowTypeOneCell class] forCellWithReuseIdentifier:DCShowTypeOneCellID];
        [_collectionView registerClass:[DCShowTypeTwoCell class] forCellWithReuseIdentifier:DCShowTypeTwoCellID];
        [_collectionView registerClass:[DCShowTypeThreeCell class] forCellWithReuseIdentifier:DCShowTypeThreeCellID];
        [_collectionView registerClass:[DCShowTypeFourCell class] forCellWithReuseIdentifier:DCShowTypeFourCellID];
        [_collectionView registerClass:[DCDetailLikeCell class] forCellWithReuseIdentifier:DCDetailLikeCellID];
        [_collectionView registerClass:[DCDetailPartCommentCell class] forCellWithReuseIdentifier:DCDetailPartCommentCellID];
        [_collectionView registerClass:[DCDetailServicetCell class] forCellWithReuseIdentifier:DCDetailServicetCellID];
        //注册Footer
        [_collectionView registerClass:[DCDetailOverFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:DCDetailOverFooterViewID];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionElementKindSectionFooter"]; //间隔
        
    }
    return _collectionView;
}

- (WKWebView *)webView
{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        _webView.frame = CGRectMake(0,kScreen_Height , kScreen_Width, kScreen_Height - DCTopNavH);
        _webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _webView.scrollView.scrollIndicatorInsets = _webView.scrollView.contentInset;
        [self.scrollerView addSubview:_webView];
    }
    return _webView;
}


#pragma mark - LifeCyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _numAll = 1;
    
    [self setUpInit];
    
    [self setUpViewScroller];
    
    [self setUpGoodsWKWebView];
    
    [self setUpSuspendView];

    
    [self acceptanceNote];
}




#pragma mark - initialize
- (void)setUpInit
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = DCBGColor;
    self.collectionView.backgroundColor = self.view.backgroundColor;
    self.scrollerView.backgroundColor = self.view.backgroundColor;

    //初始化
    lastSeleArray_ = [NSArray array];
    lastNum_ = 0;
    
}

#pragma mark - 接受通知
- (void)acceptanceNote
{
    //分享通知
    WEAKSELF
    _dcObj = [[NSNotificationCenter defaultCenter]addObserverForName:SHAREALTERVIEW object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf selfAlterViewback];
        [weakSelf setUpAlterViewControllerWith:[DCShareToViewController new] WithDistance:300 WithDirection:XWDrawerAnimatorDirectionBottom WithParallaxEnable:NO WithFlipEnable:NO];
    }];
    

    //父类加入购物车，立即购买通知
    _dcObj = [[NSNotificationCenter defaultCenter]addObserverForName:SELECTCARTORBUY object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (lastSeleArray_.count != 0) {
            if ([note.userInfo[@"buttonTag"] isEqualToString:@"2"]) { //加入购物车（父类）
//                dcVc.goodTitle = _setItem[indexPath.row].main_title;
//                dcVc.goodPrice = _setItem[indexPath.row].price;
//                dcVc.goodSubtitle = _setItem[indexPath.row].goods_title;
//                dcVc.shufflingArray = _setItem[indexPath.row].images;
//                dcVc.goodImageView = _setItem[indexPath.row].image_url;
                NSMutableArray *numIsExis = [NSMutableArray arrayWithContentsOfFile:[CommonMethod getFilePath]];
                NSString *num = @"1";
                long numValue = [numIsExis count];//numAll;
                if (numValue) {
                    for (int i=0; i<numIsExis.count; i++) {
                        NSMutableDictionary *dic = [numIsExis objectAtIndex:i];
                        
                        
                        if ([strongSelf.goodImageView isEqualToString:[dic objectForKey:@"imageUrl"]]) {
                            
                            numValue = [[dic objectForKey:@"num"] intValue];
                            numValue += _numAll;
                            
                            [dic setObject:[NSString stringWithFormat:@"%ld",numValue] forKey:@"num"];
                            
                            [numIsExis writeToFile:[CommonMethod getFilePath] atomically:YES];
                        }
                        
                    }
                    
                    num = [NSString stringWithFormat:@"%ld",numValue];
                }
                
                [strongSelf writeConfigFile:self.goodImageView descirb:self.goodSubtitle price:self.goodPrice num:num selected:@"0" isSale:@"1" code:self.goodTitle];
                [strongSelf setUpWithAddSuccess];
                
            }else if ([note.userInfo[@"buttonTag"] isEqualToString:@"3"]){//立即购买（父类）
                

                XOrderPayViewController *order = [[XOrderPayViewController alloc] init];
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithCapacity:0];
                [tempDic setObject:strongSelf.goodImageView forKey:@"imageUrl"];
                [tempDic setObject:strongSelf.goodSubtitle forKey:@"descirb"];
                [tempDic setObject:strongSelf.goodPrice forKey:@"price"];
                [tempDic setObject:[NSString stringWithFormat:@"%d",_numAll] forKey:@"num"];
                [tempDic setObject:@"1" forKey:@"selected"];
                [tempDic setObject:@"1" forKey:@"isSale"];
                [tempDic setObject:strongSelf.goodTitle forKey:@"code"];
                
                order.tempPlistArr = [[NSMutableArray alloc] initWithCapacity:0];
                [order.tempPlistArr addObject:tempDic];
                order.immdetilyBtnStr = @"临时结算物品";
                
                [strongSelf.navigationController pushViewController:order animated:YES];
                
            }
            
        }else {
            //选择属性
            DCFeatureSelectionViewController *dcNewFeaVc = [DCFeatureSelectionViewController new];
            dcNewFeaVc.goodImageView = weakSelf.goodImageView;
            [weakSelf setUpAlterViewControllerWith:dcNewFeaVc WithDistance:kScreen_Height * 0.8 WithDirection:XWDrawerAnimatorDirectionBottom WithParallaxEnable:YES WithFlipEnable:YES];
        }
    }];

    //选择Item通知
    _dcObj = [[NSNotificationCenter defaultCenter]addObserverForName:SHOPITEMSELECTBACK object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        NSArray *selectArray = note.userInfo[@"Array"];
        NSString *num = note.userInfo[@"Num"];
        NSString *buttonTag = note.userInfo[@"Tag"];

        lastNum_ = num;
        lastSeleArray_ = selectArray;
        
        [weakSelf.collectionView reloadData];
        
        if ([buttonTag isEqualToString:@"0"]) { //加入购物车
            
            NSMutableArray *numIsExis = [NSMutableArray arrayWithContentsOfFile:[CommonMethod getFilePath]];
            NSString *num = @"1";
            long numValue = [numIsExis count];//numAll;
            if (numValue) {
                for (int i=0; i<numIsExis.count; i++) {
                    NSMutableDictionary *dic = [numIsExis objectAtIndex:i];
                    
                    
                    if ([self.goodImageView isEqualToString:[dic objectForKey:@"imageUrl"]]) {
                        
                        numValue = [[dic objectForKey:@"num"] intValue];
                        numValue += _numAll;
                        
                        [dic setObject:[NSString stringWithFormat:@"%ld",numValue] forKey:@"num"];
                        
                        [numIsExis writeToFile:[CommonMethod getFilePath] atomically:YES];
                    }
                    
                }
                
                num = [NSString stringWithFormat:@"%ld",numValue];
            }
            
            [self writeConfigFile:self.goodImageView descirb:self.goodSubtitle price:self.goodPrice num:num selected:@"0" isSale:@"1" code:self.goodTitle];
            [weakSelf setUpWithAddSuccess];
            
        }else if ([buttonTag isEqualToString:@"1"]) { //立即购买
            
            XOrderPayViewController *order = [[XOrderPayViewController alloc] init];
            NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithCapacity:0];
            [tempDic setObject:self.goodImageView forKey:@"imageUrl"];
            [tempDic setObject:self.goodSubtitle forKey:@"descirb"];
            [tempDic setObject:self.goodPrice forKey:@"price"];
            [tempDic setObject:[NSString stringWithFormat:@"%d",_numAll] forKey:@"num"];
            [tempDic setObject:@"1" forKey:@"selected"];
            [tempDic setObject:@"1" forKey:@"isSale"];
            [tempDic setObject:self.goodTitle forKey:@"code"];
            
            order.tempPlistArr = [[NSMutableArray alloc] initWithCapacity:0];
            [order.tempPlistArr addObject:tempDic];
            order.immdetilyBtnStr = @"临时结算物品";
            
            [self.navigationController pushViewController:order animated:YES];
        }
        
    }];
}

-(void)writeConfigFile:(NSString *)imageUrl descirb:(NSString *)descirb price:(NSString *)price num:(NSString *)num selected:(NSString *)selected isSale:(NSString *)isSale code:(NSString *)code{
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[CommonMethod getFilePath]]) {//如果文件不存在则创建
        NSFileManager* fm = [NSFileManager defaultManager];
        
        [fm createFileAtPath:[CommonMethod getFilePath] contents:nil attributes:nil];
    }
    
    //selected 1：表示还未选中
    //isSale   1:出售中（根据库存数做判断）
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:imageUrl,@"imageUrl",descirb,@"descirb",price,@"price",num,@"num",selected,@"selected",isSale,@"isSale",code,@"code",nil];
    
    NSMutableArray *addObj = [[NSMutableArray alloc] initWithContentsOfFile:[CommonMethod getFilePath]];
    
    if (addObj == nil) {
        addObj = [[NSMutableArray alloc] initWithCapacity:0];
        [addObj addObject:dic];
        [addObj writeToFile:[CommonMethod getFilePath] atomically:YES];
    }else{
        
        BOOL exis = NO;
        int witchDic = 0;
        for (int i=0; i<addObj.count; i++) {
            NSMutableDictionary *dics = [addObj objectAtIndex:i];
            
            
            if ([self.shopItemData.mainImgUrl isEqualToString:[dics objectForKey:@"imageUrl"]]) {
                
                exis = YES;
                witchDic = i;
                
            }
        }
        
        if (exis == YES) {
            [[addObj objectAtIndex:witchDic] setObject:[NSString stringWithFormat:@"%@",num] forKey:@"num"];
            
            [addObj writeToFile:[CommonMethod getFilePath] atomically:YES];
        }else{
            [addObj addObject:dic];
            
            [addObj writeToFile:[CommonMethod getFilePath] atomically:YES];
        }
    }
    
}

#pragma mark - 悬浮按钮
- (void)setUpSuspendView
{
    _backTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_backTopButton];
    [_backTopButton addTarget:self action:@selector(ScrollToTop) forControlEvents:UIControlEventTouchUpInside];
    [_backTopButton setImage:[UIImage imageNamed:@"btn_UpToTop"] forState:UIControlStateNormal];
    _backTopButton.hidden = YES;
    _backTopButton.frame = CGRectMake(kScreen_Width - 50, kScreen_Height - DCTopNavH - DCTopNavH, 40, 40);
}

#pragma mark - 记载图文详情
- (void)setUpGoodsWKWebView
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://weibo.com/u/5605532343"]];
    [self.webView loadRequest:request];
    
    //下拉返回商品详情View
    UIView *topHitView = [[UIView alloc] init];
    topHitView.frame = CGRectMake(0, -35, kScreen_Width, 35);
    DCLIRLButton *topHitButton = [DCLIRLButton buttonWithType:UIButtonTypeCustom];
    topHitButton.imageView.transform = CGAffineTransformRotate(topHitButton.imageView.transform, M_PI); //旋转
    [topHitButton setImage:[UIImage imageNamed:@"Details_Btn_Up"] forState:UIControlStateNormal];
    [topHitButton setTitle:@"下拉返回商品详情" forState:UIControlStateNormal];
    topHitButton.titleLabel.font = PFR12Font;
    [topHitButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [topHitView addSubview:topHitButton];
    topHitButton.frame = topHitView.bounds;
    
    [self.webView.scrollView addSubview:topHitView];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 6;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (section == 0 ||section == 2 || section == 3) ? 2 : 1;
}

#pragma mark - <UICollectionViewDelegate>
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *gridcell = nil;
    DCUserInfo *userInfo = UserInfoData;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            DCDetailGoodReferralCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DCDetailGoodReferralCellID forIndexPath:indexPath];
            cell.goodTitleLabel.text = _goodTitle;
            cell.goodPriceLabel.text = [NSString stringWithFormat:@"¥ %@",_goodPrice];
            cell.goodSubtitleLabel.text = _goodSubtitle;
            [DCSpeedy dc_setUpLabel:cell.goodTitleLabel Content:_goodTitle IndentationFortheFirstLineWith:cell.goodPriceLabel.font.pointSize * 2];
            WEAKSELF
            cell.shareButtonClickBlock = ^{
                [weakSelf setUpAlterViewControllerWith:[DCShareToViewController new] WithDistance:300 WithDirection:XWDrawerAnimatorDirectionBottom WithParallaxEnable:NO WithFlipEnable:NO];
            };
            gridcell = cell;
        }else if (indexPath.row == 1){
            DCShowTypeFourCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DCShowTypeFourCellID forIndexPath:indexPath];

            gridcell = cell;
        }

    }else if (indexPath.section == 1 || indexPath.section == 2 ){
        if (indexPath.section == 1) {
            DCShowTypeOneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DCShowTypeOneCellID forIndexPath:indexPath];

            NSString *result = [NSString stringWithFormat:@"%@ %@件",[lastSeleArray_ componentsJoinedByString:@"，"],lastNum_];
            
            cell.leftTitleLable.text = (lastSeleArray_.count == 0) ? @"点击" : @"已选";
            cell.contentLabel.text = (lastSeleArray_.count == 0) ? @"请选择该商品属性" : result;
            
            gridcell = cell;
        }else{
            if (indexPath.row == 0) {
                DCShowTypeTwoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DCShowTypeTwoCellID forIndexPath:indexPath];
                cell.contentLabel.text = (![[DCObjManager dc_readUserDataForKey:@"isLogin"] isEqualToString:@"1"]) ? @"预送地址" : userInfo.defaultAddress;//地址
                gridcell = cell;
            }else{
                DCShowTypeThreeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DCShowTypeThreeCellID forIndexPath:indexPath];
                gridcell = cell;
            }
        }
    }else if (indexPath.section == 3){
        DCDetailServicetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DCDetailServicetCellID forIndexPath:indexPath];
        NSArray *btnTitles = @[@"以旧换新",@"可选增值服务"];
        NSArray *btnImages = @[@"detail_xiangqingye_yijiuhuanxin",@"ptgd_icon_zengzhifuwu"];
        NSArray *titles = @[@"以旧换新再送好礼",@"为商品保价护航"];
        [cell.serviceButton setTitle:btnTitles[indexPath.row] forState:UIControlStateNormal];
        [cell.serviceButton setImage:[UIImage imageNamed:btnImages[indexPath.row]] forState:UIControlStateNormal];
        cell.serviceLabel.text = titles[indexPath.row];
        if (indexPath.row == 0) {//分割线
            [DCSpeedy dc_setUpLongLineWith:cell WithColor:[[UIColor lightGrayColor]colorWithAlphaComponent:0.4] WithHightRatio:0.6];
        }
        gridcell = cell;
    }else if (indexPath.section == 4){
        DCDetailPartCommentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DCDetailPartCommentCellID forIndexPath:indexPath];
        cell.backgroundColor = [UIColor orangeColor];
        gridcell = cell;
    }else if (indexPath.section == 5){
        DCDetailLikeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DCDetailLikeCellID forIndexPath:indexPath];
        gridcell = cell;
    }
    
    return gridcell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader){
        if (indexPath.section == 0) {
            DCDetailShufflingHeadView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DCDetailShufflingHeadViewID forIndexPath:indexPath];
            headerView.shufflingArray = _shufflingArray;
            reusableview = headerView;
        }else if (indexPath.section == 5){
            DCDeatilCustomHeadView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DCDeatilCustomHeadViewID forIndexPath:indexPath];
            reusableview = headerView;
        }
    }else if (kind == UICollectionElementKindSectionFooter){
        if (indexPath.section == 5) {
            DCDetailOverFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:DCDetailOverFooterViewID forIndexPath:indexPath];
            reusableview = footerView;
        }else{
            UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionElementKindSectionFooter" forIndexPath:indexPath];
            footerView.backgroundColor = DCBGColor;
            reusableview = footerView;
        }
    }
    return reusableview;
    
    ;
}

#pragma mark - item宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { //商品详情
        return (indexPath.row == 0) ? CGSizeMake(kScreen_Width, [DCSpeedy dc_calculateTextSizeWithText:_goodTitle WithTextFont:16 WithMaxW:kScreen_Width - DCMargin * 6].height + [DCSpeedy dc_calculateTextSizeWithText:_goodPrice WithTextFont:20 WithMaxW:kScreen_Width - DCMargin * 6].height + [DCSpeedy dc_calculateTextSizeWithText:_goodSubtitle WithTextFont:12 WithMaxW:kScreen_Width - DCMargin * 6].height + DCMargin * 4) : CGSizeMake(kScreen_Width, 35);
    }else if (indexPath.section == 1){//商品属性选择
        return CGSizeMake(kScreen_Width, 60);
    }else if (indexPath.section == 2){//商品快递信息
        return CGSizeMake(kScreen_Width, 60);
    }else if (indexPath.section == 3){//商品保价
        return CGSizeMake(kScreen_Width / 2, 60);
    }else if (indexPath.section == 4){//商品评价部分展示
        return CGSizeMake(kScreen_Width, 270);
    }else if (indexPath.section == 5){//商品猜你喜欢
        return CGSizeMake(kScreen_Width, (kScreen_Width / 3 + 60) * 2 + 20);
    }else{
        return CGSizeZero;
    }
}


#pragma mark - head宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return (section == 0) ?  CGSizeMake(kScreen_Width, (kScreen_Height-DCTopNavH) * 0.55) : ( section == 5) ? CGSizeMake(kScreen_Width, 30) : CGSizeZero;
}

#pragma mark - foot宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return (section == 5) ? CGSizeMake(kScreen_Width, 35) : CGSizeMake(kScreen_Width, DCMargin);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self scrollToDetailsPage]; //滚动到详情页面
    }else if (indexPath.section == 2 && indexPath.row == 0) {
        [self chageUserAdress]; //更换地址
    }else if (indexPath.section == 1){ //属性选择
        DCFeatureSelectionViewController *dcFeaVc = [DCFeatureSelectionViewController new];
        dcFeaVc.lastNum = lastNum_;
        dcFeaVc.lastSeleArray = [NSMutableArray arrayWithArray:lastSeleArray_];
        dcFeaVc.goodImageView = _goodImageView;
        [self setUpAlterViewControllerWith:dcFeaVc WithDistance:kScreen_Height * 0.8 WithDirection:XWDrawerAnimatorDirectionBottom WithParallaxEnable:YES WithFlipEnable:YES];
    }
}


#pragma mark - 视图滚动
- (void)setUpViewScroller{
    WEAKSELF
    self.collectionView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            !weakSelf.changeTitleBlock ? : weakSelf.changeTitleBlock(YES);
            weakSelf.scrollerView.contentOffset = CGPointMake(0, kScreen_Height);
        } completion:^(BOOL finished) {
            [weakSelf.collectionView.mj_footer endRefreshing];
        }];
    }];
    
    self.webView.scrollView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        [UIView animateWithDuration:0.8 animations:^{
            !weakSelf.changeTitleBlock ? : weakSelf.changeTitleBlock(NO);
            weakSelf.scrollerView.contentOffset = CGPointMake(0, 0);
        } completion:^(BOOL finished) {
            [weakSelf.webView.scrollView.mj_header endRefreshing];
        }];
        
    }];
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //判断回到顶部按钮是否隐藏
    _backTopButton.hidden = (scrollView.contentOffset.y > kScreen_Height) ? NO : YES;
}

#pragma mark - 点击事件
#pragma mark - 更换地址
- (void)chageUserAdress
{
    if (![[DCObjManager dc_readUserDataForKey:@"isLogin"] isEqualToString:@"1"]) {
        DCLoginViewController *dcLoginVc = [DCLoginViewController new];
//        [self.navigationController pushViewController:dcLoginVc animated:YES];
        [self presentViewController:dcLoginVc animated:YES completion:nil];
        return;
    }
    _adPickerView = [AddressPickerView shareInstance];
    [_adPickerView showAddressPickView];
    [self.view addSubview:_adPickerView];
    
    WEAKSELF
    _adPickerView.block = ^(NSString *province,NSString *city,NSString *district) {
        DCUserInfo *userInfo = UserInfoData;
        NSString *newAdress = [NSString stringWithFormat:@"%@ %@ %@",province,city,district];
        if ([userInfo.defaultAddress isEqualToString:newAdress]) {
            return;
        }
        userInfo.defaultAddress = newAdress;
        [userInfo save];
        [weakSelf.collectionView reloadData];
    };
}

#pragma mark - 滚动到详情页面
- (void)scrollToDetailsPage
{
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SCROLLTODETAILSPAGE object:nil];
    });
}

#pragma mark - collectionView滚回顶部
- (void)ScrollToTop
{
    if (self.scrollerView.contentOffset.y > kScreen_Height) {
        [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }else{
        WEAKSELF
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.scrollerView.contentOffset = CGPointMake(0, 0);
        } completion:^(BOOL finished) {
            [weakSelf.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        }];
    }
    !_changeTitleBlock ? : _changeTitleBlock(NO);
}

#pragma mark - 转场动画弹出控制器
- (void)setUpAlterViewControllerWith:(UIViewController *)vc WithDistance:(CGFloat)distance WithDirection:(XWDrawerAnimatorDirection)vcDirection WithParallaxEnable:(BOOL)parallaxEnable WithFlipEnable:(BOOL)flipEnable
{
    [self dismissViewControllerAnimated:YES completion:nil]; //以防有控制未退出
    XWDrawerAnimatorDirection direction = vcDirection;
    XWDrawerAnimator *animator = [XWDrawerAnimator xw_animatorWithDirection:direction moveDistance:distance];
    animator.parallaxEnable = parallaxEnable;
    animator.flipEnable = flipEnable;
    [self xw_presentViewController:vc withAnimator:animator];
    WEAKSELF
    [animator xw_enableEdgeGestureAndBackTapWithConfig:^{
        [weakSelf selfAlterViewback];
    }];
}

#pragma mark - 加入购物车成功
- (void)setUpWithAddSuccess
{
    [SVProgressHUD showSuccessWithStatus:@"加入购物车成功~"];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD dismissWithDelay:1.0];
}

#pragma 退出界面
- (void)selfAlterViewback
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:_dcObj];
}

@end
