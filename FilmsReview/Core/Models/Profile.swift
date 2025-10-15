//
//  Profile.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 13.10.25.
//

import UIKit

enum Profile {
    enum Load {
        struct Response {
            let name: String
            let email: String
            let genresText: String
            let birthday: Date?
            let avatar: UIImage?
        }
        struct ViewModel {
            let name: String
            let nameValue: String
            let emailValue: String
            let genresValue: String
            let birthdayValue: String
            let avatar: UIImage?
        }
    }
}
