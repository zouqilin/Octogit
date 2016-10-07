//
//  EventTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift
import TTTAttributedLabel

class EventTableViewController: BaseTableViewController, TTTAttributedLabelDelegate {
    
    var viewModel: EventTableViewModel! {
        didSet {
            viewModel.dataSource.asObservable()
                .skip(1)
                .do(onNext: { _ in
                    self.tableView.refreshHeader?.endRefreshing()
                    self.tableView.refreshFooter?.endRefreshing()
                })
                .bindTo(tableView.rx.items(cellIdentifier: "EventCell", cellType: EventCell.self)) { row, element, cell in
                    cell.entity = element
                    cell.titleLabel.delegate = self
                    cell.contentLabel.delegate = self
                    cell.selectionStyle = .none
                    
                    cell.titleLabel.tag = row
                    cell.avatarView.tag = row
                    cell.avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.avatarTapped)))
                }
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = viewModel.title
        
        tableView.refreshHeader = RefreshHeader(target: viewModel, selector: #selector(viewModel.refresh))
        tableView.refreshFooter = RefreshFooter(target: viewModel, selector: #selector(viewModel.fetchNextPage))
        
        tableView.refreshHeader?.beginRefreshing()
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let row = label.tag
        let user = viewModel.dataSource.value[row].actor!
        
        guard url.absoluteString != "/\(user)" else {
            showUser(user)
            return
        }
        
        let vc = URLRouter.viewControllerForURL(url)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func avatarTapped(_ recognizer: UITapGestureRecognizer) {
        let row = recognizer.view?.tag
        let user = viewModel.dataSource.value[row!].actor!
        showUser(user)
    }
    
    func showUser(_ user: User) {
        let userVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserVC") as! UserViewController
        userVC.viewModel = UserViewModel(user)
        navigationController?.pushViewController(userVC, animated: true)
    }
    
}
