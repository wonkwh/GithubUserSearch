//
// Created by kwanghyun.won
// Copyright © 2020 wonkwh. All rights reserved.
//

import Foundation

struct UserResponse: Codable {
    var hasNext: Bool?
    var items: [User]
}
