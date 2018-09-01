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
    
    func fadeButton(fadeIn: Bool, useCompleteHandler: Bool){
        let fadeInValue = fadeIn ? CGFloat(1) : CGFloat(0) //fade in when true, else fadeout by cgfloat value
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn, .curveEaseInOut, .allowUserInteraction], animations: {
            self.alpha = CGFloat(fadeInValue)
            self.transform = CGAffineTransform(scaleX: fadeInValue, y: fadeInValue)
        }, completion: { (complete: Bool) in
            if useCompleteHandler{
                self.animateButton()
            }
        })
    }
    
    func changeButtonImage(imageName: String, useCompleteHandler: Bool){
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn, .curveEaseInOut, .allowUserInteraction], animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }, completion: { (complete: Bool) in
            
            if let image = UIImage(named: imageName) {
                self.setImage(image, for: .normal)
            }
            self.fadeButton(fadeIn: true, useCompleteHandler: useCompleteHandler)
            print("fade from button class")
        })
    }
    
    func animateButton(){
        UIView.animate(withDuration: 0.4, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            self.alpha = 0.3
            self.transform = CGAffineTransform(scaleX: 0.775, y: 0.775)
        })
    }
    
    func removeAnimtion(){
        self.layer.removeAllAnimations()
    }
    
}

