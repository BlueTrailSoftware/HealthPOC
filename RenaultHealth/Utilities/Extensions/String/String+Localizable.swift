//
//  String+Localizable.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 17/07/24.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
