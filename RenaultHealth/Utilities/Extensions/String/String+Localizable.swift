//
//  String+Localizable.swift
//  RenaultHealth
//
//  Created by Blue Trail Software on 17/07/24.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
