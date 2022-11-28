//
//  RepositoryListCell.swift
//  Github
//
//  Created by 이송은 on 2022/11/28.
//

import UIKit
import SnapKit

class RepositoryListCell : UITableViewCell {
    
    var repository : Repository?
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    let starImageView = UIImageView()
    let starLable = UILabel()
    let languageLabel = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [ nameLabel,descriptionLabel,
          starImageView,starLable,languageLabel
        ].forEach{
            contentView.addSubview($0)
        }
        
        guard let repository = repository else { return }
        nameLabel.text = repository.name
        nameLabel.font = .systemFont(ofSize: 15, weight: .bold)
        
        descriptionLabel.text = repository.description
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.numberOfLines = 2
        
        starImageView.image = UIImage(systemName: "star")
        
        starLable.text = "\(repository.starGazerCount)"
        starLable.font = .systemFont(ofSize: 16)
        starLable.textColor = .gray
        
        languageLabel.text = repository.language
        languageLabel.font = .systemFont(ofSize: 16)
        languageLabel.textColor = .gray
        
        nameLabel.snp.makeConstraints{
            $0.top.leading.trailing.equalToSuperview().inset(18)
        }
        
        descriptionLabel.snp.makeConstraints{
            $0.top.equalTo(nameLabel.snp.bottom).offset(3)
            $0.leading.trailing.equalTo(nameLabel)
        }
        starImageView.snp.makeConstraints{
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            $0.leading.equalTo(descriptionLabel)
            $0.width.height.equalTo(20)
            $0.bottom.equalToSuperview().inset(18)
        }
        starLable.snp.makeConstraints{
            $0.centerY.equalTo(starImageView)
            $0.leading.equalTo(starImageView.snp.trailing).offset(5)
        }
        languageLabel.snp.makeConstraints{
            $0.centerY.equalTo(starLable)
            $0.leading.equalTo(starLable.snp.trailing).offset(12)
        }
        
        
    }
}
