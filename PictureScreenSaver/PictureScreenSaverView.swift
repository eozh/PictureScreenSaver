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
    let defaults = ScreenSaverDefaults(forModuleWithName: "eugene-o.PictureScreenSaver")
    var directory: String?
    var imageFileNames = [String]()
    let layer1 = CALayer()
    let layer2 = CALayer()
    var activeLayer = 1
    
    var confWindowController: ConfWindowController?
    
    static var sharedViews: [PictureScreenSaverView] = []
    
    var interval = 10
    var transition = 1
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)

        setDirectory(directory: defaults?.string(forKey: "directory"))
        if let interval = defaults?.integer(forKey: "interval"){
            if interval > 0 {
                self.interval = interval
            }
        }
        if let transition = defaults?.integer(forKey: "transition"){
            self.transition = transition
        }
            
        //loadImage()
        //Swift.print("animationTimeInterval: "+String(format:"%f", animationTimeInterval))
        animationTimeInterval=TimeInterval(interval)
        self.wantsLayer = true
        //Swift.print("self.layer: ",self.layer)
        layer1.bounds = (self.layer?.bounds)!
        layer1.position = CGPoint(x: (self.layer?.bounds.midX)!, y: (self.layer?.bounds.midY)!)
        layer2.bounds = (self.layer?.bounds)!
        layer2.position = layer1.position
        self.layer?.addSublayer(layer1)
        self.layer?.addSublayer(layer2)
        
        PictureScreenSaverView.sharedViews.append(self)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDirectory(directory: String?){
        self.directory = directory
        // Create a FileManager instance
        if let directory = self.directory{
            do {
                
                let fileManager = FileManager.default
                
                // Get contents in directory: '.' (current one)
                // let fileNames = try fileManager.contentsOfDirectory(atPath: directory)
                // let's try deep traversal:
                let fileNames = try fileManager.subpathsOfDirectory(atPath: directory)
                //works but doesn't seem to traverse symbolic links

                Swift.print(fileNames)
                
                self.imageFileNames = [String]()
                
                for s in fileNames {
                    //Swift.print(s)
                    let s1 = s.lowercased();
                    if s1.hasSuffix(".jpg") || s1.hasSuffix(".jpeg") || s1.hasSuffix(".gif"){
                        self.imageFileNames.append(s);
                    }
                }
                
                Swift.print(self.imageFileNames)
            } catch let error {
                Swift.print(error)
            }
        }
        
    }
    
    override func startAnimation() {
        super.startAnimation()
        animateOneFrame()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }

    override func animateOneFrame() {
        Swift.print("animateOneFrame")
        loadImage()
        
        //needsDisplay = true
        if activeLayer == 1{
            activeLayer = 2
            Swift.print("activeLayer :",activeLayer)
            CATransaction.setAnimationDuration(CFTimeInterval(transition))
            layer1.opacity = 0
            updateImageLayer(imageLayer: layer2)
//            CATransaction.setAnimationDuration(0)
//            layer2.contents = image
            CATransaction.setAnimationDuration(CFTimeInterval(transition))
            layer2.opacity = 1
        }  else {
            activeLayer = 1
            Swift.print("activeLayer :",activeLayer)
            CATransaction.setAnimationDuration(CFTimeInterval(transition))
            layer2.opacity = 0
            updateImageLayer(imageLayer: layer1)
            CATransaction.setAnimationDuration(CFTimeInterval(transition))
            layer1.opacity = 1
        }

    }
    
    func updateImageLayer(imageLayer: CALayer){
        if let image = image {
            Swift.print("updateImageLayer")
            CATransaction.setAnimationDuration(0)
            imageLayer.contents = image
            let scaleX = frame.size.width/image.size.width;
            let scaleY = frame.size.height/image.size.height;
            let scale = min(scaleX, scaleY)
//            let drawWidth = image.size.width * scale;
//            let drawHeight = image.size.height * scale;
//            let newBounds = CGRect(x: 0, y: 0, width: drawWidth, height: drawHeight)
//            Swift.print("bounds :",layer1.bounds)
            //Swift.print("newBounds :",newBounds)
//            Swift.print("image.size :",image.size)
            imageLayer.bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            //layer1.bounds = CGRect(x: 0, y: 0, width: 1920, height: 1200)
            imageLayer.transform = CATransform3DMakeScale(scale, scale, 1)
        }
    }
    
    override func hasConfigureSheet() -> Bool {
        return true
    }

    override func configureSheet() -> NSWindow? {
        if let controller = confWindowController {
            return controller.window
        }
        
        let controller = ConfWindowController(windowNibName: "ConfWindowController")
        
        confWindowController = controller
        return controller.window

    }

    func loadImage() {
        Swift.print("loadImage")
        DispatchQueue.global().async() {
 //           do {
/*
                let url = URL(string: "https://raw.githubusercontent.com/yomajkel/ImageStream/added-swift-image/assets/swift.png")
                let data = try Data(contentsOf: url!)
                self.image = NSImage(data: data)
*/
                
        if let directory = self.directory {
            if(self.imageFileNames.count > 0){
                let num = arc4random_uniform(UInt32(self.imageFileNames.count))
                let fileName = self.imageFileNames[Int(num)]
                let path = directory+"/"+fileName;
                
//                self.image = NSImage(contentsOfFile: "/Users/eugene/Pictures/ephemera/xcmrxui00yrxbjw1tenl.jpg")
                self.image = NSImage(contentsOfFile: path)
            }
        }
//                self.needsDisplay = true
//            } catch let error {
//                Swift.print(error)
//            }
        }
    }
}
