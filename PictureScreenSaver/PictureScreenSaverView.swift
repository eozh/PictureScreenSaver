//
//  PictureScreenSaverView.swift
//  PictureScreenSaver
//
//  Created by Eugene Ozhinsky on 8/22/17.
//  Copyright © 2017 Eugene Ozhinsky. All rights reserved.
//


import Cocoa
import ScreenSaver

enum PlaybackMode: Int {
    case sequential, sequentialFromRandom, random
}

class PictureScreenSaverView: ScreenSaverView {

    var image: NSImage?
    let defaults = ScreenSaverDefaults(forModuleWithName: "eugene-o.PictureScreenSaver")
    //var directory: String?
    var directories: [String] = []
    var imagePaths: [String] = []
    var imageDescriptions: [String] = [] // without prefix, for display
    
    let layer1 = CALayer()
    let layer2 = CALayer()
    var activeLayer = 0
    var textLayer = CATextLayer()
    var currentImageDescription: String?
    
    var confWindowController: ConfWindowController?
    
    static var sharedViews: [PictureScreenSaverView] = []
    
    var interval = 10
    var transition = 1

    var playbackMode = PlaybackMode.sequential
    var nextImageNumber = 0

    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)

        setDirectories(directories: defaults?.stringArray(forKey: "directories"))
        
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

        layer1.opacity = 0
        layer2.opacity = 0

        self.layer?.addSublayer(layer1)
        self.layer?.addSublayer(layer2)
        
        //textLayer.string = ""
        textLayer.bounds = (self.layer?.bounds)!
        textLayer.anchorPoint = CGPoint(x: 0, y: 1)
        textLayer.position = CGPoint(x: 10, y: layer!.bounds.height - 10)
        //textLayer.alignmentMode = .left
        //textLayer.foregroundColor = NSColor.lightGray.cgColor
        textLayer.shadowRadius = 2.0
        textLayer.shadowOpacity = 1.0
        textLayer.shadowColor = CGColor.black
        textLayer.shadowOffset = CGSize(width:0, height:0)
        textLayer.fontSize = 18
        textLayer.font = NSFont.systemFont(ofSize: 18)
        self.layer?.addSublayer(textLayer)
        
        if let bShow = defaults?.bool(forKey: "show_file_names"){
            setShowFileNames(bShow: bShow)
        }

        if let mode = PlaybackMode(rawValue: defaults?.integer(forKey: "playback_mode") ?? 0){
            playbackMode = mode
        }

        if playbackMode == PlaybackMode.sequentialFromRandom && self.imagePaths.count > 0 {
            nextImageNumber = Int(arc4random_uniform(UInt32(self.imagePaths.count)))
        }
        
        PictureScreenSaverView.sharedViews.append(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDirectories(directories: [String]?){
        if let directories = directories{
            self.directories = directories
            self.imagePaths = [String]()
            self.imageDescriptions = [String]()
            
            do {
                // Create a FileManager instance
                let fileManager = FileManager.default
                
                for directory in directories.sorted() {
                    // deep traversal:
                    let fileNames = try fileManager.subpathsOfDirectory(atPath: directory)

                    //Swift.print(fileNames)
                    
                    for s in fileNames.sorted() {
                        //Swift.print(s)
                        let s1 = s.lowercased();
                        if s1.hasSuffix(".jpg") || s1.hasSuffix(".jpeg") || s1.hasSuffix(".gif") || s1.hasSuffix(".png"){
                            self.imagePaths.append(directory+"/"+s)
                            self.imageDescriptions.append(s)
                        }
                    }
                }
                //Swift.print(self.imagePaths)
            } catch let error {
                NSLog(error.localizedDescription)
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
        NSLog("EO animateOneFrame")
        
        //Do nothing on first run: this method is called twice first
        if activeLayer == 0{
            NSLog("EO first run")
            activeLayer = 1
            return
        }
        
        loadImage()
        
        //needsDisplay = true
        if activeLayer == 1{
            activeLayer = 2
            NSLog("EO activeLayer: \(activeLayer)")
            CATransaction.setAnimationDuration(CFTimeInterval(transition))
            layer1.opacity = 0
            updateImageLayer(imageLayer: layer2)
//            CATransaction.setAnimationDuration(0)
//            layer2.contents = image
            CATransaction.setAnimationDuration(CFTimeInterval(transition))
            layer2.opacity = 1
        }  else {
            activeLayer = 1
            NSLog("EO activeLayer: \(activeLayer)")
            CATransaction.setAnimationDuration(CFTimeInterval(transition))
            layer2.opacity = 0
            updateImageLayer(imageLayer: layer1)
            CATransaction.setAnimationDuration(CFTimeInterval(transition))
            layer1.opacity = 1
        }

    }
    
    func updateImageLayer(imageLayer: CALayer){
        if let image = image {
            NSLog("EO updateImageLayer")
            CATransaction.setAnimationDuration(0)
            imageLayer.contents = image
            let scaleX = frame.size.width/image.size.width;
            let scaleY = frame.size.height/image.size.height;
            let scale = min(scaleX, scaleY)
            imageLayer.bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            imageLayer.transform = CATransform3DMakeScale(scale, scale, 1)
        }
        if let desc = self.currentImageDescription{
            self.textLayer.string = desc
        }
    }
    
    override var hasConfigureSheet: Bool {
        return true
    }

    override var configureSheet: NSWindow? {
        if let controller = confWindowController {
            return controller.window
        }
        
        let controller = ConfWindowController(windowNibName: "ConfWindowController")
        
        confWindowController = controller
        return controller.window

    }

    func performGammaFade() -> Bool {
        return true
    }

    
    func loadImage() {
        NSLog("EO loadImage")

        if self.imagePaths.count == 0{
            return
        }
        
        var num = 0
        switch playbackMode{
        case PlaybackMode.sequential, PlaybackMode.sequentialFromRandom:
            num = nextImageNumber
            nextImageNumber += 1
            if nextImageNumber == self.imagePaths.count {
                nextImageNumber = 0
            }
        case PlaybackMode.random:
            num = Int(arc4random_uniform(UInt32(self.imagePaths.count)))
        }
        
        //Do we really need to do it on a separate thread?
        //This may be causing blank images!
        //DispatchQueue.global().async() {
            let path = self.imagePaths[Int(num)]
            self.image = NSImage(contentsOfFile: path)
            self.currentImageDescription = self.imageDescriptions[Int(num)]
        //}
    }
    
    func setShowFileNames(bShow: Bool){
        if(bShow){
            textLayer.opacity = 1
        } else {
            textLayer.opacity = 0
        }
    }
}
