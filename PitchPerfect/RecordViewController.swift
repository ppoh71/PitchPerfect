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

    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordLabel: UILabel!
    
    var audioRecorder: AVAudioRecorder!
    var recordingSession: AVAudioSession!

    enum recordState{ case record, stop, pause, noPermit, failed}
    var recordStartText: String = "Tap Microphone to Record";
    var recordStopText: String = "Now Recording";
    var recordNoPermitText: String = "You have to allow using the Mic";
    var recordFailedText: String = "Recording failed, please try again";
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        stopButton.alpha = 0.1
        stopButton.isEnabled = false
        recordLabel.text = recordStartText
        self.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        print("mic button pressed")
        recordingStatus(recordState.record)
        recordAudio()
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        recordingStatus(recordState.stop)
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
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
            print("record 3")
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
                        print("failed 1")
                        self.recordingStatus(recordState.noPermit)
                    }
                }
            }
        } catch {
            print("failed 2")
            recordingStatus(recordState.failed)
        }
    }
    
    func recordingStatus(_ state: recordState ){
        switch state {
        case .record:
            print("record")
            stopButton.alpha = 1
            stopButton.isEnabled = true
            recordLabel.text = recordStopText
            micButton.isEnabled = false
            animateRecording()
        case .stop:
            stopButton.alpha = 0.1
            stopButton.isEnabled = false
            recordLabel.text = recordStartText
            micButton.layer.removeAllAnimations()
            micButton.alpha = 1
            micButton.isEnabled = true
        case .pause:
             print("pause")
        case .noPermit:
            stopButton.alpha = 0.1
            stopButton.isEnabled = false
            recordLabel.text = recordNoPermitText
            micButton.layer.removeAllAnimations()
            micButton.alpha = 0.2
        case .failed:
            stopButton.alpha = 0.1
            stopButton.isEnabled = false
            recordLabel.text = recordFailedText
            micButton.layer.removeAllAnimations()
            micButton.alpha = 0.2
        }
    }
    
    func animateRecording(){
        UIView.animate(withDuration: 0.4, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.micButton.alpha = 0.4
        })
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

