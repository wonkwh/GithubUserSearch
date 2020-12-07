//
// Created by kwanghyun.won
// Copyright © 2020 wonkwh. All rights reserved.
//

import Foundation

struct User: Codable {
    var avatar_url: String
    var login: String
    var public_repos: Int? = 0
}
