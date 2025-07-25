//
//  ValidationRegex.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 22.07.25.
//

import Foundation

enum ValidationRegex: String {
    case email = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    
    case onlyLatin = "^[A-Za-z0-9!@#$%^&*]+$"
    case hasUppercase = ".*[A-Z]+.*"
    case hasLowercase = ".*[a-z]+.*"
    case hasDigit = ".*\\d+.*"
    case hasSpecialChar = ".*[!@#$%^&*]+.*"
    case noWhitespaces = "^[^\\s]*$"
    case minLength = "^.{6,}$"
}

