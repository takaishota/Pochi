//
//  SpeechRecognitionViewController.swift
//  Pochi
//
//  Created by 高井　翔太 on 2017/03/04.
//  Copyright © 2017年 comexample. All rights reserved.
//

import UIKit
import Speech

public class SpeechRecognitionViewController: UIViewController, SFSpeechRecognizerDelegate {
    // MARK: Properties
    
    let voice = VoiceRecognizer()
    @IBOutlet weak var textView: UITextView?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        voice.requestAuthorization() { result in
            print(result)
        }
    }
    
    func performCommand(string: String) {
        switch string {
        case PochiCommand.goAhead.rawValue, PochiCommand.goAheadKanji.rawValue:
            PochiCommand.goAhead.execute()
        case PochiCommand.stop.rawValue, PochiCommand.stopKanji.rawValue:
            PochiCommand.stop.execute()
        case PochiCommand.goBack.rawValue, PochiCommand.goBackKanji.rawValue:
            PochiCommand.bark.execute()
        case PochiCommand.rotate.rawValue, PochiCommand.rotateKanji.rawValue:
            PochiCommand.rotate.execute()
        case PochiCommand.bark.rawValue, PochiCommand.barkKanji.rawValue:
            PochiCommand.bark.execute()
        default:
            break
        }
        
        if string == PochiCommand.goAhead.rawValue || string == PochiCommand.goAheadKanji.rawValue {
            PochiCommand.goAhead.execute()
        } else if string == PochiCommand.stop.rawValue || string == PochiCommand.stopKanji.rawValue {
            PochiCommand.stop.execute()
        }
    }
    
    @IBAction func startRecording(sender: AnyObject) {
        try! voice.startRecording { [weak self] result in
            switch result {
            case .success(let string):
                    self?.performCommand(string)
            case .failure(let error):
                    print(error)
            }
        }
    }
    
    @IBAction func stopRecording(sender: AnyObject) {
        voice.finish()
    }
}
