//
//  UserProfile.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 7.08.25.
//

import Foundation

struct UserProfile: Codable {
    let uid: String
    let email: String
    let name: String
    let birthday: Date
    let avatarURL: URL?
    var favoriteGenres: [String]?
    var favorites: [String]? 
}
