//
// Created by kwanghyun.won
// Copyright © 2020 wonkwh. All rights reserved.
//

import Kingfisher
import ReactorKit
import RxCocoa
import RxSwift
import UIKit

class GithubSearchViewController: UIViewController, ReactorKit.View {
    var loadingIndicator: UIActivityIndicatorView!
    var tableView: UITableView!

    let searchController = UISearchController(searchResultsController: nil)

    var disposeBag = DisposeBag()

    typealias Reactor = GithubSearchViewReactor

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.hidesWhenStopped = true
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        tableView.rowHeight = 70

        reactor = GithubContainer.container.resolve(GithubSearchViewReactor.self)
    }

    func bind(reactor: Reactor) {
        reactor.state.map { $0.isLoading }
            .bind(to: loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        reactor.state.map { $0.users }
            .bind(to: tableView.rx.items(cellIdentifier: "GithubUserCell", cellType: GithubUserCell.self)) { _, user, cell in
                cell.reactor = GithubContainer.container.resolve(GithubUserCellReactor.self, argument: user)
            }.disposed(by: disposeBag)

        searchController.searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .map { Reactor.Action.fetchUsers($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        tableView.rx.contentOffset
            .filter { [weak self] offset in
                guard let self = self else { return false }
                guard self.tableView.frame.height > 0 else { return false }
                return offset.y + self.tableView.frame.height >= self.tableView.contentSize.height - 100
            }
            .map { _ in Reactor.Action.fetchNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
