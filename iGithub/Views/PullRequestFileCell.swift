//
//  PullRequestFileCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/12/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

class PullRequestFileCell: UITableViewCell {
    
    private let iconLabel = UILabel()
    private let nameLabel = UILabel()
    private let infoLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.configureSubviews()
        self.layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        iconLabel.font = UIFont.OcticonOfSize(20)
        iconLabel.textColor = UIColor(netHex: 0x767676)
        
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.font = UIFont.systemFont(ofSize: 17)
        nameLabel.textColor = UIColor(netHex: 0x333333)
        
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.textColor = UIColor(netHex: 0x888888)
        
        contentView.addSubviews([iconLabel, nameLabel, infoLabel])
    }
    
    func layout() {
        let margins = contentView.layoutMarginsGuide
        
        iconLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        iconLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            iconLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 3),
            
            nameLabel.topAnchor.constraint(equalTo: iconLabel.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            
            infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            infoLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            infoLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
    }
    
    var entity: PullRequestFile! {
        didSet {
            nameLabel.text = entity.name
            
            var additions = "\(entity.additions!) addition"
            if entity.additions! > 1 {
                additions.append("s")
            }
            
            var deletions = "\(entity.deletions!) deletion"
            if entity.deletions! > 1 {
                deletions.append("s")
            }
            
            infoLabel.text = "\(additions), \(deletions)"
            
            switch entity.status! {
            case .added:
                iconLabel.text = Octicon.diffAdded.rawValue
            case .removed:
                iconLabel.text = Octicon.diffRemoved.rawValue
            case .modified:
                iconLabel.text = Octicon.diffModified.rawValue
            }
        }
    }
}