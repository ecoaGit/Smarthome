//
//  AlarmManager.m
//  EcoaSmarthome
//
//  Created by Apple on 2015/1/21.
//  Copyright (c) 2015年 ECOA. All rights reserved.
//

#import "AlarmManager.h"


@implementation AlarmManager

NSXMLParser *parser;
NSMutableArray *alarmList;
FMDatabase *db;


-(id) init {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *diretory = [path objectAtIndex:0];
    NSString *dbPath = [diretory stringByAppendingPathComponent:@"EcoaDatabase.db"];
    db = [FMDatabase databaseWithPath:dbPath];
    return self;
}

-(void) parseAlarm:(NSData *)data {
    parser = [[NSXMLParser alloc]initWithData:data];
    
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSLog(@"alarm parser didstartelement");
    // get attr
    if ([elementName isEqualToString:@"alarm"]) {
        //
        NSString *sigh = [attributeDict objectForKey:@"sign"];//pid
        NSString *message = [attributeDict objectForKey:@"message"];
        NSString *tag = [attributeDict objectForKey:@"tag"];
        NSString *haptm = [attributeDict objectForKey:@"haptm"];
        if (haptm != nil) {
            haptm = [haptm stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        }
        NSString *endtm = [attributeDict objectForKey:@"endtm"];
        if (endtm != nil) {
            endtm = [endtm stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        }
        NSString *hapval = [attributeDict objectForKey:@"hapval"];
        NSString *endval = [attributeDict objectForKey:@"endval"];
        
    }
    else if ([elementName isEqualToString:@"ipcam"]) {
        // ipcam alarm
        NSString *camid = [attributeDict objectForKey:@"id"];
        NSString *mode = [attributeDict objectForKey:@"mode"];
        NSString *url = [attributeDict objectForKey:@"url"];
        NSString *rip = [attributeDict objectForKey:@"rip"];
        NSString *usr = [attributeDict objectForKey:@"usr"];
        NSString *pswd = [attributeDict objectForKey:@"pswd"];
        NSString *tm = [attributeDict objectForKey:@"tm"];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSLog(@"alarm parser didendelement");
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    
}

- (int) checkForUpdate:(NSString *)pid{
    FMResultSet *rs = [db executeQuery:@"SELECT etime FROM alarm_list WHERE tag = '%@'", pid];
    if (rs != nil) {
        
    }
    else {
        NSLog(@"fix the code");
    }
    
    return 0;
}


@end
