//
//  Voice.swift
//  Pochi
//
//  Created by nori on 2017/03/04.
//  Copyright © 2017年 comexample. All rights reserved.
//

import Foundation
import Speech

enum Result<T, E> {
    case success(T)
    case failure(E)
}

private func dispatchAsyncOnMain(block: (Void) -> (Void)) {
    dispatch_async(dispatch_get_main_queue(), block)
}

class VoiceRecognizer {
    
    enum Error: ErrorType {
        case NotAuthorized
        case NoData
    }
    
    let recognizer = SFSpeechRecognizer(locale: NSLocale(localeIdentifier: "ja-JP"))
    let engine = AVAudioEngine()
    var task: SFSpeechRecognitionTask? = nil
    
    typealias AuthorizationResult = Result<Void, VoiceRecognizer.Error>
    typealias RecognizionResult = Result<String, VoiceRecognizer.Error>
    typealias CompletionHandler = (VoiceRecognizer.AuthorizationResult) -> (Void)
    
    func requestAuthorization(handler: VoiceRecognizer.CompletionHandler?) {
        SFSpeechRecognizer.requestAuthorization { (status) in
            let result: Result<Void, VoiceRecognizer.Error>
            switch status {
            case .Authorized:
                result = .success()
            default:
                result = .failure(VoiceRecognizer.Error.NotAuthorized)
            }
            handler?(result)
        }
    }
    
    func startRecording(completion: (RecognizionResult) -> (Void)) throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(AVAudioSessionCategoryRecord)
        try session.setMode(AVAudioSessionModeMeasurement)
        try session.setActive(true)
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        guard let inputNode = engine.inputNode else { fatalError() }
        
        request.shouldReportPartialResults = false
        
        task = recognizer?.recognitionTaskWithRequest(request) { result, error in
            
            guard let string = result?.transcriptions.first?.formattedString else {
                dispatchAsyncOnMain {
                    completion(.failure(.NoData))
                }
                return
            }
            
            dispatchAsyncOnMain {
                completion(.success(string))
            }
        }
        
        let recordingFormat = inputNode.outputFormatForBus(0)
        inputNode.installTapOnBus(0, bufferSize: 1024, format: recordingFormat) { (buffer, time) in
            request.appendAudioPCMBuffer(buffer)
        }
        
        engine.prepare()
        try engine.start()
    }
    
    func finish() {
        self.engine.inputNode?.removeTapOnBus(0)
        self.engine.stop()
        task?.finish()
        task = nil
    }
}
