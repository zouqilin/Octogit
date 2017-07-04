//
//  RepositoryViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/23/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import RxMoya
import RxSwift
import ObjectMapper

class RepositoryViewModel {
    
    enum Section {
        case info
        case code
        case misc
        case loading
    }
    
    enum InfoType {
        case author
        case description
        case homepage
        case readme
    }
    
    var fullName: String
    let disposeBag = DisposeBag()
    var repository: Variable<Repository>
    var isStarring = Variable<Bool?>(nil)
    var isRepositoryLoaded: Bool {
        return self.repository.value.defaultBranch != nil
    }
    
    var branches = [Branch]()
    var pageForBranches = 1
    var isBranchesLoaded = Variable(false)
    var branch: String!
    
    var sections = [Section]()
    var infoTypes = [InfoType]()
    
    lazy var information: String = {
        var information: String = "Check out the repository \(self.fullName)."
        if let description = self.repository.value.repoDescription,
            description.characters.count > 0 {
            information.append(" \(description)")
        }
        
        return information
    }()
    lazy var htmlURL: URL = {
        return URL(string: "https://github.com/\(self.fullName)")!
    }()
    
    init(repo: Repository) {
        self.fullName = repo.fullName!
        self.repository = Variable(repo)
        
        branch = repo.defaultBranch!
    }
    
    init(repo: String) {
        self.fullName = repo
        
        let name = fullName.components(separatedBy: "/").last!
        self.repository = Variable(Mapper<Repository>().map(JSON: ["name": "\(name)"])!)
    }
    
    func fetchRepository() {
        GitHubProvider
            .request(.getARepository(repo: fullName))
            .mapJSON()
            .subscribe(onNext: { [unowned self] in
                // first check if there is an error and if the repo exists
//                if $0.statusCode == 404 {
//                    
//                }
                
                if let repo = Mapper<Repository>().map(JSONObject: $0) {
                    self.branch = repo.defaultBranch!
                    self.rearrangeBranches(withDefaultBranch: repo.defaultBranch!)
                    self.repository.value = repo
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    // MARK: Branches
    
    func fetchBranches() {
        let token = GitHubAPI.branches(repo: fullName, page: pageForBranches)
        
        GitHubProvider
            .request(token)
            .subscribe(onNext: { [unowned self] in
                
                if let json = try? $0.mapJSON(), let newBranches = Mapper<Branch>().mapArray(JSONObject: json) {
                    self.branches.append(contentsOf: newBranches)
                }
                
                if let headers = ($0.response as? HTTPURLResponse)?.allHeaderFields {
                    if let _ = (headers["Link"] as? String)?.range(of: "rel=\"next\"") {
                        self.pageForBranches += 1
                        self.fetchBranches()
                    } else {
                        self.isBranchesLoaded.value = true
                    }
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func rearrangeBranches(withDefaultBranch defaultBranch: String) {
        for (index, branch) in self.branches.enumerated() {
            if branch.name! == defaultBranch {
                let _ = self.branches.remove(at: index)
                branches.insert(branch, at: 0)
                
                break
            }
        }
    }
    
    // MARK: Star
    
    func checkIsStarring() {
        GitHubProvider
            .request(.isStarring(repo: fullName))
            .subscribe(onNext: { [unowned self] response in
                if response.statusCode == 204 {
                    self.isStarring.value = true
                } else if response.statusCode == 404 {
                    self.isStarring.value = false
                } else {
                    // error happened
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    @objc func toggleStarring() {
        let token: GitHubAPI = isStarring.value! ? .unstar(repo: fullName) : .star(repo: fullName)
        
        GitHubProvider
            .request(token)
            .subscribe(onNext: { [unowned self] response in
                if response.statusCode == 204 {
                    self.isStarring.value = !self.isStarring.value!
                } else {
                    let json = try! response.mapJSON()
                    print(json)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    var numberOfSections: Int {
        setSections()
        return sections.count
    }
    
    func setSections() {
        sections = []
        
        guard self.isRepositoryLoaded else {
            sections.append(.loading)
            return
        }
        
        sections.append(.info)
        if let _ = repository.value.defaultBranch {
            sections.append(.code)
        }
        sections.append(.misc)
    }
    
    func setInfoTypes(repo: Repository) {
        
        if !isRepositoryLoaded || infoTypes.count > 0 {
            return
        }
        
        infoTypes.append(.author)
        
        if let desc = repo.repoDescription?.trimmingCharacters(in: .whitespacesAndNewlines),
            desc.characters.count > 0 {
            infoTypes.append(.description)
        }
        
        if let homepage = repo.homepage?.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines),
            homepage.characters.count > 0 {
            infoTypes.append(.homepage)
        }
        
        infoTypes.append(.readme)
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        switch sections[section] {
        case .info:
            setInfoTypes(repo: repository.value)
            return infoTypes.count
        case .code:
            return 2
        case .misc:
            return 5
        case .loading:
            return 1
        }
    }
    
    // MARK: generate child viewmodel
    
    var readmeViewModel: FileViewModel {
        return FileViewModel(repository: fullName, ref: branch)
    }
    
    var fileTableViewModel: FileTableViewModel {
        return FileTableViewModel(repository: fullName, ref: branch)
    }
    
    var commitTableViewModel: CommitTableViewModel {
        return CommitTableViewModel(repo: fullName, branch: branch)
    }

    var ownerViewModel: UserViewModel {
        switch repository.value.owner!.type! {
        case .user:
            return UserViewModel(repository.value.owner!)
        case .organization:
            return OrganizationViewModel(repository.value.owner!)
        }
    }
}
