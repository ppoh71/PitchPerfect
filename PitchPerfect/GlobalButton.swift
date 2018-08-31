//
//  GlobalButton.swift
//  PitchPerfect
//
//  Created by Peter Pohlmann on 31.08.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit

class GlobalButton: UIButton {
        
        override func draw(_ rect: CGRect) {
            updateLayerProperties()
            print("shadow button")
        }
        
        func updateLayerProperties() {
            self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75).cgColor
            self.layer.shadowOffset = CGSize(width: 3, height: 3)
            self.layer.shadowOpacity = 0.7
            self.layer.shadowRadius = 6.0
            self.layer.masksToBounds = false
        }
        
    }

