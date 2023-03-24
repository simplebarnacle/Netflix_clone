//
//  Extensions.swift
//  NetflixClone
//
//  Created by jayden on 2023/03/24.
//

import Foundation

extension String {
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
