//
//  PosterAspect.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 17.09.25.
//

import UIKit

enum PosterAspect {
    case h4x3
    case h3x4
    case h3x2
    case h16x9
    case h9x16
    case h1x1
    case custom(CGFloat)
    
    var hOverW: CGFloat {
        switch self {
        case .h4x3: return 4.0 / 3.0
        case .h3x4: return 3.0 / 4.0
        case .h3x2: return 3.0 / 2.0
        case .h16x9: return 16.0 / 9.0
        case .h9x16: return 9.0 / 16.0
        case .h1x1:  return 1.0
        case .custom(let v): return v
        }
    }
}
