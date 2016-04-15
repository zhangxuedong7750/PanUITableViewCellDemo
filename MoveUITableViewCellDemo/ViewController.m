//
//  ViewController.m
//  MoveUITableViewCellDemo
//
//  Created by 张雪东 on 16/4/15.
//  Copyright © 2016年 张雪东. All rights reserved.
//

#import "ViewController.h"

static NSString *const identifier = @"tableViewCell";

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView *snapView;
@property (nonatomic, strong) NSIndexPath *sourceIndexPath;
@property (nonatomic, strong) NSIndexPath *destinationIndexPath;

@property (nonatomic, strong) NSMutableArray *contentArr;
@end

@implementation ViewController

#pragma mark 视图生命周期相关
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    self.title = @"长按拖动cell";
    
    [self addLongPressGesture];
}

#pragma mark 手势处理
-(void)addLongPressGesture{

    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longGesture];
}

-(void)longPressGestureRecognized:(id)sender{

    UILongPressGestureRecognizer *longGesture = (UILongPressGestureRecognizer *)sender;
    
    CGPoint location = [longGesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    self.destinationIndexPath = indexPath;

    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:{
            [self gestureBegan:longGesture];
        }
            break;
        case UIGestureRecognizerStateChanged:{
            [self gestureChange:longGesture];
        }
            break;
        case UIGestureRecognizerStateCancelled:{
            [self gestureEndOrCancle:longGesture];
        }
            break;
        case UIGestureRecognizerStateEnded:{
            [self gestureEndOrCancle:longGesture];
        }
            break;
        default:
            break;
    }
}

-(void)gestureBegan:(UILongPressGestureRecognizer *)longPressGesture{

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_destinationIndexPath];
    self.snapView = [self customSnapshoFromView:cell];
    self.sourceIndexPath = self.destinationIndexPath;
    
    CGPoint location = [longPressGesture locationInView:self.tableView];
    
    __block CGPoint center = cell.center;
    self.snapView.center = center;
    self.snapView.alpha = 0;
    [self.tableView addSubview:_snapView];
    
    [UIView animateWithDuration:0.2 animations:^{
       
        center.y = location.y;
        self.snapView.center = center;
        self.snapView.transform = CGAffineTransformMakeScale(1.05, 1.05);
        self.snapView.alpha = 0.98;
        
        cell.hidden = YES;
    }];
}

-(void)gestureChange:(UILongPressGestureRecognizer *)longPressGesture{

    CGPoint location = [longPressGesture locationInView:self.tableView];
    CGPoint center = _snapView.center;
    center.y = location.y;
    self.snapView.center = center;
    
    if (self.destinationIndexPath && ![self.destinationIndexPath isEqual:self.sourceIndexPath]) {
        [self.contentArr exchangeObjectAtIndex:_destinationIndexPath.row withObjectAtIndex:_sourceIndexPath.row];
        [self.tableView moveRowAtIndexPath:_sourceIndexPath toIndexPath:_destinationIndexPath];
        
        self.sourceIndexPath = _destinationIndexPath;
    }
}

-(void)gestureEndOrCancle:(UILongPressGestureRecognizer *)longPressGesture{
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_sourceIndexPath];
    cell.backgroundColor = [UIColor whiteColor];
    [UIView animateWithDuration:0.1 animations:^{
        
        self.snapView.center = cell.center;
        self.snapView.transform = CGAffineTransformIdentity;
        self.snapView.alpha = 0.0;
        
        cell.hidden = NO;
    } completion:^(BOOL finished) {
        
        [self.snapView removeFromSuperview];
        self.snapView = nil;
    }];
    self.sourceIndexPath = nil;
}

-(UIView *)customSnapshoFromView:(UIView *)inputView {
    
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

#pragma mark getter
-(NSArray *)contentArr{

    if (!_contentArr) {
        _contentArr = [NSMutableArray array];
        for (int i = 0; i < 20; i++) {
            [_contentArr addObject:[NSString stringWithFormat:@"这是第%d行。。。",i]];
        }
    }
    return _contentArr;
}

#pragma mark UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.contentArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.contentArr[indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 60;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
