//
//  ProxyProtocol.swift
//  Interceptor
//
//  Created by Chittapon Thongchim on 25/5/2566 BE.
//

import Foundation

class ProxyProtocol: URLProtocol {

    lazy var session = URLSession(configuration: .interceptor_default(), delegate: self, delegateQueue: nil)
    let requestId = UUID().uuidString
    var sessionTask: URLSessionDataTask?
    var responseData: Data?
    var response: URLResponse?
    
    override class func canInit(with request: URLRequest) -> Bool {
        let usingStub = Interceptor.stubber.shouldHandle(request: request)
        let usingMock = Interceptor.mocker.shouldHandle(request: request)
        let usingLog = Interceptor.logger.shouldHandle(request: request)
        return usingStub || usingMock || usingLog
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if Interceptor.stubber.shouldHandle(request: request) {
            /// Do not send request over network
            Interceptor.stubber.sendRequest(with: self)
        } else {
            if Interceptor.mocker.shouldHandle(request: request) {
                Interceptor.mocker.getMock(id: requestId, request: request, with: self)
            } else {
                /// Send request over network and log request/response
                sessionTask = session.dataTask(with: request)
                sessionTask?.resume()
            }
            if Interceptor.logger.shouldHandle(request: request) {
                Interceptor.logger.logRequest(id: requestId, request: request)
            }
        }
    }
    
    override func stopLoading() {
        sessionTask?.cancel()
        session.invalidateAndCancel()
        /// Log real request
        if sessionTask != nil {
            Interceptor.onResponse?(request, response as? HTTPURLResponse, responseData)
            Interceptor.logger.logResponse(id: requestId, request: request, response: response, data: responseData)
        }
    }
    
}

extension ProxyProtocol: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
        if responseData == nil {
            responseData = data
        } else {
            responseData?.append(data)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        self.response = response
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error else { return }
        client?.urlProtocol(self, didFailWithError: error)
    }
}
