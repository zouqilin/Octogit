//
//  GithubAPI.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/20/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import RxMoya

enum GithubAPI {
    case GetARepository(fullName: String)
    case GetContents(repository: String, path: String)
    case OAuthUser(accessToken: String)
    case Members(organization: String)
    case Organization(org: String)
    case Organizations(username: String)
    case ReceivedEvents(username: String)
    case User(username: String)
    case UserEvents(username: String)
}

extension GithubAPI: TargetType {
    var baseURL: NSURL { return NSURL(string: "https://api.github.com")! }
    var path: String {
        switch self {
        case .GetARepository(let fullName):
            return "/repos/\(fullName)"
        case .GetContents(let repository, let path):
            return "/repos/\(repository)/contents/\(path)"
        case .Members(let organization):
            return "/orgs/\(organization)/members"
        case .OAuthUser(_):
            return "/user"
        case .Organization(let org):
            return "/orgs/\(org)"
        case .Organizations(let username):
            return "/users/\(username)/orgs"
        case .ReceivedEvents(let username):
            return "/users/\(username)/received_events"
        case .UserEvents(let username):
            return "/users/\(username)/events"
        case .User(let username):
            return "/users/\(username)"
        }
    }
    var method: RxMoya.Method {
        switch self {
        default:
            return .GET
        }
    }
    var parameters: [String: AnyObject]? {
        switch self {
        case .OAuthUser(let accessToken):
            return ["access_token": accessToken]
        default:
            return nil
        }
    }
    var sampleData: NSData {
        switch self {
        default:
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
        }
    }
    var multipartBody: [RxMoya.MultipartFormData]? {
        switch self {
        default:
            return nil
        }
    }
}


private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
    var UTF8EncodedData: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}