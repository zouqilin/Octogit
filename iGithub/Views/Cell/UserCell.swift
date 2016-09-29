//
//  UserCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/29/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    let avatarView = UIImageView()
    let nameLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        contentView.addSubviews([avatarView, nameLabel])
        
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 5),
            avatarView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 32),
            avatarView.heightAnchor.constraint(equalToConstant: 32),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 6),
            nameLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8),
            nameLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 6),
            nameLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -6)
        ])
    }
    
    var entity: User! {
        didSet {
            avatarView.setAvatar(with: entity.avatarURL)
            nameLabel.text = entity.login
        }
    }

}