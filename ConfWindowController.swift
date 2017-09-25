//
//  ConfWindowController.swift
//  PictureScreenSaver
//
//  Created by Eugene Ozhinsky on 9/15/17.
//  Copyright © 2017 Eugene Ozhinsky. All rights reserved.
//

import Cocoa
import ScreenSaver

class ConfWindowController: NSWindowController, NSTextFieldDelegate {

    let defaults = ScreenSaverDefaults(forModuleWithName: "eugene-o.PictureScreenSaver")

    
    @IBOutlet weak var intervalStepper: NSStepper!
    @IBOutlet weak var transitionStepper: NSStepper!
    @IBOutlet weak var transitionField: NSTextField!
    @IBOutlet weak var okButton: NSButton!
    @IBOutlet weak var fileNameField: NSTextField!
    @IBOutlet weak var intervalField: NSTextField!
    

    @IBAction func cancelButtonPressed(_ sender: Any) {
        loadDefaults()
        NSApp.mainWindow?.endSheet(window!)
    }
 
    @IBAction func okButtonPressed(_ sender: Any) {
        // remove focus

//        if !(intervalField.window?.makeFirstResponder(nil))!{
        if !(window?.makeFirstResponder(nil))!{
            return
        }
        
        defaults?.set(fileNameField.stringValue, forKey: "directory")
        defaults?.set(intervalField.intValue, forKey: "interval")
        defaults?.set(transitionField.intValue, forKey: "transition")
        defaults?.synchronize()
        for view in PictureScreenSaverView.sharedViews{
            view.setDirectory(directory: fileNameField.stringValue)
            view.interval = Int(intervalField.intValue)
            view.transition = Int(transitionField.intValue)
        }
        NSApp.mainWindow?.endSheet(window!)
    }
    @IBAction func browseButtonPressed(_ sender: Any) {
/*
        let alert: NSAlert = NSAlert()
        alert.messageText = "Browse"
        alert.runModal()
*/
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a folder with images";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseFiles          = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = false;
        dialog.allowsMultipleSelection = false;
        //dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSModalResponseOK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                fileNameField.stringValue = path
            }
        } else {
            // User clicked on "Cancel"
            return
        }
        
    }

    
    func control(_ control: NSControl,
                          didFailToFormatString string: String,
                          errorDescription error: String?) -> Bool {
        
   /*     let field = control as? NSTextField
        if let field = field{
            field.intValue = 0
        } */
        
        let alert: NSAlert = NSAlert()
        alert.alertStyle = NSAlertStyle.critical
        alert.messageText = error!
        alert.beginSheetModal(for: window!)
        
        return false;

        
    }
   
    override func windowDidLoad() {
        NSLog("EO ConfWindowController.windowDidLoad()")
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        loadDefaults()
    }
    
    func loadDefaults(){
        if let directory = defaults?.string(forKey: "directory"){
            fileNameField.stringValue = directory
        }
        if let interval = defaults?.integer(forKey: "interval"){
            if interval > 0 {
                intervalField.intValue = Int32(interval)
            } else {
                intervalField.intValue = 10
            }
        } else {
            intervalField.intValue = 10
        }
        
        if let transition = defaults?.integer(forKey: "transition"){
            transitionField.intValue = Int32(transition)
        } else {
            transitionField.intValue = 1
        }
    }
    
}