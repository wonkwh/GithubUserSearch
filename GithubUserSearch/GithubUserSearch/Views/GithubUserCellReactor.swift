//
// Created by kwanghyun.won
// Copyright © 2020 wonkwh. All rights reserved.
//

import ReactorKit
import RxSwift

class GithubUserCellReactor: Reactor {
    typealias State = User
    var initialState: State
    let userUseCase: UserUseCase
    enum Action {
        case fetchUser
    }

    enum Mutation {
        case setUser(User)
    }

    init(user: User, userUseCase: UserUseCase) {
        self.initialState = user
        self.userUseCase = userUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchUser:
            return userUseCase.getUser(username: currentState.login)
                .asObservable()
                .map { .setUser($0) }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setUser(user):
            newState = user
        }
        return newState
    }
}
