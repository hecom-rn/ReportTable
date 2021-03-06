//
//  ReportTableViewModel.m
//
//
//  Created by ms on 2019/11/22.
//

#import "ReportTableViewModel.h"
#import "ReportTableModel.h"
#import "ReportTableView.h"
#import <React/RCTConvert.h>
#import "ReportTableHeaderView.h"

@interface ReportTableViewModel();

@property (nonatomic, strong) ReportTableView * reportTableView;
@property (nonatomic, strong) NSMutableArray<NSArray<ItemModel *> *> *dataSource;
@property (nonatomic, strong) ReportTableModel *reportTableModel;
@property (nonatomic, strong) ReportTableHeaderScrollView *headerScrollView;
@property (nonatomic, assign) NSInteger propertyCount;
@property (nonatomic, weak) RCTBridge *bridge;
@property (nonatomic, strong) ReportTableHeaderView *headerView;

@end

@implementation ReportTableViewModel

- (NSMutableArray<NSArray<ItemModel *> *> *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (ReportTableView *)reportTableView {
    if (!_reportTableView) {
        _reportTableView = [[ReportTableView alloc] init];
        [self addSubview:_reportTableView];
    }
    return _reportTableView;
}


- (ReportTableHeaderScrollView *)headerScrollView {
    if (!_headerScrollView) {
        ReportTableHeaderView *headerView = [[ReportTableHeaderView alloc] initWithBridge:self.bridge];
        self.headerView = headerView;
        _headerScrollView = [[ReportTableHeaderScrollView alloc] init];
        _headerScrollView.showsHorizontalScrollIndicator = NO;
        _headerScrollView.showsVerticalScrollIndicator = NO;
        _headerScrollView.bounces = true;
        [_headerScrollView addSubview: headerView];
        [self.reportTableView addSubview: _headerScrollView];
    }
    return _headerScrollView;
}


- (id)initWithBridge:(RCTBridge *)bridge {
    self = [super init];
    if (self) {
        self.bridge = bridge;
        self.reportTableModel = [[ReportTableModel alloc] init];
        self.propertyCount = 0;
    }
    return self;
}

- (NSMutableArray<ForzenRange *> *)generateMergeRange:(NSArray<NSArray<ItemModel *> *>*)dataSource {
    NSMutableArray<ForzenRange *> *frozenArray = [NSMutableArray array];
    for (int i = 0; i < dataSource.count; i++) { // i columnIndex
        NSArray *rowArr = dataSource[i];
        for (int j = 0; j < rowArr.count; j ++) { // j = rowIndex
             NSInteger sameRowLength = [self jungleSameLength:[self rowWithIndex:j columnIndex:i]];
             NSInteger samecolumnLength = [self jungleSameLength:[self columnWithIndex:j columnIndex:i]];
             ItemModel *model = dataSource[i][j];
             model.horCount = sameRowLength ;
             model.verCount = samecolumnLength;
             if (sameRowLength > 1 || samecolumnLength > 1) {
                ForzenRange *forzenRange = [[ForzenRange alloc] init];
                forzenRange.startX = i;
                forzenRange.startY = j;
                forzenRange.endX = i + samecolumnLength - 1;
                forzenRange.endY = j + sameRowLength - 1;
                [frozenArray addObject:forzenRange];
             }
        }
    }
    return frozenArray;
}

- (NSInteger)jungleSameLength:(NSArray<ItemModel *> *)arr {
    if (arr.count <= 1) {
        return arr.count;
    }
    ItemModel *model = arr[0];
    if (model.used && model.used == YES) {
        return 1;
    }
    NSInteger sameLenth = [self sameLength:arr andKeyIndex:model.keyIndex];
    return sameLenth;
}

- (NSInteger)sameLength:(NSArray<ItemModel *> *)arr andKeyIndex:(NSInteger)keyIndex{
    NSInteger sameLenth = 0;
    for (int i = 0; i< arr.count; i++) {
        ItemModel *model = arr[i];
        if (model.keyIndex == keyIndex) {
            sameLenth += 1;
            if (sameLenth > 1) {
                model.used = true;
            }
        } else {
            break;
        }
    }
    return sameLenth;
}

- (NSMutableArray *)rowWithIndex:(NSInteger)rowIndex columnIndex:(NSInteger)columnIndex {
    NSMutableArray<ItemModel *> *result = [NSMutableArray array];
    NSArray *arr = self.dataSource[columnIndex];
    for (NSInteger i = rowIndex; i <arr.count; i++) {
        ItemModel *model = arr[i];
        [result addObject:model];
    }
    return result;
}

- (NSMutableArray *)columnWithIndex:(NSInteger)rowIndex columnIndex:(NSInteger)columnIndex {
    NSMutableArray<ItemModel *> *result = [NSMutableArray array];
    for (NSInteger i = columnIndex; i <self.dataSource.count; i++) {
        NSArray *arr = self.dataSource[i];
        ItemModel *model = arr[rowIndex];
        [result addObject:model];
    }
    return result;
}

- (CGFloat)getTextWidth:(NSString *)text withTextSize:(CGFloat)fontSize {
    CGFloat textW = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size.width;
    return textW + 8;
}

- (void)setData:(NSArray *)data {
    NSMutableArray *dataSource = [NSMutableArray arrayWithArray:data];
    if (self.reportTableModel.data.count > 0) {
        self.reportTableModel.data = dataSource; // update
        [self integratedDataSource];
    } else {
        self.reportTableModel.data = dataSource;
        self.propertyCount += 1;
        [self reloadCheck];
    }
}

- (void)setMinWidth:(float)minWidth {
    self.reportTableModel.minWidth = minWidth;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setMaxWidth:(float)maxWidth {
    self.reportTableModel.maxWidth = maxWidth;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setMinHeight:(float)minHeight {
    self.reportTableModel.minHeight = minHeight;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setFrozenColumns:(NSInteger)frozenColumns {
    self.reportTableModel.frozenColumns = frozenColumns;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setFrozenRows:(NSInteger)frozenRows {
    self.reportTableModel.frozenRows = frozenRows;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setOnClickEvent:(RCTDirectEventBlock)onClickEvent {
    self.reportTableModel.onClickEvent = onClickEvent;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setSize:(CGSize)size {
    self.reportTableModel.tableRect = CGRectMake(0, 0, size.width, size.height);
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setHeaderViewSize:(CGSize)headerViewSize {
    if (headerViewSize.width != 0) {
        self.headerScrollView.contentSize = CGSizeMake(headerViewSize.width, 0);
        self.headerView.frame = CGRectMake(0, 0, headerViewSize.width, headerViewSize.height);
    }
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setOnScrollEnd:(RCTDirectEventBlock)onScrollEnd {
    self.reportTableModel.onScrollEnd = onScrollEnd;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setLineColor:(UIColor *)lineColor {
    self.reportTableModel.lineColor = lineColor;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setFrozenCount:(NSInteger)frozenCount {
    self.reportTableModel.frozenCount = frozenCount;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setFrozenPoint:(NSInteger)frozenPoint {
    self.reportTableModel.frozenPoint = frozenPoint;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)reloadCheck {
    if (self.propertyCount >= 13) {
        self.propertyCount = 0;
        [self integratedDataSource];
    }
}

- (void)integratedDataSource {
    NSMutableArray *dataSource = [NSMutableArray arrayWithArray: self.reportTableModel.data];
    NSMutableArray *cloumsHight = [NSMutableArray array];
    NSMutableArray *rowsWidth = [NSMutableArray array];
    CGFloat minWidth = self.reportTableModel.minWidth; //margin
    CGFloat maxWidth = self.reportTableModel.maxWidth; //margin
    CGFloat minHeight = self.reportTableModel.minHeight;
    [self.dataSource removeAllObjects]; // clear
    
    for (int i = 0; i < dataSource.count; i++) {
       NSArray *rowArr = dataSource[i];
       NSMutableArray *modelArr = [NSMutableArray array];
       CGFloat rowWith = minWidth;
       CGFloat columnHeigt = minHeight;
       for (int j = 0; j < rowArr.count; j ++) {
           if (i == 0) {
               [rowsWidth addObject:[NSNumber numberWithFloat:minWidth]];
           }
           NSDictionary *dir = rowArr[j];
           ItemModel *model = [[ItemModel alloc] init];
           model.keyIndex = [RCTConvert NSInteger:[dir objectForKey:@"keyIndex"]];
           model.title = [RCTConvert NSString:[dir objectForKey:@"title"]];
           model.backgroundColor = [RCTConvert UIColor:[dir objectForKey:@"backgroundColor"]];
           model.fontSize = [RCTConvert CGFloat:[dir objectForKey:@"fontSize"]];
           model.textColor = [RCTConvert UIColor:[dir objectForKey:@"textColor"]];
           model.isLeft = [RCTConvert BOOL:[dir objectForKey:@"isLeft"]];
           model.textPaddingHorizontal = [RCTConvert NSInteger:[dir objectForKey:@"textPaddingHorizontal"]];
           NSDictionary *iconDic = [RCTConvert NSDictionary:[dir objectForKey:@"icon"]];
           if (iconDic != nil) {
               IconStyle *icon = [[IconStyle alloc] init];
               icon.size = CGSizeMake([[iconDic objectForKey:@"width"] floatValue], [[iconDic objectForKey:@"height"] floatValue]);
               icon.path = [iconDic objectForKey:@"path"];
               model.iconStyle = icon;
           }
           BOOL isLock = false;
           if (i == 0) {
               if (self.reportTableModel.frozenPoint > 0 && j + 1 == self.reportTableModel.frozenPoint) {
                   isLock = true;
               } else if (self.reportTableModel.frozenCount > 0 && j < self.reportTableModel.frozenCount) {
                   isLock = true;
               }
           }
           CGFloat imageIconWidth = (isLock ? 13 + 10 : iconDic != nil ? model.iconStyle.size.width + 10 : 0);
           CGFloat exceptText = 2 * model.textPaddingHorizontal + imageIconWidth; //margin
           CGFloat textW = [self getTextWidth: model.title withTextSize: model.fontSize];
           if (textW > minWidth - exceptText) {
               if (textW < maxWidth - exceptText) {
                   rowWith = textW + exceptText;
               } else {
                   rowWith = maxWidth;
                   NSInteger height = (ceilf(textW / (maxWidth - exceptText)) - 1) * (model.fontSize + 2) + minHeight;
                   columnHeigt = MAX(columnHeigt, height);
               }
            } else {
               rowWith = minWidth;
            }
            if ([rowsWidth[j] floatValue] < rowWith) {
               rowsWidth[j] = [NSNumber numberWithFloat:rowWith];
            }
    
            [modelArr addObject:model];
        }
        [cloumsHight addObject:[NSNumber numberWithFloat:columnHeigt]];
        [self.dataSource addObject:modelArr];
    }
    for (int i = 0; i < rowsWidth.count; i++) {
        rowsWidth[i] = [NSNumber numberWithFloat: [rowsWidth[i] floatValue] - 1 - 1.0/rowsWidth.count];
    }
    NSMutableArray<ForzenRange *> *frozenArray = [self generateMergeRange:self.dataSource];
    self.reportTableModel.frozenArray = frozenArray;
    self.reportTableModel.dataSource = self.dataSource;
    self.reportTableModel.rowsWidth = rowsWidth;
    self.reportTableModel.cloumsHight = cloumsHight;
    
    CGFloat tableHeigt = 1;
    for (int i = 0; i < cloumsHight.count; i++) {
        tableHeigt += [cloumsHight[i] floatValue] + 1; // speHeight
    }
    
    CGSize headerSize = self.headerView.frame.size;
    tableHeigt += headerSize.height;
    self.headerScrollView.frame = CGRectMake(0, 0, self.reportTableModel.tableRect.size.width, headerSize.height);
    self.reportTableView.headerScrollView = self.headerScrollView;

    CGRect tableRect = self.reportTableModel.tableRect;
    tableRect.size.height = MIN(tableRect.size.height, tableHeigt);
    self.reportTableView.frame = tableRect;
    
    self.reportTableView.reportTableModel = self.reportTableModel;
}

@end
