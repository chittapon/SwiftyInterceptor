//
//  InterceptorLoader.m
//  Interceptor
//
//  Created by Chittapon Thongchim on 25/5/2566 BE.
//

#import "InterceptorLoader.h"
#import <SwiftyInterceptor/SwiftyInterceptor-Swift.h>

@implementation InterceptorLoader

+ (void)load {
    [Interceptor configure];
}
@end
