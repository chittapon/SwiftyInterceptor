//
//  InterceptorStubber.swift
//  Interceptor
//
//  Created by Chittapon Thongchim on 4/6/2566 BE.
//

import Foundation

class InterceptorStubber {
    var stubResponseHandler: StubResponseHandler?
    
    func shouldHandle(request: URLRequest) -> Bool {
        stubResponseHandler?(request) != nil
    }
    
    func sendRequest(with proxy: ProxyProtocol) {
        guard let stub = stubResponseHandler?(proxy.request) else { return }
        if let response = stub.response {
            proxy.client?.urlProtocol(proxy, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let data = stub.body {
            proxy.client?.urlProtocol(proxy, didLoad: data)
        }
        let finishLoading = {
            proxy.client?.urlProtocolDidFinishLoading(proxy) ?? ()
            Interceptor.onResponse?(proxy.request, stub.response, stub.body)
        }
        stub.delay.map({ asyncAfter(delay: $0, excute: finishLoading) }) ?? finishLoading()
    }
    
    func asyncAfter(delay: TimeInterval, excute: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: excute)
    }
}
