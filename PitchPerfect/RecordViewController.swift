//
//  ViewController.swift
//  PitchPerfect
//
//  Created by Peter Pohlmann on 28.08.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {

    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordLabel: UILabel!
    
    var audioURL = "Sender AudioURL"
    enum recordState{ case record, stop, pause}
    var recordStartText: String = "Tap Microphone to Record";
    var recordStopText: String = "Now Recording";
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        stopButton.alpha = 0.1
        stopButton.isEnabled = false
        recordLabel.text = recordStartText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        print("mic button pressed")
        recordingStatus(recordState.record)
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        recordingStatus(recordState.stop)
        performSegue(withIdentifier: "PlaybackSegue", sender: audioURL)
    }
    
    func recordingStatus(_ state: recordState ){

        switch state {
            case .record:
                print("record")
                stopButton.alpha = 1
                stopButton.isEnabled = true
                recordLabel.text = recordStopText
                animateRecording()
            case .stop:
                stopButton.alpha = 0.1
                stopButton.isEnabled = false
                recordLabel.text = recordStartText
                micButton.layer.removeAllAnimations()
                micButton.alpha = 1
            case .pause:
            print("pause")
        }
    }
    
    func animateRecording(){
        UIView.animate(withDuration: 0.4, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.micButton.alpha = 0.4
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlaybackSegue" {
            let playbackVC = segue.destination as! PitchViewController
            let audioURL = sender as! String
            playbackVC.audioURL = audioURL
        }
    }
    
}

