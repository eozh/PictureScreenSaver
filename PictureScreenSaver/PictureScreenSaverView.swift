//
//  PictureScreenSaverView.swift
//  PictureScreenSaver
//
//  Created by Eugene Ozhinsky on 8/22/17.
//  Copyright © 2017 Eugene Ozhinsky. All rights reserved.
//


import Cocoa
import ScreenSaver

class PictureScreenSaverView: ScreenSaverView {

    var image: NSImage?
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        loadImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func startAnimation() {
        super.startAnimation()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        if let image = image {
            let point = CGPoint(x: (frame.size.width - image.size.width) / 2, y: (frame.size.height - image.size.height) / 2)
            image.draw(at: point, from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1)
        }
    }
    
    override func animateOneFrame() {
        
    }
    
    override func hasConfigureSheet() -> Bool {
        return false
    }
    
    override func configureSheet() -> NSWindow? {
        return nil
    }
    
    func loadImage() {
        DispatchQueue.global().async() {
            do {
                let url = URL(string: "https://raw.githubusercontent.com/yomajkel/ImageStream/added-swift-image/assets/swift.png")
                let data = try Data(contentsOf: url!)
                self.image = NSImage(data: data)
                self.needsDisplay = true
            } catch let error {
                // will figure out error handling later
            }
        }
    }
}
