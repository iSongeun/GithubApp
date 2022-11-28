//
//  RepositoryListCell.swift
//  Github
//
//  Created by 이송은 on 2022/11/28.
//

import UIKit
import SnapKit

class RepositoryListCell : UITableViewCell {
    var repository : String?
    let nameLable = UILabel()
    let descriptionLabel = UILabel()
    let starImageView = UIImageView()
    let starLable = UILabel()
    let languageLabel = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [ nameLable,descriptionLabel,
          starImageView,starLable,languageLabel
        ].forEach{
            contentView.addSubview($0)
        }
        
        
    }
}
