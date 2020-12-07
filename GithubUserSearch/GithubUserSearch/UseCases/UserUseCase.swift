//
// Created by kwanghyun.won
// Copyright © 2020 wonkwh. All rights reserved.
//

import Foundation
import RxAlamofire
import RxSwift

protocol UserUseCase {
    func getUsers(query: String, page: Int) -> Single<UserResponse>
    func getUser(username: String) -> Single<User>
}

class DefaultUserUseCase: UserUseCase {
    let network: Network
    let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)

    init(network: Network) {
        self.network = network
    }

    func getUsers(query: String, page: Int) -> Single<UserResponse> {
        let parameters: [String: Any] = ["q": query, "page": page, "per_page": 20]

        return network.get("https://api.github.com/search/users", parameters: parameters)
            .flatMap { response in
                guard let data = response.data else {
                    return .error(NetworkError.networkError)
                }
                do {
                    let decoder = JSONDecoder()
                    var value = try decoder.decode(UserResponse.self, from: data)
                    let links = (response.response?.allHeaderFields["Link"] as? String)?.components(separatedBy: ",") ?? []
                    value.hasNext = links.contains { $0.contains("next") }
                    return .just(value)
                } catch {
                    return .error(NetworkError.typeError)
                }
            }
    }

    func getUser(username: String) -> Single<User> {
        return network.get("https://api.github.com/users/\(username)", parameters: nil, responseType: User.self)
    }
}
