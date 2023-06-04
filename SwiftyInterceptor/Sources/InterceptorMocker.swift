//
//  InterceptorMocker.swift
//  Interceptor
//
//  Created by Chittapon Thongchim on 4/6/2566 BE.
//

import Foundation

class InterceptorMocker {
    let session: URLSession
    let mockURL = URL(string: "http://localhost:\(Interceptor.port)")
    var uiTestingEnabled = false
    
    init(session: URLSession = .init(configuration: .interceptorDefault), uiTestingEnabled: Bool = false) {
        self.session = session
        self.uiTestingEnabled = uiTestingEnabled
    }
    
    func shouldHandle(request: URLRequest) -> Bool {
        uiTestingEnabled
    }
    
    func mock(_ mock: Mockable) {
        guard let mockURL = mockURL else { return }
        var request = URLRequest(url: mockURL.appendingPathComponent("mock/set"))
        var body: [String: Any] = [:]
        let pattern = mock.requestPattern
        let requestPattern: [String: Any] = ["method": pattern.method,
                                             "url": ["kind": pattern.url.kind.rawValue, "value": pattern.url.value]]
        body["requestPattern"] = requestPattern
        let response = mock.response
        var _response: [String: Any] = [:]
        _response["status"] = response.status
        _response["headers"] = response.headers
        _response["delay"] = response.delay
        if let data = response.body {
            _response["body"] = (try? JSONDecoder().decode(AnyDecodable.self, from: data).value) ?? "[Binary data]"
        }
        body["response"] = _response
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request)
        task.resume()
    }
    
    func getMock(id: String, request: URLRequest, with proxy: ProxyProtocol) {
        var newRequest = request
        newRequest.url = mockURL?.appendingPathComponent("mock/get")
        newRequest.httpMethod = "POST"
        var body: [String: Any] = [:]
        body["url"] = request.url?.absoluteString
        body["method"] = request.httpMethod
        newRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        newRequest.httpBody = try? JSONSerialization.data(withJSONObject: body)
        let task = session.dataTask(with: newRequest) { data, response, error in
            /// Log mock response
            Interceptor.logger.logResponse(id: id, request: request, response: response, data: data, isMock: true)
            if let response = response as? HTTPURLResponse {
                let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
                proxy.client?.urlProtocol(proxy, didReceive: response, cacheStoragePolicy: policy)
            }
            if let data = data {
                proxy.client?.urlProtocol(proxy, didLoad: data)
            }
            if let error = error {
                proxy.client?.urlProtocol(proxy, didFailWithError: error)
            } else {
                proxy.client?.urlProtocolDidFinishLoading(proxy)
            }
        }
        task.resume()
    }
}
