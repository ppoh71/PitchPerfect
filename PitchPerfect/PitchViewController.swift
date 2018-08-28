//
//  PitchViewController.swift
//  PitchPerfect
//
//  Created by Peter Pohlmann on 28.08.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit

class PitchViewController: UIViewController {
    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    
    var audioURL = "Test URL"
    
    enum PlaybackAudio: Int{ case slow=0, fast, reverb, echo, chipmunk, vader}
    
    @IBAction func stopAction(_ sender: Any) {
        print("stop pressed")
    }
    
    @IBAction func fxPressed(_ sender: UIButton){
        print("fx pressed")
        print(sender.tag)
        
        switch(PlaybackAudio(rawValue: sender.tag)!){
        case .slow:
            print("play slow")
        case .fast:
             print("play fast")
        case .reverb:
             print("play reverb")
        case .echo:
             print("play echo")
        case .chipmunk:
             print("play chip")
        case .vader:
             print("play vader")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("var on appear: \(audioURL)")
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
