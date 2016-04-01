//
//  HIstoryViewController.m
//  EcoaSmarthome
//
//  Created by Apple on 2016/3/31.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import "HIstoryViewController.h"

@interface HIstoryViewController ()

@end

@implementation HIstoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem]setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil]];
    helper = [[AlarmHelper alloc]init];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.navigationController setNavigationBarHidden:NO];
    //[self setList];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [self setList];
}

- (void)viewWillDisappear:(BOOL)animated {
    [helper closeDatabase];
    helper = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setList{
    NSLog(@"setList");
    if (helper!=nil) {
        FMResultSet *rs = [helper getAlarmHistory];
        array = [NSMutableArray array];
        while ([rs next]) {
            [array addObject:[rs resultDictionary]];
        }
        NSLog(@"%lu", (unsigned long)[array count]);
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlarmViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"alarmViewCell" forIndexPath:indexPath];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"AlarmViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    if (array != nil && [array count] >indexPath.row) {
        NSDictionary *nd = [array objectAtIndex:indexPath.row];
        //NSLog(@"%@", [nd description]);
        [cell.alarmMessage setText:[nd objectForKey:@"stime"]];
        [cell.alarmTitle setText:[nd objectForKey:@"message"]];
        int readed = [nd[@"readed"] intValue];
        //NSLog(@"%d", readed);
        if (readed==0) {
            [cell.alarmstate setImage:[UIImage imageNamed:@"alarm"]];
        }
        else {
            [cell.alarmstate setImage:[UIImage imageNamed:@"alarm_readed"]];
        }
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return array.count;
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
