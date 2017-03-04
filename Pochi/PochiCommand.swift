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
            robotConnection.brick?.directCommand.turnMotorAtSpeed(onPorts: OutputPort.All, withSpeed: 50)
        case .goBack:
            robotConnection.brick?.directCommand.turnMotorAtSpeed(onPorts: OutputPort.All, withSpeed: -50)
        case .stop:
            robotConnection.brick?.directCommand.turnMotorAtSpeed(onPorts: OutputPort.All, withSpeed: 0)
        default:
            break
        }
    }
}
