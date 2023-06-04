//
//  InterceptorLogger.swift
//  Interceptor
//
//  Created by Chittapon Thongchim on 4/6/2566 BE.
//

import Foundation

public protocol BodyModifier {
    func modifyRequest(_ request: URLRequest, body data: Data) -> Data
    func modifyResponse(_ request: URLRequest, body data: Data) -> Data
}

struct LogModifier: BodyModifier {
    func modifyRequest(_ request: URLRequest, body data: Data) -> Data {
        data
    }
    
    func modifyResponse(_ request: URLRequest, body data: Data) -> Data {
        data
    }
}

class InterceptorLogger {
    
    let session: URLSession
    let logURL = URL(string: "http://localhost:\(Interceptor.port)")
    var bodyModifier: BodyModifier
    var dataTasks: [URLRequest: URLSessionDataTask] = [:]
    var ignoredHosts: [String] = []
    
    init(session: URLSession = .init(configuration: .interceptorDefault), bodyModifier: BodyModifier = LogModifier()) {
        self.session = session
        self.bodyModifier = bodyModifier
    }
    
    func shouldHandle(request: URLRequest) -> Bool {
        guard let host = request.url?.host else { return false }
        return ignoredHosts.filter({ host.hasSuffix($0) }).isEmpty
    }
    
    func logRequest(id: String, request: URLRequest) {
        var newRequest = request
        let body = newRequest.httpBody
        var newBody: [String: Any] = [:]
        newBody["url"] = request.url?.absoluteString
        newBody["method"] = request.httpMethod
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            newBody["headers"] = request.allHTTPHeaderFields
        }
        if let body = body {
            let bodyModified = bodyModifier.modifyRequest(request, body: body)
            newBody["body"] = (try? JSONDecoder().decode(AnyDecodable.self, from: bodyModified))?.value ?? "[Binary data]"
        }
        newRequest.url = logURL?.appendingPathComponent("log/request/\(id)")
        newRequest.httpMethod = "POST"
        newRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        newRequest.httpBody = try? JSONSerialization.data(withJSONObject: newBody)
        let task = session.dataTask(with: newRequest)
        task.resume()
        dataTasks[request] = task
    }
    
    func logResponse(id: String, request: URLRequest, response: URLResponse?, data: Data?, isMock: Bool = false) {
        var newRequest = request
        var newBody: [String: Any] = [:]
        newBody["code"] = (response as? HTTPURLResponse)?.statusCode
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            newBody["headers"] = request.allHTTPHeaderFields
        }
        if isMock {
            newBody["url"] = "mock"
        }
        if let data = data {
            let bodyModified = bodyModifier.modifyResponse(request, body: data)
            newBody["body"] = (try? JSONDecoder().decode(AnyDecodable.self, from: bodyModified))?.value ?? "[Binary data]"
        }
        newRequest.url = logURL?.appendingPathComponent("log/response/\(id)")
        newRequest.httpMethod = "POST"
        newRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        newRequest.httpBody = try? JSONSerialization.data(withJSONObject: newBody)
        let task = session.dataTask(with: newRequest)
        task.resume()
        dataTasks[request] = task
    }
    
    func cancel(request: URLRequest) {
        dataTasks[request]?.cancel()
    }
}
