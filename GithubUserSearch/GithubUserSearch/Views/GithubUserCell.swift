//
// Created by kwanghyun.won
// Copyright © 2020 wonkwh. All rights reserved.
//

import Nuke
import ReactorKit
import RxSwift
import UIKit

class GithubUserCell: UITableViewCell, View {
    @IBOutlet var ivProfile: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelRepo: UILabel!

    typealias Reactor = GithubUserCellReactor
    var disposeBag = DisposeBag()

    func bind(reactor: Reactor) {
        reactor.action.onNext(.fetchUser)
        reactor.state.map { $0.avatar_url }
            .subscribe(onNext: { [weak self] url in
                if let url = URL(string: url), let imageView = self?.ivProfile {
                    let options = ImageLoadingOptions(
                        placeholder: UIImage(named: "profile"),
                        transition: .fadeIn(duration: 0.33)
                    )

                    Nuke.loadImage(with: url, options: options, into: imageView)
                }
            }).disposed(by: disposeBag)

        reactor.state.map { $0.login }
            .bind(to: labelName.rx.text)
            .disposed(by: disposeBag)

        reactor.state.map { "Number of repose: \($0.public_repos ?? 0)" }
            .bind(to: labelRepo.rx.text)
            .disposed(by: disposeBag)
    }
}
