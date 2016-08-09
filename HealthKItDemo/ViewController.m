//
//  ViewController.m
//  HealthKItDemo
//
//  Created by apple2015 on 16/3/31.
//  Copyright © 2016年 apple2015. All rights reserved.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>

@interface ViewController ()
@property(nonatomic,strong)UILabel * label;
@property(nonatomic,strong)UILabel * label2;
@property(nonatomic,assign)NSInteger   step;
@property(nonatomic,copy)  NSString *  running;
@property(nonatomic,strong)HKHealthStore *healthStore ;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    
    UIButton * button =[UIButton buttonWithType:UIButtonTypeSystem];
    button.frame=CGRectMake(100, 50, 100, 30);
    
    [button setTitle:@"获取" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(asscept) forControlEvents:UIControlEventTouchUpInside];
    button.tag=1;
    [button setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:button];
    
    
    self.label=[[UILabel alloc]initWithFrame:CGRectMake(100, 100, 250, 100)];
    
    self.label.textAlignment=NSTextAlignmentCenter;
    self.label.font=[UIFont boldSystemFontOfSize:20];
    self.label.textColor=[UIColor redColor];
    [self.view addSubview:self.label];
    
    self.label2=[[UILabel alloc]initWithFrame:CGRectMake(100, 200, 250, 100)];
    
    self.label2.textAlignment=NSTextAlignmentCenter;
    self.label2.font=[UIFont boldSystemFontOfSize:20];
    self.label2.textColor=[UIColor redColor];
    [self.view addSubview:self.label2];
    
    
    
    if ([HKHealthStore isHealthDataAvailable]) {
        NSLog(@"yes");
    }
    self.healthStore = [[HKHealthStore alloc] init];
    NSSet *readObjectTypes = [NSSet setWithObjects:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning], nil];
    [self.healthStore requestAuthorizationToShareTypes:readObjectTypes readTypes:readObjectTypes completion:^(BOOL success, NSError *error) {
        if (success == YES)  {
            //授权成功
            NSLog(@"授权成功");
        } else {
            //授权失败
            NSLog(@"授权失败");
        }
    }];
    
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *date = [dateFormatter dateFromString:@"2016-03-31 00:00:00"];
//    NSLog(@"%@", date);
//    
//        HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
//        NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:date endDate:nil options:HKQueryOptionNone];
//        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:YES];
//        HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
//            if(!error && results) {
//                for(HKQuantitySample *samples in results) {
//                    NSLog(@"%@ 至 %@ : %@", samples.startDate, samples.endDate, samples.quantity);
//                }
//            } else {
//                //error
//            }
//        }];
//        [healthStore executeQuery:sampleQuery];
//
//
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond: 0];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    
    [self step:startDate];
    [self runningAndwalking:startDate];
       
}


- (void)asscept
{


    
    self.label.text=[NSString stringWithFormat:@"今天走了：%zd步",self.step];

    self.label2.text=[NSString stringWithFormat:@"今天跑了：%@",self.running];




}

-(void)step:(NSDate *)date
{

    
    NSLog(@"%@",date);
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = 1;
    HKStatisticsCollectionQuery *collectionQuery = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:nil options:HKStatisticsOptionCumulativeSum | HKStatisticsOptionSeparateBySource anchorDate:date intervalComponents:dateComponents];
    collectionQuery.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection * __nullable result, NSError * __nullable error) {
        NSLog(@"+++******%@",result.statistics);
        
        for (HKStatistics *statistic in result.statistics) {
            NSLog(@"%@ 至 %@", statistic.startDate, statistic.endDate);
            for (HKSource *source in statistic.sources) {
                if ([source.name isEqualToString:[UIDevice currentDevice].name]) {
                    NSLog(@" -- %f", [[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]]);
                    //                    NSLog(@"**** -- %f", [[statistic sumQuantity]doubleValueForUnit:[HKUnit countUnit]]);
                    self.step=[[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]];
                }
            }
        }
    };
    [self.healthStore executeQuery:collectionQuery];
    


}


- (void)runningAndwalking:(NSDate  *)date
{


    HKQuantityType *quantityType2 = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    NSDateComponents *dateComponents2 = [[NSDateComponents alloc] init];
    dateComponents2.day = 1;
    HKStatisticsCollectionQuery *collectionQuery2 = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType2 quantitySamplePredicate:nil options:HKStatisticsOptionCumulativeSum | HKStatisticsOptionSeparateBySource anchorDate:date intervalComponents:dateComponents2];
    collectionQuery2.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection * __nullable result, NSError * __nullable error) {
        NSLog(@"//////////+++******%@",result.statistics);
        for (HKStatistics *statistic in result.statistics) {
            NSLog(@"%@ 至 %@", statistic.startDate, statistic.endDate);

            for (HKSource *source in statistic.sources) {
                if ([source.name isEqualToString:[UIDevice currentDevice].name]) {
                    
                    NSLog(@" ******-- %@",  [statistic  sumQuantity]);
                    self.running=[NSString stringWithFormat:@"%@",[statistic  sumQuantity]];
                }
            }
        }
    };
    [self.healthStore executeQuery:collectionQuery2];


    
}


@end

