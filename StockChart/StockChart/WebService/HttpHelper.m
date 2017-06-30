//
//  HttpHelper.m
//  HBDemo
//
//  Created by Vols on 2016/10/19.
//  Copyright © 2016年 Vols. All rights reserved.
//

#import "HttpHelper.h"
#import "AFNetworking.h"

#define kBaseURL    @""


@interface HttpHelper ()

@property (nonatomic, strong) NSURLSessionDownloadTask * downloadTask;

@end

@implementation HttpHelper

+ (instancetype)shared {
    
    static HttpHelper *_sharedClient = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        _sharedClient = [[self alloc] init];
    });
    
    return _sharedClient;
}

- (void)post:(NSDictionary *)data path:(NSString *)path success:(SuccessBlock)success failue:(FailureBlock)failure{
    
    NSString * hostURL = kBaseURL;
    NSMutableDictionary * params = [self handlerWithParamsDic:data];
    
    AFHTTPSessionManager *manager = [HttpHelper managerWithBaseURL:hostURL sessionConfiguration:NO];
    
    NSLog(@"request--> %@, parameters --> %@", path, params);
    
    [manager POST:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"request--> %@, responseObject --> %@", path, responseObject);
        
        if (responseObject == nil)
            success(@{@"code":@"-100",@"message":@"没有返回数据，可能服务器错误"});
        else
            success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        NSLog(@"error --> %@", error);
    }];
}


- (void)get:(NSDictionary *)data path:(NSString *)path success:(SuccessBlock)success failue:(FailureBlock)failure{
    
    NSString * hostURL = kBaseURL;
    NSMutableDictionary * params = [self handlerWithParamsDic:data];
    
    AFHTTPSessionManager *manager = [HttpHelper managerWithBaseURL:hostURL sessionConfiguration:NO];
    
    NSLog(@"request path: %@, parameters --> %@", path, params);
    
    [manager GET:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"response.URL --> %@", task.response.URL);
        NSLog(@"request--> %@, responseObject --> %@", path, responseObject);
        
        if (responseObject == nil)
            success(@{@"code":@"-100",@"message":@"没有返回数据，可能服务器错误"});
        else
            success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        NSLog(@"error --> %@", error);
    }];
}


- (NSURLSessionDownloadTask *)down:(NSString *)downURL percent:(PercentBlock)percent success:(void (^)(id, id))success failue:(FailureBlock)failure{
    
    AFHTTPSessionManager *manager = [HttpHelper managerWithBaseURL:nil sessionConfiguration:YES];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downURL]];
    
    NSURLSessionDownloadTask *downloadtask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        percent(downloadProgress.fractionCompleted);
        NSLog(@"localizedDescription = %@",downloadProgress.localizedDescription);
        NSLog(@"localizedAdditionalDescription = %@",downloadProgress.localizedAdditionalDescription);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (error) {
            failure(error);
        }else{
            success(response,filePath);
        }
    }];
    
    [downloadtask resume];
    
    _downloadTask = downloadtask;
    return downloadtask;
}



- (void)cancel{
    [_downloadTask cancel];
}

/*
 - (void)down:(NSString *)downURL percent:(CompletePercentBlock)percent{
 
 AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
 // 要下载文件的url
 NSURL *url = [NSURL URLWithString:downURL];
 // 创建请求对象
 NSURLRequest *request = [NSURLRequest requestWithURL:url];
 
 // 声明一个进度对象
 NSProgress *progress = nil;
 
 // 异步
 [[manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
 
 NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
 NSLog(@"file = %@",targetPath);
 return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
 } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
 NSLog(@"response = %@,filePath = %@",response,filePath);
 }] resume];
 
 // 使用 KVO 监听进度
 [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
 }
 
 - (void)dealloc {
 // 移除kvo监听
 [self removeObserver:self forKeyPath:@"name"];
 }
 
 - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
 if([object isKindOfClass:[NSProgress class]]) {
 // 获得进度值
 NSProgress *progress = (NSProgress *)object;
 NSLog(@"下载进度----%f",progress.fractionCompleted);
 NSLog(@"localizedDescription = %@",progress.localizedDescription);
 NSLog(@"localizedAdditionalDescription = %@",progress.localizedAdditionalDescription);
 }
 }
 */

#pragma mark - Private
// 添加公共参数
- (NSMutableDictionary *)handlerWithParamsDic:(NSDictionary *)dic{
    
    if (dic == nil)     return nil;
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    return params;
}

+ (AFHTTPSessionManager *)managerWithBaseURL:(NSString *)URLString  sessionConfiguration:(BOOL)isconfiguration{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = nil;

    NSURL *baseURL = [NSURL URLWithString:URLString];
    
    if (isconfiguration) {
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:configuration];
    }else{
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    }
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];

    return manager;
}


@end
