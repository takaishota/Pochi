//
//  PochiCommand.swift
//  Pochi
//
//  Created by 高井　翔太 on 2017/03/04.
//  Copyright © 2017年 comexample. All rights reserved.
//

import Foundation

enum PochiCommand : String {
    case goAhead = "すすめ"
    case goAheadKanji = "進め"
    case goBack = "もどれ"
    case goBackKanji = "戻れ"
    case rotate = "まわれ"
    case rotateKanji = "回れ"
    case stop = "とまれ"
    case stopKanji = "止まれ"
    
    func execute() {
        switch self {
        case .goAhead:
            robotConnection.goStraight()
        case .goBack:
            robotConnection.goBackForword()
        case .stop:
            robotConnection.stop()
        default:
            break
        }
    }
}
