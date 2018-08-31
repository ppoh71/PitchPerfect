//
//  PitchViewController.swift
//  PitchPerfect
//
//  Created by Peter Pohlmann on 28.08.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit
import AVFoundation

class PitchViewController: UIViewController, AVAudioPlayerDelegate {
    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var fxLabel: UILabel!
    @IBOutlet weak var micButton: GlobalButton!
    
    var audioURL:URL!
    var audioFile:AVAudioFile!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    var activeButton: UIButton!
    
    enum SoundFx: Int{ case slow = 0, fast, reverb, echo, chipmunk, vader}
    
    @IBAction func fxPressed(_ sender: UIButton){
        switch(SoundFx(rawValue: sender.tag)!){
        case .slow:
            print("play slow")
            audioPlayOrStop(rate: 0.5, pitch: nil, fx: .slow, button: sender)
        case .fast:
            audioPlayOrStop(rate: 1.5, pitch: nil, fx: .fast, button: sender)
        case .reverb:
            audioPlayOrStop(rate: nil, pitch: nil, fx: .reverb, button:sender)
        case .echo:
            audioPlayOrStop(rate: nil, pitch: nil, fx: .echo, button:sender)
        case .chipmunk:
            audioPlayOrStop(rate: nil, pitch: 1000, fx: .chipmunk, button:sender)
        case .vader:
            audioPlayOrStop(rate: nil, pitch: -1000, fx: .vader, button:sender)
        }
    }
    
    @IBAction func micButtonPressed(_ sender: Any) {
        stopAudio(fromButton: true)
        animateButtons(button: micButton)
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    func audioPlayOrStop(rate: Float?, pitch: Float?, fx: SoundFx, button: UIButton){
        if button.alpha == 1{
            playAudio(rate: rate, pitch: pitch, fx: fx, button: button)
            button.alpha = 0.6
            animateButtons(button: button)
            activeButton = button
            print("BUTTON alpha=1 - playadio")
        }else{
            stopAudio(fromButton: true);
            button.alpha = 1
            button.layer.removeAllAnimations()
            activeButton = UIButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    func playAudio(rate: Float?, pitch: Float?, fx: SoundFx, button: UIButton){
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        
        audioEngine.attach(audioPlayerNode)
        
        //get audiofile and set playback buffer
        audioFile = try! AVAudioFile(forReading: audioURL)
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
        try! audioFile.read(into: buffer!, frameCount: AVAudioFrameCount(audioFile.length) )
        
        //attach and connect audioNodes by fx type
        switch fx {
        case .slow, .fast, .chipmunk, .vader:
            let pitchNode = AVAudioUnitTimePitch()
            if let pitch = pitch{
                pitchNode.pitch = pitch
            }
            if let rate = rate{
                pitchNode.rate = rate
            }
            connectAudioNodes(fxNode: pitchNode, audioPlayerNode: audioPlayerNode, buffer: buffer)
            
        case .reverb:
            let reverbNode = AVAudioUnitReverb()
            reverbNode.loadFactoryPreset(AVAudioUnitReverbPreset.cathedral)
            reverbNode.wetDryMix = 50
            connectAudioNodes(fxNode: reverbNode, audioPlayerNode: audioPlayerNode, buffer: buffer)
            
        case .echo:
            let echoNode = AVAudioUnitDistortion()
            echoNode.loadFactoryPreset(.multiEcho1)
            connectAudioNodes(fxNode: echoNode, audioPlayerNode: audioPlayerNode, buffer: buffer)
        }
        //audioPlayerNode.stop()
        audioPlayerNode.scheduleBuffer(buffer!, at: nil, options:[]){
            /* for udacity review: this is a completion handler gets called when sounds finished playing. as expected
             So i use a direct method call and skip skip the time calculation via length, sampleTime, Bitrate...
             scheduleBuffer(file... seems to call it right away
             */
            DispatchQueue.main.async {
                //self.stopAudio(fromButton: false) // no need to call stop, scheduleBuffer resets buffer and plays the new sound
                self.toggleButton(button: button)
                print("stopped from buffer/ no stop fx gets called")
            }
        }
        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("nope start engine")
            return
        }
        audioPlayerNode.volume = 1
        audioPlayerNode.play()
    }
    
    @objc func stopAudio(fromButton: Bool){
        //stop only from stopButton,
        if fromButton == true {
            if let audioEngine = audioEngine{
                if let audioPlayerNode = audioPlayerNode{
                     print("stop audio from BUTTIN")
                    audioPlayerNode.reset()
                    audioEngine.stop()
                    audioEngine.reset()
                }
            }
        }
    }
    
    func animateButtons(button: UIButton){
        button.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.4, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            button.alpha = 0.1
            button.transform = CGAffineTransform(scaleX: 0.875, y: 0.86)
        })
    }
    
    func toggleButton(button: UIButton){
        button.alpha = 1
        button.layer.removeAllAnimations()
        button.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    func connectAudioNodes(fxNode: AVAudioNode,audioPlayerNode: AVAudioPlayerNode,  buffer: AVAudioPCMBuffer? ) {
        audioEngine.attach(fxNode)
        audioEngine.connect(audioPlayerNode, to: fxNode, format: audioFile.processingFormat)
        audioEngine.connect(fxNode, to: audioEngine.mainMixerNode, format: buffer?.format)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
