//
//  PitchViewController.swift
//  PitchPerfect
//
//  Created by Peter Pohlmann on 28.08.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit
import AVFoundation

class PitchViewController: UIViewController {
    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var fxLabel: UILabel!
    
    var audioURL:URL!
    var player: AVAudioPlayer?
    var audioFile:AVAudioFile!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    enum SoundFx: Int{ case slow=0, fast, reverb, echo, chipmunk, vader}
    
    @IBAction func stopAction(_ sender: Any) {
        print("stop pressed")
    }
    
    @IBAction func fxPressed(_ sender: UIButton){
        print("fx pressed")
        print(sender.tag)
        
        switch(SoundFx(rawValue: sender.tag)!){
        case .slow:
            print("play slow")
            playAudio(rate: 0.5, pitch: nil, fx: .slow)
        case .fast:
            playAudio(rate: 1.5, pitch: nil, fx: .fast)
        case .reverb:
            playAudio(rate: nil, pitch: nil, fx: .reverb)
        case .echo:
            playAudio(rate: nil, pitch: nil, fx: .echo)
        case .chipmunk:
            playAudio(rate: nil, pitch: 1000, fx: .chipmunk)
        case .vader:
            playAudio(rate: nil, pitch: -1000, fx: .vader)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("var on appear: \(audioURL)")
        prepareAudio()
    }
    
    func prepareAudio(){
        do {
            audioFile = try AVAudioFile(forReading: audioURL as URL)
            print("prepare audio success \(audioFile)")
        } catch {
            //let error = String(describing: error)
            //fxLabel.text = error
        }
    }
    
    func playAudio(rate: Float?, pitch: Float?, fx: SoundFx){
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioPlayerNode.volume = 1
        audioEngine.attach(audioPlayerNode)
        
        //get audiofile and set playback buffer
        let audioFile = try! AVAudioFile(forReading: audioURL)
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
        try! audioFile.read(into: buffer!, frameCount: AVAudioFrameCount(audioFile.length) )
        
        //attach and connect audioNodes for fx
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
        
        
        //assign audio effects to engine
       // audioEngine.attach(pitchNode)
       // audioEngine.attach(echoNode)
       // audioEngine.connect(audioPlayerNode, to: echoNode, format: audioFile.processingFormat)
       // audioEngine.connect(echoNode, to: audioEngine.mainMixerNode, format: buffer?.format)
        audioPlayerNode.scheduleBuffer(buffer!, at: nil, options:[], completionHandler: nil)
        //audioPlayerNode.scheduleBuffer(buffer!, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
        
        //if audioEngine.isRunning {
        //    return
        //}
        
        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("nope start engine")
            return
        }

         audioPlayerNode.play()
    }
    
    @objc func stopAudio(){
        
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
