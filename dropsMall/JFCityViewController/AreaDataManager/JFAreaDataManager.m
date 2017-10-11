//
//  JFAreaDataManager.m
//  JFFootball
//
//  Created by 张志峰 on 2016/11/18.
//  Copyright © 2016年 zhifenx. All rights reserved.
//

#import "JFAreaDataManager.h"

#import "FMDB.h"

@interface JFAreaDataManager ()

@property (nonatomic, strong) FMDatabase *db;

@end

@implementation JFAreaDataManager

static JFAreaDataManager *manager = nil;

+ (JFAreaDataManager *)shareManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)areaSqliteDBData {
    // copy"area.sqlite"到Documents中
    NSFileManager *fileManager =[NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory =[paths objectAtIndex:0];
    NSString *txtPath =[documentsDirectory stringByAppendingPathComponent:@"china_cities"];
    if([fileManager fileExistsAtPath:txtPath] == NO){
        NSString *resourcePath =[[NSBundle mainBundle] pathForResource:@"china_cities" ofType:@"db"];
        [fileManager copyItemAtPath:resourcePath toPath:txtPath error:&error];
    }
    // 新建数据库并打开
    NSString *path  = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"china_cities"];
    FMDatabase *db = [FMDatabase databaseWithPath:path];
    self.db = db;
    BOOL success = [db open];
    if (success) {
        // 数据库创建成功!
        NSLog(@"数据库创建成功!");
        NSString *sqlStr = @"CREATE TABLE IF NOT EXISTS city (id INTEGER , name TEXT ,pinyin TEXT);";
        BOOL successT = [self.db executeUpdate:sqlStr];
        if (successT) {
        // 创建表成功!
            
            NSLog(@"创建表成功!");
        }else{
            // 创建表失败!
            NSLog(@"创建表失败!");
            [self.db close];
        }
    }else{
        // 数据库创建失败!
        NSLog(@"数据库创建失败!");
        [self.db close];
    }
}

/// 所有市区的名称
- (void)cityData:(void (^)(NSMutableArray *dataArray))cityData {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    FMResultSet *result = [self.db executeQuery:@"SELECT DISTINCT name FROM city;"];
    while ([result next]) {
        NSString *cityName = [result stringForColumn:@"name"];
        [resultArray addObject:cityName];
    }
    cityData(resultArray);
}

/// 获取当前市的city_number
- (void)cityNumberWithCity:(NSString *)city cityNumber:(void (^)(NSString *cityNumber))cityNumber {
    FMResultSet *result = [self.db executeQuery:[NSString stringWithFormat:@"SELECT  id FROM city WHERE name = '%@';",city]];
    while ([result next]) {
        NSString *number = [result stringForColumn:@"id"];
        cityNumber(number);
    }
}

/// 所有区县的名称
- (void)areaData:(NSString *)cityNumber areaData:(void (^)(NSMutableArray *areaData))areaData {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSString *sqlString = [NSString stringWithFormat:@"SELECT name FROM shop_area WHERE id ='%@';",cityNumber];
    FMResultSet *result = [self.db executeQuery:sqlString];
    while ([result next]) {
        NSString *areaName = [result stringForColumn:@"name"];
        [resultArray addObject:areaName];
    }
    areaData(resultArray);
}

/// 根据city_number获取当前城市
- (void)currentCity:(NSString *)cityNumber currentCityName:(void (^)(NSString *name))currentCityName {
    FMResultSet *result = [self.db executeQuery:[NSString stringWithFormat:@"SELECT DISTINCT name FROM city WHERE id = '%@';",cityNumber]];
    while ([result next]) {
        NSString *name = [result stringForColumn:@"name"];
        currentCityName(name);
    }
}

- (void)searchCityData:(NSString *)searchObject result:(void (^)(NSMutableArray *result))result {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    FMResultSet *areaResult = [self.db executeQuery:[NSString stringWithFormat:@"SELECT  name,id,pinyin FROM city WHERE name LIKE '%@%%';",searchObject]];
    while ([areaResult next]) {

        NSString *city = [areaResult stringForColumn:@"name"];
        NSString *cityNumber = [areaResult stringForColumn:@"id"];
        NSDictionary *dataDic = @{@"super":@"",@"city":city,@"city_number":cityNumber};
        [resultArray addObject:dataDic];
    }
    
    if (resultArray.count == 0) {
        FMResultSet *cityResult = [self.db executeQuery:[NSString stringWithFormat:@"SELECT  id,name,pinyin FROM city WHERE id = '%@';",searchObject]];
        
        while ([cityResult next]) {
            NSLog(@"111122233344%@",searchObject);
//                NSString *city = [areaResult stringForColumn:@"name"];
//                NSString *cityNumber = [areaResult stringForColumn:@"id"];
//                NSDictionary *dataDic = @{@"super":@"",@"city":city,@"city_number":cityNumber};
//                [resultArray addObject:dataDic];
            }
        
        if (resultArray.count == 0) {
            FMResultSet *provinceResult = [self.db executeQuery:[NSString stringWithFormat:@"SELECT  pinyin,id,name FROM city WHERE pinyin LIKE '%@%%';",searchObject]];
            
            while ([provinceResult next]) {
                NSLog(@"222223333333344444%@",searchObject);
//                NSString *city = [areaResult stringForColumn:@"name"];
//                NSString *cityNumber = [areaResult stringForColumn:@"id"];
//                NSDictionary *dataDic = @{@"super":@"",@"city":city,@"city_number":cityNumber};
//                [resultArray addObject:dataDic];
            }
            
            //统一在数组中传字典是为了JFSearchView解析数据时方便
            if (resultArray.count == 0) {
                [resultArray addObject:@{@"city":@"抱歉",@"super":@"未找到相关位置，可尝试修改后重试!"}];
            }
        }
    }
    
    
    NSLog(@"%@",resultArray);
    //返回结果
    result(resultArray);
}

@end
