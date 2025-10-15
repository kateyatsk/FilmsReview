//
//  MetaChip.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 10.09.25.
//
import UIKit

enum MetaChip {
    case year(String)
    case season(String)
    case genre(String)
    
    var text: String {
        switch self {
        case .year(let t), .season(let t), .genre(let t): return t
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .year: return UIImage(systemName: "calendar")
        case .season: return UIImage(systemName: "timer")
        case .genre: return UIImage(systemName: "square.grid.2x2")
        }
    }
}
