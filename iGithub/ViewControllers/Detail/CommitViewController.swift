//
//  CommitViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/14/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CommitViewController: BaseTableViewController {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    let indicator = LoadingIndicator()
    
    var viewModel: CommitViewModel!
    
    class func instantiateFromStoryboard() -> CommitViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CommitViewController") as! CommitViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = viewModel.shortSHA
        
        self.show(indicator: indicator)
        
        let commitDriver = viewModel.commit.asDriver().flatMap {
            Driver.from(optional: $0)
        }
        let commentsDriver = viewModel.dataSource.asDriver()
        
        commitDriver
            .drive(onNext: { [unowned self] _ in
                self.configureHeader()
                self.sizeHeaderToFit(tableView: self.tableView)
                
                self.indicator.removeFromSuperview()
            })
            .addDisposableTo(viewModel.disposeBag)
        
        Driver.combineLatest(commitDriver, commentsDriver) { commit, comments in
            	(commit, comments)
            }
            .drive(onNext: { [unowned self] _ in
                self.tableView.reloadData()
                
                self.sizeHeaderToFit(tableView: self.tableView)
            })
            .addDisposableTo(viewModel.disposeBag)
        
        viewModel.fetchFiles()
        viewModel.fetchData()
    }
    
    func configureHeader() {
        
        guard let commit = viewModel.commit.value else {
            return
        }
        
        titleLabel.text = commit.message!.components(separatedBy: "\n").first!
        
        avatarView.setAvatar(with: commit.author?.avatarURL)
        
        let author = commit.author?.login ?? commit.authorName
        
        let attrInfo = NSMutableAttributedString(string: "\(author!) committed \(commit.commitDate!.naturalString(withPreposition: true))")
        attrInfo.addAttributes([
            NSAttributedStringKey.foregroundColor: UIColor(netHex: 0x555555),
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
            ],
                               range: NSRange(location: 0, length: author!.characters.count))
        
        infoLabel.attributedText = attrInfo
    }
    
    // MARK: table view
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch viewModel.sectionTypes[section] {
        case .changes, .timeline:
            return 25
        default:
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch viewModel.sectionTypes[section] {
        case .changes:
            return "Changes"
        case .timeline:
            if viewModel.dataSource.value.count > 0 {
                return "Comments"
            }
            return nil
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.sectionTypes[indexPath.section] {
        case .message:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            cell.selectionStyle = .none
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.textColor = UIColor(netHex: 0x333333)
            cell.accessoryType = .none
            cell.textLabel?.text = viewModel.commit.value?.message
            
            return cell
            
        case .changes:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            cell.selectionStyle = .default
            cell.textLabel?.textColor = UIColor(netHex: 0x333333)
            
            let iconColor = UIColor(netHex: 0x4078C0)
            switch indexPath.row {
            case 0:
                cell.textLabel?.attributedText = Octicon.diffAdded.iconString(" \(viewModel.additions) added", iconSize: 18, iconColor: iconColor)
                cell.accessoryType = viewModel.additions > 0 ? .disclosureIndicator : .none
            case 1:
                cell.textLabel?.attributedText = Octicon.diffRemoved.iconString(" \(viewModel.removed) removed", iconSize: 18, iconColor: iconColor)
                cell.accessoryType = viewModel.removed > 0 ? .disclosureIndicator : .none
            case 2:
                cell.textLabel?.attributedText = Octicon.diffModified.iconString(" \(viewModel.modified) modified", iconSize: 18, iconColor: iconColor)
                cell.accessoryType = viewModel.modified > 0 ? .disclosureIndicator : .none
            default:
                cell.textLabel?.attributedText = Octicon.diff.iconString(" All files", iconSize: 18, iconColor: iconColor)
                cell.accessoryType = viewModel.commit.value?.files == nil ? .none : .disclosureIndicator
            }
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            cell.selectionStyle = .none
            cell.entity = viewModel.dataSource.value[indexPath.row]
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard viewModel.sectionTypes[indexPath.section] == .changes,
            var files = viewModel.commit.value?.files else {
                return
        }
        
        let fileTVC = CommitFileTableViewController()
        switch indexPath.row {
        case 0:
            files = files.filter {
                $0.status! == .added
            }
        case 1:
            files = files.filter {
                $0.status! == .removed
            }
        case 2:
            files = files.filter {
                return $0.status! == .modified || $0.status! == .renamed
            }
        default:
            break
        }
        
        guard files.count > 0 else { return }
        
        fileTVC.viewModel = CommitFileTableViewModel(files: files)
        navigationController?.pushViewController(fileTVC, animated: true)
    }
}
