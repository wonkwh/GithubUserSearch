//
// Created by kwanghyun.won
// Copyright © 2020 wonkwh. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration

class GithubContainer {
    static let container: Container = {
        let container = Container()
        container.autoregister(Network.self, initializer: DefaultNetwork.init)
        container.autoregister(UserUseCase.self, initializer: DefaultUserUseCase.init)
        container.autoregister(GithubSearchViewReactor.self, initializer: GithubSearchViewReactor.init)
        container.autoregister(GithubUserCellReactor.self, argument: User.self, initializer: GithubUserCellReactor.init)
        return container
    }()
}
