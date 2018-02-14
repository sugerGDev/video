//
//  SJRequestProxy.m
//  SJProject
//
//  Created by sharejoy_SJ on 16-10-18.
//  Copyright © 2016年 wSJ. All rights reserved.
//
#import <YYKit.h>
#import "SJRequestProxy.h"



//基本url，可定义成全局变量或者宏， 拼接URL使用
#define BaseUrl @"http://m2.qiushibaike.com"


@interface SJRequestProxy ()

@property (nonatomic, strong) YYThreadSafeDictionary *dispatchTable;
@property (nonatomic, strong) NSNumber *recordedRequestId;

//AFNetworking stuff
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation SJRequestProxy


-(instancetype)init{
self = [super init];
if (self) {
    self.httpHost = BaseUrl;
}

return self;
}

#pragma mark - getters and setters
- (YYThreadSafeDictionary *)dispatchTable
{
    if (_dispatchTable == nil) {
        _dispatchTable = [[YYThreadSafeDictionary alloc] initWithCapacity:20];
    }
    return _dispatchTable;
}

- (AFHTTPSessionManager *)sessionManager
{
    if (_sessionManager == nil) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain",nil];
        
//        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];  //都在具体请求里设置
//        [_sessionManager.securityPolicy setAllowInvalidCertificates:NO]; //设置这句话可以支持发布测试url
    }
    return _sessionManager;
}

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static SJRequestProxy *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SJRequestProxy alloc] init];
    });
    return sharedInstance;
}

#pragma mark - 公有方法

- (NSInteger)callGETWithParams:(NSDictionary *)params uri:(NSString *)uri  headers:(NSDictionary*)headers methodName:(NSString *)methodName isDefaultHost:(BOOL)isDefaultHost success:(SJProxyCallback)success fail:(SJProxyCallback)fail {
#warning 如果有加密需求，可以在这个类里设置公共的一些加密字段及value
//    headers = [NSDictionary sjHeaderForGETComplementWithHeader:headers];
//    params = [NSDictionary sjParamsForGETComplementWithParams:params];
    
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.sessionManager.requestSerializer.timeoutInterval = kSJNCacheOverdueSeconds;
    
    [self fillHeader:headers];
    
    NSNumber *requestId = [self callApiWithParams:params uri:uri methodName:methodName requestType:REQUEST_GET isDefaultHost:isDefaultHost success:success fail:fail upload:nil ];
    
    return [requestId integerValue];
}

- (NSInteger)callPOSTWithParams:(NSDictionary *)params uri:(NSString *)uri  headers:(NSDictionary*)headers methodName:(NSString *)methodName isDefaultHost:(BOOL)isDefaultHost success:(SJProxyCallback)success fail:(SJProxyCallback)fail  {
    
//    headers = [NSDictionary sjHeaderForPOSTComplementWithHeader:headers];
    
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.sessionManager.requestSerializer.timeoutInterval = kSJNCacheOverdueSeconds;
    
    [self fillHeader:headers];
    
    NSNumber *requestId = [self callApiWithParams:params uri:uri methodName:methodName requestType:REQUEST_POST isDefaultHost:isDefaultHost success:success fail:fail upload:nil ];
    
    return [requestId integerValue];
}

