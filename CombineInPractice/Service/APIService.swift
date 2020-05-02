//
//  APIService.swift
//  CombineInPractice
//
//  Created by crea on 2020/05/02.
//  Copyright © 2020 crea. All rights reserved.
//

import Foundation
import Combine

enum APIServiceError: Error {
    case invalidURL
    case responseError
    case parseError(Error)
}

protocol APIRequestType {
    associatedtype Response: Decodable
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
}

struct UsernameValidationRequest: APIRequestType {
    
    let username: String
    
    struct Result: Decodable {
        let available: Bool
    }
    
    typealias Response = Result

    var path: String { return "/user/available" }
    var queryItems: [URLQueryItem]? {
        return nil
        // 実際はこのような形になるはず
        // return [
        //     URLQueryItem(name: "username", value: username)
        // ]
    }

}


protocol APIServiceType {
    func request<Request>(with request: Request) -> AnyPublisher<Request.Response, APIServiceError> where Request: APIRequestType
}

final class APIService: APIServiceType {

    private let baseURLString: String
    init(baseURLString: String = "https://usernameavailable.free.beeceptor.com") {
        self.baseURLString = baseURLString
    }

    func request<Request: APIRequestType>(with request: Request) -> AnyPublisher<Request.Response, APIServiceError> {
        guard let pathURL = URL(string: request.path, relativeTo: URL(string: baseURLString)) else {
            return Fail(error: APIServiceError.invalidURL)
                .eraseToAnyPublisher()
        }

        var urlComponents = URLComponents(url: pathURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = request.queryItems
        
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let decorder = JSONDecoder()
        decorder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { data, urlResponse in data }
            .mapError { _ in APIServiceError.responseError }
            .decode(type: Request.Response.self, decoder: decorder)
            .mapError(APIServiceError.parseError)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

