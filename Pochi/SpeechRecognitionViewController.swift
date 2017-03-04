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
            actionArray.append("goStraight")
        case PochiCommand.stop.rawValue, PochiCommand.stopKanji.rawValue:
            PochiCommand.stop.execute()
            actionArray.append("stop")
        case PochiCommand.goBack.rawValue, PochiCommand.goBackKanji.rawValue:
            PochiCommand.bark.execute()
            actionArray.append("goBackForward")
        case PochiCommand.rotate.rawValue, PochiCommand.rotateKanji.rawValue:
            PochiCommand.rotate.execute()
            actionArray.append("turnAround")
        case PochiCommand.bark.rawValue, PochiCommand.barkKanji.rawValue:
            PochiCommand.bark.execute()
            actionArray.append("bark")
        default:
            break
        }
    }
    
    @IBAction func startRecording(sender: AnyObject) {
        try! voice.startRecording { [weak self] result in
            switch result {
            case .success(let string):
                self?.textView?.text? = string
                    self?.performCommand(string)
            case .failure(let error):
                    print(error)
                self?.textView?.text? = "\(error)"
            }
        }
    }
    
    @IBAction func stopRecording(sender: AnyObject) {
        voice.finish()
    }
}
