//
// Created by kwanghyun.won
// Copyright © 2020 wonkwh. All rights reserved.
//

//
//  Network.swift
//  GithubSearch
//
//  Created by 이동현 on 2019/10/16.
//  Copyright © 2019 이동현. All rights reserved.
//
import Alamofire
import Foundation
import RxSwift

enum NetworkError: Error {
    case invalidPath
    case networkError
    case typeError
}

protocol Network {
    func get<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Single<T>
    func get(_ path: String, parameters: [String: Any]?) -> Single<AFDataResponse<Any>>
}

final class DefaultNetwork: Network {
    private func request(_ path: String, method: HTTPMethod, parameters: Parameters?) -> Single<AFDataResponse<Any>> {
        return Single.create { single in
            guard let url = URL(string: path) else {
                single(.error(NetworkError.invalidPath))
                return Disposables.create()
            }

            let request = AF.request(url, method: method, parameters: parameters)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        single(.success(response))
                    case .failure:
                        single(.error(NetworkError.networkError))
                        return
                    }
                }
            return Disposables.create {
                request.cancel()
            }
        }
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func get<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Single<T> {
        return request(path, method: .get, parameters: parameters)
            .flatMap { response in
                guard let data = response.data else {
                    return .error(NetworkError.networkError)
                }
                do {
                    let decoder = JSONDecoder()
                    let value = try decoder.decode(T.self, from: data)
                    return .just(value)
                } catch {
                    return .error(NetworkError.typeError)
                }
            }
    }

    func get(_ path: String, parameters: [String: Any]?) -> Single<AFDataResponse<Any>> {
        return request(path, method: .get, parameters: parameters)
    }
}
