//
//  RepositoryListViewController.swift
//  Github
//
//  Created by 이송은 on 2022/11/25.
//

import UIKit
import RxSwift
import RxCocoa

class RepositoryListViewController : UITableViewController{
    private let organization = "Apple"
    private let repositries = BehaviorSubject<[Repository]>(value: [])
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title  = organization + "Repositories"
        
        //당겨서 새로고침
        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl!
        refreshControl.backgroundColor = .white
        refreshControl.tintColor = .darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        tableView.register(RepositoryListCell.self, forCellReuseIdentifier: "RepositoryListCell")
        tableView.rowHeight = 140
    }
    
    @objc func refresh(){
        DispatchQueue.global(qos: .background).async {[weak self] in
            guard let self = self else { return }
            self.fetchRepositories(of: self.organization)
        }
    }
    
    func fetchRepositories(of organization : String){
        Observable.from([organization]).map { organization -> URL in
            return URL(string: "https://api.github.com/orgs/\(organization)/repos")!
        }.map { url -> URLRequest in
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            return request
        }.flatMap{ request -> Observable<(response : HTTPURLResponse, data : Data)> in
            return URLSession.shared.rx.response(request: request)
        }.filter { responds , _ in 200..<300 ~= responds.statusCode
        }.map { _ ,data -> [[String: Any]] in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                  let result = json as? [[String : Any]] else{
                return []
            }
            return result
        }.filter{ result in
            return result.count > 0
        }.map { objects in
            return objects.compactMap { dic -> Repository? in
                guard let id = dic["id"] as? Int,
                      let name = dic["name"] as? String,
                      let description = dic["description"] as? String,
                      let stargazersCount = dic["stargazers_count"] as? Int,
                      let language = dic["language"] as? String else{
                    return nil
                }
                return Repository(id: id, name: name, description: description, starGazerCount: stargazersCount, language: language)
            }
        }.subscribe(onNext: {[weak self] newRepositories in
            self?.repositries.onNext(newRepositories)
            
            DispatchQueue.main.async{
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }
        }).disposed(by: disposeBag)
    }
}

//Datasource , Delegate
extension RepositoryListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        do{
            return try repositries.value().count
        }catch{
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryListCell", for : indexPath) as? RepositoryListCell else { return UITableViewCell()}
        var currentRepo : Repository?{
            do{
                return try repositries.value()[indexPath.row]
            }catch{
                return nil
            }
        }
        cell.repository = currentRepo
        return cell
    }
}
