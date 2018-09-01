//
//  ViewController.swift
//  PitchPerfect
//
//  Created by Peter Pohlmann on 28.08.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var micButton: GlobalButton!
    @IBOutlet weak var recordLabel: UILabel!
    
    var audioRecorder: AVAudioRecorder!
    var recordingSession: AVAudioSession!

    enum RecordState{ case record, stop, pause, noPermit, failed}
    enum AimationComplete: Int{ case record = 0, fadeIn, none}
    var recordStartText: String = "press mic to record";
    var recordStopText: String = " .... recording ....";
    var recordNoPermitText: String = "You have to allow using the Mic";
    var recordFailedText: String = "Recording failed, please try again";
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        setupUI()
    }
    
    @IBAction func recordAudio(_ sender: UIButton) {
        print("mic button pressed")
       sender.isSelected = !sender.isSelected
        
        if sender.isSelected{
            recordingStatus(RecordState.record)
            recordAudio()
        }else{
            recordingStatus(RecordState.stop)
            audioRecorder.stop()
            let audioSession = AVAudioSession.sharedInstance()
            try! audioSession.setActive(false)
        }
    }
    
    func recordAudio(){
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedAudio.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        let settings = [
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                        AVEncoderBitRateKey: 256000,
                        AVNumberOfChannelsKey: 2,
                        AVSampleRateKey: 44100.0] as [String : Any]
       
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
            try recordingSession.setActive(true)
            try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])

            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                       print("allowed to record")
                        self.audioRecorder.isMeteringEnabled = true
                        self.audioRecorder.delegate = self as AVAudioRecorderDelegate
                        self.audioRecorder.prepareToRecord()
                        self.audioRecorder.record()
                        
                    } else {
                        // failed to record!
                        self.recordingStatus(RecordState.noPermit)
                    }
                }
            }
        } catch {
            recordingStatus(RecordState.failed)
        }
    }
    
    func recordingStatus(_ state: RecordState ){
        switch state {
        case .record:
            recordLabel.text = recordStopText
            micButton.changeButtonImage(imageName: "mic-stop", useCompleteHandler: true)
        case .stop:
            micButton.fadeButton(fadeIn: false, useCompleteHandler: false)
            //nothing to do much
            // break
        case .pause:
             print("pause")
        case .noPermit:
            recordLabel.text = recordNoPermitText
            micButton.layer.removeAllAnimations()
            micButton.alpha = 0.2
        case .failed:
            recordLabel.text = recordFailedText
            micButton.layer.removeAllAnimations()
            micButton.alpha = 0.2
        }
    }
    
    func fadeOut(){
        
        /*
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseIn, .curveEaseInOut, .allowUserInteraction], animations: {
            self.micButton.alpha = 0
            self.micButton.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }, completion: { (complete: Bool) in
            if let image = UIImage(named: "mic-stop") {
                self.micButton.setImage(image, for: .normal)
            }
            self.fadeIn()
        })
        */
    }
    
    func fadeIn(){
         /*
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn, .curveEaseInOut, .allowUserInteraction], animations: {
            self.micButton.alpha = 1
            self.micButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: { (complete: Bool) in
            self.animateRecording()
        })
         */
    }
    
    func animateRecording(){
        /*
        UIView.animate(withDuration: 0.4, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            self.micButton.alpha = 0.3
            self.micButton.transform = CGAffineTransform(scaleX: 0.775, y: 0.775)
        }, completion: { (complete: Bool) in
            print("complete")
        })
        */
    }
    
    func setupUI(){
        recordLabel.text = recordStartText
        micButton.alpha = 0
        micButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        micButton.changeButtonImage(imageName: "microphone2x-iphone", useCompleteHandler: false)
                
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("finish recording")
        if flag {
            performSegue(withIdentifier: "PlaybackSegue", sender: audioRecorder.url)
        }else{
            recordingStatus(.failed)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlaybackSegue" {
            let playbackVC = segue.destination as! PitchViewController
            let audioURL = sender as! URL
            playbackVC.audioURL = audioURL
        }
    }
}

