//
//  MatchPickerOverlayView.swift
//  CSCI490 App2
//
//  Created by Ron Ward on 3/23/16.
//  Copyright © 2016 Ethan Ward. All rights reserved.
//

import UIKit
import Koloda

private let overlayRightImageName = "overlay_like"
private let overlayLeftImageName = "overlay_skip"

class MatchPickerOverlayView: OverlayView {
    
//    @IBOutlet weak var userNameAge: UILabel!
    
    @IBOutlet lazy var overlayImageView: UIImageView! = {
        [unowned self] in
        
        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        return imageView
        }()
    
    override var overlayState:OverlayMode  {
        didSet {
            switch overlayState {
            case .Left :
                overlayImageView.image = UIImage(named: overlayLeftImageName)
            case .Right :
                overlayImageView.image = UIImage(named: overlayRightImageName)
            default:
                overlayImageView.image = nil
            }
            
        }
    }
    
}
