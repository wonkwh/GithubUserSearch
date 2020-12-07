//
// Created by kwanghyun.won
// Copyright © 2020 wonkwh. All rights reserved.
//

import ReactorKit
import RxSwift

class GithubSearchViewReactor: Reactor {
    let initialState: State
    let userUseCase: UserUseCase
    struct State {
        var query: String = ""
        var users: [User] = []
        var nextPage: Int?
        var isLoading: Bool = false
    }

    init(userUseCase: UserUseCase) {
        self.initialState = State()
        self.userUseCase = userUseCase
    }

    enum Action {
        case fetchUsers(String)
        case fetchNextPage
    }

    enum Mutation {
        case setQuery(String)
        case updateUsers([User], nextPage: Int?)
        case appendUsers([User], nextPage: Int?)
        case setIsLoading(Bool)
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .fetchUsers(query):
            guard !query.isEmpty else {
                return Observable.concat([
                    .just(.setIsLoading(false)),
                    .just(.setQuery(query)),
                    .just(.updateUsers([], nextPage: nil))
                ])
            }
            return Observable.concat([
                .just(.setQuery(query)),
                .just(.setIsLoading(true)),
                userUseCase.getUsers(query: query, page: 1)
                    .asObservable()
                    .map { response in
                        let nextPage = response.hasNext == true ? 2 : nil
                        return .updateUsers(response.items, nextPage: nextPage)
                    },
                .just(.setIsLoading(false))
            ])
        case .fetchNextPage:
            guard let nextPage = currentState.nextPage, !currentState.isLoading else {
                return .empty()
            }
            return Observable.concat([
                .just(.setIsLoading(true)),
                userUseCase.getUsers(query: currentState.query, page: nextPage)
                    .asObservable()
                    .map { response in
                        let nextPage = response.hasNext == true ? nextPage + 1 : nil
                        return .appendUsers(response.items, nextPage: nextPage)
                    },
                .just(.setIsLoading(false))
            ])
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .appendUsers(users, nextPage: nextPage):
            newState.users = newState.users + users
            newState.nextPage = nextPage
        case let .updateUsers(users, nextPage: nextPage):
            newState.users = users
            newState.nextPage = nextPage
        case let .setQuery(query):
            newState.query = query
        case let .setIsLoading(loading):
            newState.isLoading = loading
        }
        return newState
    }
}
