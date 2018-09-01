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
    @IBOutlet weak var fastButton: GlobalButton!
    @IBOutlet weak var slowButton: GlobalButton!
    @IBOutlet weak var reverbButton: GlobalButton!
    @IBOutlet weak var echoButton: GlobalButton!
    @IBOutlet weak var chipmunkButton: GlobalButton!
    @IBOutlet weak var vaderButton: GlobalButton!
    @IBOutlet weak var micButton: GlobalButton!
    @IBOutlet weak var fxLabel: UILabel!

    var audioURL:URL!
    var audioFile:AVAudioFile!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    var activeButton: UIButton!
    
    enum SoundFx: Int{ case slow = 0, fast, reverb, echo, chipmunk, vader}
    var fxButtons = [GlobalButton]()
    
    @IBAction func fxPressed(_ sender: GlobalButton){
        switch(SoundFx(rawValue: sender.tag)!){
        case .slow:
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
    
    @IBAction func micButtonPressed(_ sender: GlobalButton) {
        stopAudio(fromButton: true)
        sender.fadeButton(fadeIn: false, delay: 0, useCompleteHandler: false)
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    func audioPlayOrStop(rate: Float?, pitch: Float?, fx: SoundFx, button: GlobalButton){
        if button.alpha == 1{
            playAudio(rate: rate, pitch: pitch, fx: fx, button: button)
            button.alpha = 0.6
            button.animateButton()
            activeButton = button
        }else{
            stopAudio(fromButton: true);
            button.alpha = 1
            button.layer.removeAllAnimations()
            activeButton = GlobalButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fxButtons = [slowButton, fastButton, reverbButton, echoButton, chipmunkButton, vaderButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated:true);
        animateButtons(fxButtons: fxButtons, delay: 0)
        animateButtons(fxButtons: [micButton], delay: 0.6)
    }
    
    func animateButtons(fxButtons: [GlobalButton], delay: Double){
        for button in fxButtons{
            button.alpha = 1
            button.transform = CGAffineTransform(scaleX: 0, y: 0)
        }
        
        for button in fxButtons{
            button.fadeButton(fadeIn: true, delay: delay, useCompleteHandler: false)
        }
    }
    
    func playAudio(rate: Float?, pitch: Float?, fx: SoundFx, button: GlobalButton){
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

        audioPlayerNode.scheduleBuffer(buffer!, at: nil, options:[]){
            /* for udacity review: this is a completion handler gets called when sounds finished playing. as expected
             So i use a direct method call and skip skip the time calculation via length, sampleTime, Bitrate...
             scheduleBuffer(file... seems to call it right away
             */
            DispatchQueue.main.async {
                //self.stopAudio(fromButton: false) // no need to call stop, scheduleBuffer resets buffer and plays the new sound
                button.resetButton()
            }
        }
        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            return
        }
        audioPlayerNode.volume = 1
        audioPlayerNode.play()
    }
    
    @objc func stopAudio(fromButton: Bool){
        if fromButton == true {
            if let audioEngine = audioEngine{
                if let audioPlayerNode = audioPlayerNode{
                    audioPlayerNode.reset()
                    audioEngine.stop()
                    audioEngine.reset()
                }
            }
        }
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
