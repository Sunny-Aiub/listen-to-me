//
//  Colors.swift
//  ListenToMe
//
//  Created by Sunny Chowdhury on 8/13/21.
//

import Foundation
import UIKit
//MARK: - Colors
enum Color: String {
    case Red, red, orange, Orange, Yellow, yellow, green, blue, purple, black, gray
    
    var create: UIColor {
        switch self {
        case .Red, .red:
            return UIColor.red
        case .Orange, .orange:
            return UIColor.orange
        case .Yellow,.yellow:
            return UIColor.yellow
        case .green:
            return UIColor.green
        case .blue:
            return UIColor.blue
        case .purple:
            return UIColor.purple
        case .black:
            return UIColor.black
        case .gray:
            return UIColor.gray
        }
    }
}