- (NSInteger)callUPLOADWithParams:(NSDictionary *)params url:(NSString *)url headers:(NSDictionary *)headers uploads:(NSDictionary *)uploads methodName:(NSString *)methodName isDefaultHost:(BOOL)isDefaultHost success:(SJProxyCallback)success fail:(SJProxyCallback)fail  {
//    headers = [NSDictionary sjHeaderForPOSTComplementWithHeader:headers];
    
    [self.sessionManager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    self.sessionManager.requestSerializer.timeoutInterval = 60.0f;
    [self fillHeader:headers];
    
    multipart upload = ^(id<AFMultipartFormData> formData){
        NSMutableArray *filepart = [uploads objectForKey:@"fileparts"];
        NSString *filename = [uploads objectForKey:@"filename"];

        [filepart enumerateObjectsUsingBlock:^(NSData *imageData, NSUInteger idx, BOOL *stop) {

            [formData appendPartWithFileData:imageData
                                        name:[NSString stringWithFormat:@"%@",filename]
                                    fileName:[NSString stringWithFormat:@"image%ld.jpg",idx]mimeType:@"image/jpeg"];
        }];

    };
    NSNumber *requestId = [self callApiWithParams:params uri:url methodName:methodName requestType:REQUEST_UPLOAD  isDefaultHost:isDefaultHost success:success fail:fail upload:upload];
    return [requestId integerValue];
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID
{
    NSURLSessionDataTask *dataTask = [self.dispatchTable objectForKey:requestID];
    [dataTask cancel];
    [self.dispatchTable setNilValueForKey:requestID.stringValue];
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList
{
    for (NSNumber *requestId in requestIDList) {
        [self cancelRequestWithRequestID:requestId];
    }
}

#pragma mark - 私有方法

/** 这个函数存在的意义在于，如果将来要把AFNetworking换掉，只要修改这个函数的实现即可。因为最终调用三方的主要代码都在这个方法里 */
- (NSNumber *)callApiWithParams:(NSDictionary *)params uri:(NSString *)uri methodName:(NSString *)methodName requestType:(RequestType)type isDefaultHost:(BOOL)isDefaultHost success:(SJProxyCallback)success fail:(SJProxyCallback)fail upload:(multipart)upload  {
    
    // 之所以不用getter，是因为如果放到getter里面的话，每次调用self.recordedRequestId的时候值就都变了，违背了getter的初衷(配合setter, 值才会变)
    NSNumber *requestId = [self generateRequestId];
    
    //AFN回调成功的block, 内部会将返回的参数转成SJAPIResponse, 在调用BaseManager中的success:(AXCallback)success的block实现回调(即从BaseManager中传进来一个block, 回调成功把这个block参数一填, 外部就回调了)
    suceesBlock sblk = ^(NSURLSessionDataTask *task, id reponseObject) {
        //假设连续发出请求, recordedRequestId连续增加, 这里的requestId为什么不会用最大的值, 因为block引用的值会引用当时该变量的值, 调用这个方法的时候, 定义了这个block时如果requestId = 2, 即使连续增长至5, 回调的时候requestId依然会是2
        NSURLSessionDataTask *storedTask = [self.dispatchTable objectForKey:requestId];
        
        if (storedTask == nil) {
            // 如果这个operation是被cancel的(即self.dispatchTable中对应的operation已被删除了), 那就不用处理回调了。
            return;
        } else {
            [self.dispatchTable setNilValueForKey:requestId.stringValue];//成功返回数据, 删除掉request记录
        }
        
        
        SJResponse *response = [[SJResponse alloc] initWithRequestId:requestId request:task.originalRequest params:params reponseObject:reponseObject];
        
        success ? success(response) : nil;
        
    };
    
    
    failureBlock fblk =  ^(NSURLSessionDataTask *task, NSError *error) {
        
        NSURLSessionDataTask *storedTask = [self.dispatchTable objectForKey:requestId];
        
        if (storedTask == nil) {
            return;
        } else {
            [self.dispatchTable setNilValueForKey:requestId.stringValue];
        }
        
        SJResponse *response = [[SJResponse alloc] initWithRequestId:requestId request:task.originalRequest params:params error:error];
        
        fail?fail(response):nil;
        
    };
    
    
    // 跑到这里的block的时候，就已经是主线程了。
    //返回的类型就是AFHTTPRequestOperation, 含请求头, 响应头等信息, 发起一个请求之后就会返回这个对象, 只不过内部的response为(null), 回调成功之后这个对象的response就会赋值真正的响应头
    NSURLSessionDataTask *urlSessionDataTask;  //返回的类型就是AFHTTPRequestOperation, 含请求头, 响应头等信息
    NSString *requestURL = [self _generatingHttpHostWithURI:uri isDefaultHost:isDefaultHost];

    switch (type) {
        case REQUEST_GET:
            urlSessionDataTask = [self.sessionManager GET:requestURL parameters:params progress:nil success:sblk failure:fblk];
            break;
        case REQUEST_POST:
            urlSessionDataTask = [self.sessionManager POST:requestURL parameters:params progress:nil success:sblk failure:fblk];
            break;
        case REQUEST_UPLOAD:
            urlSessionDataTask = [self.sessionManager POST:requestURL parameters:params constructingBodyWithBlock:upload progress:nil success:sblk failure:fblk];
            break;
            
        default:
            break;
    }

    //发出请求之后立即将httpRequestOperation加进dispatchTable
    [self.dispatchTable setValue:urlSessionDataTask forKey:requestId.stringValue];
    
    return requestId;
}

//生成的id在本次APP生命周期内一直递增, 会一直记录
- (NSNumber *)generateRequestId
{
    if (_recordedRequestId == nil) {
        _recordedRequestId = @(1);
    } else {
        if ([_recordedRequestId integerValue] == NSIntegerMax) {
            _recordedRequestId = @(1);
        } else {
            _recordedRequestId = @([_recordedRequestId integerValue] + 1);
        }
    }
    return _recordedRequestId;
}

-(void)fillHeader:(NSDictionary* )headers
{
    if (nil != headers) {
        for (id key in headers) {
            [self.sessionManager.requestSerializer setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
    }
}

/**
 * 生成请求URL
 * @param uri 当前URI
 * @param isDefaultHost 是否用默认是否用HOST
 * @return 请求的URL
 */
- (NSString *)_generatingHttpHostWithURI:(NSString *)uri isDefaultHost:(BOOL)isDefaultHost{
    
    NSString *url = nil;
    
    if (isDefaultHost){
       url = [NSString stringWithFormat:@"%@/%@",self.httpHost,uri];
        
    } else{
        url = [uri copy];
    }
    
    NSLog(@"request url is >>>> %@",url);
    return url;
}

@end
