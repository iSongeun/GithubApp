//
//  Repository.swift
//  Github
//
//  Created by 이송은 on 2022/11/28.
//

import Foundation

struct Repository : Decodable {
    let id : Int
    let name : String
    let description : String
    let starGazerCount : Int
    let language : String
    
    enum CodingKeys : String , CodingKey{
        case id , name, description, language
        case starGazerCount = "stargazer_count"
    }
}
