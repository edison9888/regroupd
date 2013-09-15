//
//  Blocpad_Tests.m
//  Blocpad Tests
//
//  Created by Hugh Lang on 3/26/13.
//
//

#import "Blocpad_Tests.h"
#import "WebServiceClass.h"
#import "SBJson.h"
#import "TraccsCalculation.h"
#import "TraccsContract.h"
#import "TraccsRebateHistory.h"
#import "TraccsVialHistory.h"
#import "SQLiteDB.h"

@implementation Blocpad_Tests

static NSString *kTraccsGetCalculationIdRequestFormat = @"TraccsServiceGetCalculation?$format=json";
static NSString *kTraccsRebateHistoryRequestFormat = @"TraccsServiceGetRebateHistory?&$format=json";
static NSString *kTraccsCurrentCalculationRequestFormat = @"TraccsServiceGetCurrentCalculationId?calcID=%@&$format=json";
static NSString *kTraccsContractsRequestFormat = @"TraccsServiceGetContractsByCalculationId?calcID=%@&$format=json";
static NSString *kTraccsVialHistoryRequestFormat = @"TraccsServiceGetVialHistoryByCalculationId?calcID=%@&$format=json";

static NSString *kSearchTextFormat = @"%@##%@##%@##%i";


- (void)setUp
{
    [super setUp];
    _calcId = 18;
    saveData = YES;
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testGetCalculation
{
    NSLog(@"%s", __FUNCTION__);
    WebServiceClass *ws = [[WebServiceClass alloc] init];
    
    NSData *data = [ws callWebService:kTraccsGetCalculationIdRequestFormat];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict;
    NSDictionary *resultData;
    
    NSString *jsonKey = @"TraccsServiceGetCalculation";
    NSString *text;
    NSString *tmp;
    
    dict = (NSDictionary *) [jsonParser objectWithData:data];;
    NSInteger calcId = 0;
    
    if (dict != nil) {
        NSLog(@"dict = %@", dict);
        NSDictionary *object = [dict objectForKey:@"d"];
        if (object != nil) {
//            NSLog(@"object = %@", object);
            
            tmp = (NSString *) [object objectForKey:jsonKey];
            tmp = [tmp stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
//            NSLog(@"tmp = %@", tmp);
            
            NSArray *resultRow = (NSArray *)[jsonParser objectWithString:tmp];
            
            if (resultRow != nil && resultRow.count > 0) {
                resultData = (NSDictionary *) [resultRow objectAtIndex:0];
//                NSLog(@"resultData = %@", resultData);
                
                text = (NSString *) [resultData objectForKey:@"CalculationId"];
                NSLog(@"text=%@", text);
                
                calcId = text.integerValue;
                
            }
        }
    }
    if (calcId != 0 && saveData) {
        NSLog(@"calcId=%i", calcId);
        
        NSString *deleteSql = @"DELETE from config;";
        [[SQLiteDB testConnection] executeUpdate:deleteSql];
        
        NSString *insertSql = @"INSERT INTO config (calcId) VALUES (?);";
        // Use NSNumber to wrap params:  http://stackoverflow.com/questions/9347377/fmdb-executeupdate-fails
        BOOL success = [[SQLiteDB testConnection] executeUpdate:insertSql,
                        [NSNumber numberWithInt:calcId]
                        ];
        
        if (!success) {
            NSLog(@"################################### SQL Insert failed ###################################");
        } else {
            NSLog(@"=================================== SQL INSERT SUCCESS ===================================");
        }
        
        
    }
    
}

- (void)testGetCurrentCalculation
{
    NSLog(@"%s", __FUNCTION__);
    TraccsCalculation *traccsResult = [self getTraccsCalculation:(_calcId)];
    NSLog(@"calculation row=%@", traccsResult.toString);
    
    NSString *insertSql = @"INSERT INTO calculation (calcId, calcDate, qtrname, vialPrice, finalInd) VALUES (?, ?, ?, ?, ?);";
    if (saveData) {
        
        NSString *deleteSql = @"DELETE from calculation;";
        [[SQLiteDB testConnection] executeUpdate:deleteSql];
        
        BOOL success = [[SQLiteDB testConnection] executeUpdate:insertSql,
                        [NSNumber numberWithInt:_calcId],
                        traccsResult.calculationDate,
                        traccsResult.name,
                        [NSNumber numberWithDouble:traccsResult.vialPrice],
                        [NSNumber numberWithInt:traccsResult.finalInd]
                        ];
        
        if (!success) {
            NSLog(@"################################### SQL Insert failed ###################################");
        } else {
            NSLog(@"=================================== SQL INSERT SUCCESS ===================================");
        }
    }
    
}


- (void)testGetContracts
{
    NSLog(@"%s", __FUNCTION__);
    
    NSMutableArray *resultsArray = [self getContracts];
    
    NSLog(@"row count = %i", resultsArray.count);
    
    //    @synthesize contractId, groupName, city, state, zipcode, gpoName, territory, effectiveDate, avgPrevYear, specialInd, newInd;
    if (saveData) {
        NSString *deleteSql = @"DELETE from contract;";
        [[SQLiteDB testConnection] executeUpdate:deleteSql];
        NSString *insertSql = @"INSERT INTO contract (contractId, groupName, city, state, zipcode, camName, territory, effectiveDate, gpoName, avgPrevYear, specialInd, newInd, search_text) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
        TraccsContract *dataRow;
        
        for (int i=0; i<resultsArray.count; i++) {
            dataRow = (TraccsContract *) [resultsArray objectAtIndex:i];
            NSString *searchText = [NSString stringWithFormat:kSearchTextFormat, dataRow.groupName, dataRow.city, dataRow.zipcode, dataRow.contractId];
            //            NSLog(@"%@", searchText);
            
            BOOL success = [[SQLiteDB testConnection] executeUpdate:insertSql,
                            [NSNumber numberWithInt:dataRow.contractId],
                            dataRow.groupName,
                            dataRow.city,
                            dataRow.state,
                            dataRow.zipcode,
                            dataRow.camName,
                            dataRow.territory,
                            dataRow.effectiveDate,
                            dataRow.gpoName,
                            [NSNumber numberWithDouble:dataRow.avgPrevYear],
                            [NSNumber numberWithInt:dataRow.specialInd],
                            [NSNumber numberWithInt:dataRow.newInd],
                            searchText
                            ];
            
            if (!success) {
                NSLog(@"################################### SQL Insert failed ###################################");
                //        } else {
                //            NSLog(@"=================================== SQL INSERT SUCCESS ===================================");
            }
        }
        
    }
    
    
}

- (void)testGetRebateHistory
{
    NSLog(@"%s", __FUNCTION__);
    
    NSMutableArray *resultsArray = [self getRebateHistory];
    
    NSLog(@"row count = %i", resultsArray.count);
    
    if (saveData) {
        NSString *deleteSql = @"DELETE from rebate_history;";
        [[SQLiteDB testConnection] executeUpdate:deleteSql];
        
        NSString *insertSql = @"INSERT INTO rebate_history (contractId, qtrname, totalRebateAdj) VALUES (?, ?, ?);";
        TraccsRebateHistory *dataRow;
        
        for (int i=0; i<resultsArray.count; i++) {
            dataRow = (TraccsRebateHistory *) [resultsArray objectAtIndex:i];
            
            BOOL success = [[SQLiteDB testConnection] executeUpdate:insertSql,
                            [NSNumber numberWithInt:dataRow.contractId],
                            dataRow.qtrname,
                            [NSNumber numberWithDouble:dataRow.totalRebateAdj]
                            ];
            
            if (!success) {
                NSLog(@"################################### SQL Insert failed ###################################");
                //        } else {
                //            NSLog(@"=================================== SQL INSERT SUCCESS ===================================");
            }
        }
        
    } 
}



- (void)testGetVialHistory
{
    NSLog(@"%s", __FUNCTION__);
    
    NSMutableArray *resultsArray = [self getVialHistory];
    
    NSLog(@"row count = %i", resultsArray.count);
    
    if (saveData) {
        
        NSString *deleteSql = @"DELETE from vial_history;";
        [[SQLiteDB testConnection] executeUpdate:deleteSql];
        NSString *insertSql = @"INSERT INTO vial_history (contractId, qtrname, actUnits) VALUES (?, ?, ?);";
        TraccsVialHistory *dataRow;
        
        for (int i=0; i<resultsArray.count; i++) {
            dataRow = (TraccsVialHistory *) [resultsArray objectAtIndex:i];
            
            BOOL success = [[SQLiteDB testConnection] executeUpdate:insertSql,
                            [NSNumber numberWithInt:dataRow.contractId],
                            dataRow.qtrname,
                            [NSNumber numberWithInt:dataRow.actUnits]
                            ];
            
            if (!success) {
                NSLog(@"################################### SQL Insert failed ###################################");
                //        } else {
                //            NSLog(@"=================================== SQL INSERT SUCCESS ===================================");
            }
        }
    }
    
    
}

#pragma mark -- data access methods

- (TraccsCalculation *)getTraccsCalculation:(NSInteger)calcId {
    WebServiceClass *ws = [[WebServiceClass alloc] init];
    
    NSString *idKey = [NSString stringWithFormat:@"%i", calcId];
    NSString *requestUrl = [NSString stringWithFormat:kTraccsCurrentCalculationRequestFormat, idKey];
    
    NSData *data = [ws callWebService:requestUrl];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict;
    NSDictionary *resultData;
    
    NSString *jsonKey = @"TraccsServiceGetCurrentCalculationId";
    NSString *text;
    NSString *tmp;
    TraccsCalculation *traccsResult = [[TraccsCalculation alloc] init];
    
    dict = (NSDictionary *) [jsonParser objectWithData:data];;
    
    if (dict != nil) {
        NSLog(@"dict = %@", dict);
        NSDictionary *object = [dict objectForKey:@"d"];
        if (object != nil) {
            NSLog(@"object = %@", object);
            
            tmp = (NSString *) [object objectForKey:jsonKey];
            tmp = [tmp stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
            NSLog(@"tmp = %@", tmp);
            
            NSArray *resultRow = (NSArray *)[jsonParser objectWithString:tmp];
            
            if (resultRow != nil && resultRow.count > 0) {
                resultData = (NSDictionary *) [resultRow objectAtIndex:0];
                NSLog(@"resultData = %@", resultData);
                
                
                traccsResult.name = (NSString *) [resultData objectForKey:@"Name"];
                
                text = (NSString *) [resultData objectForKey:@"CalculationDate"];
                traccsResult.calculationDate = text;
                
                text = (NSString *) [resultData objectForKey:@"FinalInd"];
                
                //                NSLog(@"FinalInd=%@", text);
                traccsResult.finalInd = text.intValue;
                
                text = (NSString *) [resultData objectForKey:@"VialPrice"];
                
                traccsResult.vialPrice = text.doubleValue;
                
                NSLog(@"%@", traccsResult.toString);
                
            }
        }
    }
    return traccsResult;
}
- (NSMutableArray *)getRebateHistory {
    WebServiceClass *ws = [[WebServiceClass alloc] init];
    
    NSData *data = [ws callWebService:kTraccsRebateHistoryRequestFormat];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict;
    NSDictionary *dataRow;
    
    NSString *jsonKey = @"TraccsServiceGetRebateHistory";
    NSString *text;
    NSString *tmp;
    
    dict = (NSDictionary *) [jsonParser objectWithData:data];
    
    NSMutableArray *resultsArray = [[NSMutableArray alloc] init];
    TraccsRebateHistory *row;
    
    if (dict != nil) {
        NSDictionary *object = [dict objectForKey:@"d"];
        if (object != nil) {
            
            tmp = (NSString *) [object objectForKey:jsonKey];
            tmp = [tmp stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
            
            NSArray *dataRows = (NSArray *)[jsonParser objectWithString:tmp];
            NSLog(@"REBATE HISTORY dataRows count = %i", dataRows.count);

            for (int i=0; i<dataRows.count; i++) {
                row = [[TraccsRebateHistory alloc] init];
                dataRow = (NSDictionary *) [dataRows objectAtIndex:i];
                
                text = (NSString *) [dataRow objectForKey:@"contractid"];
                row.contractId = text.integerValue;
                
                text = (NSString *) [dataRow objectForKey:@"Name"];
                row.qtrname = text;
                
                text = (NSString *) [dataRow objectForKey:@"TotalRebateAdj"];
                row.totalRebateAdj = text.doubleValue;
                
//                NSLog(@"row = %@", row.toString);
                
                [resultsArray addObject:row];
                
                
            }
        }
    }
    return resultsArray;
}
- (NSMutableArray *)getContracts {
    WebServiceClass *ws = [[WebServiceClass alloc] init];
    
    NSString *idKey = [NSString stringWithFormat:@"%i", _calcId];
    NSString *requestUrl = [NSString stringWithFormat:kTraccsContractsRequestFormat, idKey];
    
    NSData *data = [ws callWebService:requestUrl];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict;
    NSDictionary *dataRow;
    
    NSString *jsonKey = @"TraccsServiceGetContractsByCalculationId";
    NSString *text;
    NSString *tmp;
    
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    
    dict = (NSDictionary *) [jsonParser objectWithData:data];
    
    NSMutableArray *resultsArray = [[NSMutableArray alloc] init];
    TraccsContract *row;
    //  contractId, groupName, city, state, zipcode, gpoName, terrName, effectiveDate, avgPrevYear, specialInd, newInd;
    
    if (dict != nil) {
        NSLog(@"dict = %@", dict);
        NSDictionary *object = [dict objectForKey:@"d"];
        if (object != nil) {
            
            tmp = (NSString *) [object objectForKey:jsonKey];
            tmp = [tmp stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
            
            NSArray *dataRows = (NSArray *)[jsonParser objectWithString:tmp];
            NSLog(@"CONTRACT dataRows count = %i", dataRows.count);
            
            for (int i=0; i<dataRows.count; i++) {
                row = [[TraccsContract alloc] init];
                dataRow = (NSDictionary *) [dataRows objectAtIndex:i];
                
                text = (NSString *) [dataRow objectForKey:@"ContractId"];
                row.contractId = text.integerValue;
                
                text = (NSString *) [dataRow objectForKey:@"GroupName"];
                row.groupName = text;
                
                text = (NSString *) [dataRow objectForKey:@"City"];
                row.city = text;
                
                text = (NSString *) [dataRow objectForKey:@"State"];
                row.state = text;
                
                text = (NSString *) [dataRow objectForKey:@"ZipCode"];
                row.zipcode = text;
                
                text = (NSString *) [dataRow objectForKey:@"Camname"];
                row.camName = text;
                
                text = (NSString *) [dataRow objectForKey:@"GPOName"];
                row.gpoName = text;
                
                text = (NSString *) [dataRow objectForKey:@"terrname"];
                row.territory = text;
                
                text = (NSString *) [dataRow objectForKey:@"ContractEffectiveDate"];
                row.effectiveDate = text;
                
                text = (NSString *) [dataRow objectForKey:@"AvgPrevYear"];
                @try {
                    row.avgPrevYear = text.doubleValue;
                }
                @catch (NSException *exception) {
                    NSLog(@"FAIL: AvgPrevYear value: %@", text);
                    row.avgPrevYear = 0;
                }
                
                
                text = (NSString *) [dataRow objectForKey:@"SpecialInd"];
                row.specialInd = text.integerValue;
                
                text = (NSString *) [dataRow objectForKey:@"NewInd"];
                row.newInd = text.integerValue;
                
                //                NSLog(@"row = %@", row.toString);
                
                [resultsArray addObject:row];
                
                
            }
        }
    }
    return resultsArray;
}

- (NSMutableArray *)getVialHistory {
    WebServiceClass *ws = [[WebServiceClass alloc] init];
    
    NSString *_id = [NSString stringWithFormat:@"%i", _calcId];
    
    NSString *requestUrl = [NSString stringWithFormat:kTraccsVialHistoryRequestFormat, _id];
    
    NSData *data = [ws callWebService:requestUrl];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict;
    NSDictionary *dataRow;
    
    NSString *jsonKey = @"TraccsServiceGetVialHistoryByCalculationId";
    NSString *text;
    NSString *tmp;
    
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    
    dict = (NSDictionary *) [jsonParser objectWithData:data];
    
    NSMutableArray *resultsArray = [[NSMutableArray alloc] init];
    TraccsVialHistory *row;
    
    if (dict != nil) {
        NSDictionary *object = [dict objectForKey:@"d"];
        if (object != nil) {
            tmp = (NSString *) [object objectForKey:jsonKey];
            tmp = [tmp stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
            
            NSArray *dataRows = (NSArray *)[jsonParser objectWithString:tmp];
            NSLog(@"VIAL HISTORY dataRows count = %i", dataRows.count);
            
            for (int i=0; i<dataRows.count; i++) {
                row = [[TraccsVialHistory alloc] init];
                dataRow = (NSDictionary *) [dataRows objectAtIndex:i];
                
                text = (NSString *) [dataRow objectForKey:@"contractid"];
                row.contractId = text.integerValue;
                
                text = (NSString *) [dataRow objectForKey:@"qtrname"];
                row.qtrname = text;
                
                text = (NSString *) [dataRow objectForKey:@"ActUnits"];
                row.actUnits = text.integerValue;
                
//                NSLog(@"row = %@", row.toString);
                
                [resultsArray addObject:row];
                
                
            }
        }
    }
    return resultsArray;
}

@end
