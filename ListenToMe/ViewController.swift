//
//  ViewController.swift
//  ListenToMe
//
//  Created by Sunny Chowdhury on 8/13/21.
//

import UIKit
import Speech
import AudioToolbox
import AVFoundation
import InstantSearchVoiceOverlay

class ViewController: UIViewController, VoiceOverlayDelegate {
    
    @IBOutlet weak var lblDtectedText: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var coloredView: UIView!
    
    var audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    var recordingStarted = false
    var soundID: SystemSoundID = 0
    var mainBundle: CFBundle = CFBundleGetMainBundle()
    
    
    let voiceOverlayController = VoiceOverlayController()
    var player: AVAudioPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("huhihihih")
        
//        voiceOverlayController.delegate = self
//
//        // If you want to start recording as soon as modal view pops up, change to true
//        voiceOverlayController.settings.autoStart = true
//        voiceOverlayController.settings.autoStop = true
//        voiceOverlayController.settings.showResultScreen = false
//        voiceOverlayController.settings.autoStopTimeout = 15
        
        
        // Do any additional setup after loading the view.
        // Play a sound without vibration
        //        let url = URL(fileURLWithPath: "/System/Library/Audio/UISounds/sms-received5.caf")
        //        do {
        //            let reps_sound_effect = try AVAudioPlayer(contentsOf: url)
        //            reps_sound_effect.play()
        //        } catch {
        //            print("Error!")
        //        }
        //        var systemSoundID : SystemSoundID = kSystemSoundID_Vibrate // doesnt matter; edit path instead
        //        let url = URL(fileURLWithPath: "/System/Library/Audio/UISounds/sms-received5.caf")
        //        AudioServicesCreateSystemSoundID(url as CFURL, &systemSoundID)
        //        AudioServicesPlaySystemSound(systemSoundID)
        //
        //recordAndRecognizeSpeech()
    }
    
    
    @IBAction func recordButtonClicked(_ sender: Any) {
        print("recordButtonClicked")
        // First way to listen to recording through callbacks
//        voiceOverlayController.start(on: self, textHandler: { (text, final, extraInfo) in
//            print("callback: getting \(String(describing: text))")
//            print("callback: is it final? \(String(describing: final))")
//
//            if final {
//                // here can process the result to post in a result screen
//                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (_) in
//                    let myString = text
//                    let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.red ]
//                    let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
//
//                    self.voiceOverlayController.settings.resultScreenText = myAttrString
//                    self.voiceOverlayController.settings.layout.resultScreen.titleProcessed = "BLA BLA"
//                })
//            }
//        }, errorHandler: { (error) in
//            print("callback: error \(String(describing: error))")
//        }, resultScreenHandler: { (text) in
//            print("Result Screen: \(text)")
//        }
//        )
//
//                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
//
//                var systemSoundID : SystemSoundID = kSystemSoundID_Vibrate// 1304//1013 // doesnt matter; edit path instead
//                let url = URL(fileURLWithPath: "/System/Library/Audio/UISounds/sms-received5.caf")
//                AudioServicesCreateSystemSoundID(url as CFURL, &systemSoundID)
//                AudioServicesPlaySystemSound(systemSoundID)
        
        
        //        audioEngine.stop()
        //        audioEngine.inputNode.removeTap(onBus: 0)
        //        //audioEngine.reset()
        //        recordingStarted = true
                self.recordAndRecognizeSpeech()
    }
    
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "1", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }
            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }

    
    func recording(text: String?, final: Bool?, error: Error?) {
        if let error = error {
            print("delegate: error \(error)")
        }
        
        if error == nil {
            lblDtectedText.text = text
        }
    }
    
    
    func recordAndRecognizeSpeech() {
        
        //        AudioServicesPlayAlertSound(SystemSoundID(1322))
        
        if audioEngine == nil{
            audioEngine = AVAudioEngine()
        }
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 99999, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.sendAlert(title: "Speech Recognizer Error", message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(title: "Speech Recognizer Error", message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(title: "Speech Recognizer Error", message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                
                var bestString = result.bestTranscription.formattedString
                
                
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = String(bestString[indexTo...])
                    print(lastString)
                }
                
                if bestString.lowercased().contains("listen to me") && self.recordingStarted == false{
                    self.sendAlert(title: "Recording Started", message: "Say words now!")
                    self.recordingStarted = true
                    self.playSound()
                    bestString = ""
                }else if bestString.lowercased().contains("stop me"){
                    self.sendAlert(title: "Recording Stopped", message: "Say words now!")
                    self.recordingStarted = false
                    self.audioEngine.stop()
                    self.audioEngine.inputNode.removeTap(onBus: 0)
                    
                    //self.audioEngine.reset()
                    
                }
                
                if self.recordingStarted == true {
                    self.lblDtectedText.text = bestString
                    self.checkForColorsSaid(resultString: lastString)
                    
                }
            } else if let error = error {
                self.sendAlert(title: "Speech Recognizer Error", message: "There has been a speech recognition error.")
                print(error)
            }
        })
    }
    
    //MARK: - UI / Set view color.
    func checkForColorsSaid(resultString: String) {
        guard let color = Color(rawValue: resultString) else { return }
        coloredView.backgroundColor = color.create
        self.lblDtectedText.text = resultString
    }
    
    //MARK: - Alert
    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension ViewController: SFSpeechRecognizerDelegate{
    
    //MARK: - Check Authorization Status
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.startStopButton.isEnabled = true
                case .denied:
                    self.startStopButton.isEnabled = false
                    self.lblDtectedText.text = "User denied access to speech recognition"
                case .restricted:
                    self.startStopButton.isEnabled = false
                    self.lblDtectedText.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.startStopButton.isEnabled = false
                    self.lblDtectedText.text = "Speech recognition not yet authorized"
                @unknown default:
                    return
                }
            }
        }
    }
    
    
}
