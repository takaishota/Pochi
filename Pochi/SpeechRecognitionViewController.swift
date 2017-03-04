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
    
    private let speechRecognizer = SFSpeechRecognizer(locale: NSLocale(localeIdentifier: "ja-JP"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    @IBOutlet var textView : UITextView!
    
    @IBOutlet var recordButton : UIButton!
    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the record buttons until authorization has been granted.
        recordButton.enabled = false
    }
    
    override public func viewDidAppear(animated: Bool) {
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            
            dispatch_async(dispatch_get_main_queue(), {
                switch authStatus {
                case .Authorized:
                    self.recordButton.enabled = true
                    
                case .Denied:
                    self.recordButton.enabled = false
                    self.recordButton.setTitle("User denied access to speech recognition", forState: .Disabled)
                    
                case .Restricted:
                    self.recordButton.enabled = false
                    self.recordButton.setTitle("Speech recognition restricted on this device", forState: .Disabled)
                    
                case .NotDetermined:
                    self.recordButton.enabled = false
                    self.recordButton.setTitle("Speech recognition not yet authorized", forState: .Disabled)
                }
            })
        }
    }
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, withOptions: .NotifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTaskWithRequest(recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                self.textView.text = result.bestTranscription.formattedString
                let string = result.bestTranscription.formattedString
                
                print(result)
                if string == PochiCommand.goAhead.rawValue || string == PochiCommand.goAheadKanji.rawValue {
                    PochiCommand.goAhead.execute()
                } else if string == PochiCommand.stop.rawValue || string == PochiCommand.stopKanji.rawValue {
                    PochiCommand.stop.execute()
                }
                
                isFinal = result.final
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTapOnBus(0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.enabled = true
                self.recordButton.setTitle("Start Recording", forState: [])
            }
        }
        
        let recordingFormat = inputNode.outputFormatForBus(0)
        inputNode.installTapOnBus(0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.appendAudioPCMBuffer(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        textView.text = "(Go ahead, I'm listening)"
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.enabled = true
            recordButton.setTitle("Start Recording", forState: [])
        } else {
            recordButton.enabled = false
            recordButton.setTitle("Recognition not available", forState: .Disabled)
        }
    }
    
    // MARK: Interface Builder actions
    
    @IBAction func recordButtonTapped() {
        if audioEngine.running {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.enabled = false
            recordButton.setTitle("Stopping", forState: .Disabled)
        } else {
            try! startRecording()
            recordButton.setTitle("Stop recording", forState: [])
        }
    }
}
