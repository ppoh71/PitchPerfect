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
    
    var audioURL:URL!
    var audioFile:AVAudioFile!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    var activeButton: UIButton!
    
    enum SoundFx: Int{ case slow = 0, fast, reverb, echo, chipmunk, vader}
    
    @IBAction func micButtonPressed(_ sender: Any) {
        print("dissmiss")
         _ = navigationController?.popToRootViewController(animated: true)
    }
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
    
    func audioPlayOrStop(rate: Float?, pitch: Float?, fx: SoundFx, button: UIButton){
        if button.alpha == 1{
            playAudio(rate: rate, pitch: pitch, fx: fx, button: button)
            button.alpha = 0.6
            animateButtons(button: button)
            activeButton = button
            print("alpha 6")
        }else{
            stopAudio("stoppen from BUTTON");
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
        print("var on appear: \(audioURL)")
        self.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    func playAudio(rate: Float?, pitch: Float?, fx: SoundFx, button: UIButton){
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioPlayerNode.volume = 1
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
        audioPlayerNode.stop()
        audioPlayerNode.scheduleBuffer(buffer!, at: nil, options:[]){
            /* for udacity review: as fare as this is a completion handler, looks like it gets called,
             right after sound is played. So i use a direct func call and skip skip the time calculation via length, sampleTime, Bitrate...
             Not that i am too lazy, but its less complexety..
             */
            self.stopAudio("stopped from buffer")
            DispatchQueue.main.async { // Correct
                self.toggleButton(button: button)
            }
        }
        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("nope start engine")
            return
        }

        audioPlayerNode.play()
    }
    
    @objc func stopAudio(_ str: String){
        print(str)
        //audioEngine = AVAudioEngine()
        audioPlayerNode.reset()
    }
    
    func animateButtons(button: UIButton){
         button.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.4, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            button.alpha = 0.1
            //button.transform = CGAffineTransform(scaleX: 0.975, y: 0.96)
        })
    }
    
    func toggleButton(button: UIButton){
        button.alpha = 1
        button.layer.removeAllAnimations()
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
