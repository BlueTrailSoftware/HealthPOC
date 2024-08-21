//
//  LightFormulaViewModel.swift
//  RenaultHealth
//
//  Created by Leonardo Carrillo on 20/08/24.
//

import Foundation

struct TitleValueStringPair: Hashable {
    var title: String = ""
    var value: String = ""
}

struct LightFormulaDemonstrationResultItem: Hashable {
    var title: String = ""
    var values: [TitleValueStringPair] = []
}

class LightFormulaDemonstrationViewModel: ObservableObject {
    
    @Published var formulaResults: [LightFormulaDemonstrationResultItem] = [
        /*
        LightFormulaDemonstrationResultItem(
           title: "[8.0, 8.0, 8.0, 8.0, 8.0, 6.0, 7.0]",
           values: [
               TitleValueStringPair(title: "7", value: "80"),
               TitleValueStringPair(title: "9", value: "80"),
               TitleValueStringPair(title: "11", value: "80"),
               TitleValueStringPair(title: "13", value: "80"),
               TitleValueStringPair(title: "15", value: "80"),
               TitleValueStringPair(title: "17", value: "80"),
               TitleValueStringPair(title: "19", value: "80"),
               TitleValueStringPair(title: "21", value: "80")
           ]
        )
         */
    ]
    
    func runDemonstration() {
        
        let results = LightFormula().runDemonstration()
        
        self.formulaResults = results.map { k, v in
            LightFormulaDemonstrationResultItem(
                title: k,
                values: v.map{ value in
                    TitleValueStringPair(
                        title: "\(value.key)",
                        value: "\(value.value)"
                    )
                }
            )
        }
    }
}
