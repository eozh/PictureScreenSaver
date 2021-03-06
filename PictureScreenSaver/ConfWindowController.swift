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

    var directories: [String] = []
    
    var playbackMode = PlaybackMode.sequential
    
    @IBOutlet weak var intervalStepper: NSStepper!
    @IBOutlet weak var transitionStepper: NSStepper!
    @IBOutlet weak var transitionField: NSTextField!
    @IBOutlet weak var okButton: NSButton!
    @IBOutlet weak var intervalField: NSTextField!
    @IBOutlet weak var showFileNamesCheckBox: NSButton!
    
    @IBOutlet weak var folderTableView: NSTableView!
    @IBOutlet weak var sequentialRadioButton: NSButton!
    @IBOutlet weak var sequentialFromRandomRadioButton: NSButton!
    @IBOutlet weak var randomRadioButton: NSButton!
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        NSLog("EO cancelButtonPressed");
        loadDefaults()
        window?.sheetParent?.endSheet(window!)
    }
 
    @IBAction func okButtonPressed(_ sender: Any) {
        // remove focus
        NSLog("EO okButtonPressed");

        if !(window?.makeFirstResponder(nil))!{
            return
        }
        
        defaults?.set(self.directories, forKey: "directories")
        defaults?.set(intervalField.intValue, forKey: "interval")
        defaults?.set(transitionField.intValue, forKey: "transition")
        defaults?.set(showFileNamesCheckBox.state == NSControl.StateValue.on, forKey: "show_file_names")
        defaults?.set(playbackMode.rawValue, forKey: "playback_mode")

        defaults?.synchronize()
        for view in PictureScreenSaverView.sharedViews{
            view.setDirectories(directories: self.directories)
            view.interval = Int(intervalField.intValue)
            view.transition = Int(transitionField.intValue)
            view.setShowFileNames(bShow: showFileNamesCheckBox.state == NSControl.StateValue.on)
            view.playbackMode = playbackMode
        }
        window?.sheetParent?.endSheet(window!)
    }
    
    @IBAction func plusButtonPressed(_ sender: Any) {
        NSLog("EO plusButtonPressed");

        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a folder with images";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseFiles          = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = false;
        dialog.allowsMultipleSelection = false;
        //dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                NSLog("EO appending path...");
                directories.append(path)
                NSLog("EO %@", directories.description);
                folderTableView.reloadData()
            }
        } else {
            // User clicked on "Cancel"
            return
        }

    }

    @IBAction func minusButtonPressed(_ sender: Any) {
        NSLog("EO minusButtonPressed");
        if(folderTableView.selectedRow >= 0 ){
            directories.remove(at: folderTableView.selectedRow)
            folderTableView.reloadData()
        }
    }
    
    func control(_ control: NSControl,
                          didFailToFormatString string: String,
                          errorDescription error: String?) -> Bool {
                
        let alert: NSAlert = NSAlert()
        alert.alertStyle = NSAlert.Style.critical
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
        if let directories = defaults?.stringArray(forKey: "directories"){
            self.directories = directories
        }
        if let interval = defaults?.integer(forKey: "interval"){
            if interval > 0 {
                intervalField.intValue = Int32(interval)
                intervalStepper.intValue = Int32(interval)
            } else {
                intervalField.intValue = 10
                intervalStepper.intValue = 10
            }
        } else {
            intervalField.intValue = 10
            intervalStepper.intValue = 10
        }
        
        if let transition = defaults?.integer(forKey: "transition"){
            if transition > 0 {
                transitionField.intValue = Int32(transition)
                transitionStepper.intValue = Int32(transition)
            } else{
                transitionField.intValue = 1
                transitionStepper.intValue = 1
            }
        } else {
            transitionField.intValue = 1
            transitionStepper.intValue = 1
        }
        
        if let bShow = defaults?.bool(forKey: "show_file_names"){
            if bShow {
                showFileNamesCheckBox.state = NSControl.StateValue.on
            } else{
                showFileNamesCheckBox.state = NSControl.StateValue.off
            }
        } else {
            showFileNamesCheckBox.state = NSControl.StateValue.on
        }
        
        if let mode = PlaybackMode(rawValue: defaults?.integer(forKey: "playback_mode") ?? 0){
            playbackMode = mode
            NSLog("EO playbackMode: \(playbackMode)")
            switch playbackMode{
            case PlaybackMode.sequential:
                NSLog("EO sequential")
                sequentialRadioButton.state = .on
            case PlaybackMode.sequentialFromRandom:
                NSLog("EO sequentialFromRandom")
                sequentialFromRandomRadioButton.state = .on
            case PlaybackMode.random:
                NSLog("EO Random")
                randomRadioButton.state = .on
            }
        } else {
            NSLog("EO playbackMode undefined")
            sequentialRadioButton.state = .on
        }

        
    }
    
    @IBAction func playbackModeChanged(_ sender: NSButton?) {
        NSLog("EO plabackModeChanged")
        switch sender{
        case sequentialRadioButton:
            NSLog("EO sequential")
            playbackMode = PlaybackMode.sequential
        case sequentialFromRandomRadioButton:
            NSLog("EO sequentialFromRandom")
            playbackMode = PlaybackMode.sequentialFromRandom
        case randomRadioButton:
            playbackMode = PlaybackMode.random
            NSLog("EO Random")
        default:
            ()
        }
    }
    
}

extension ConfWindowController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        NSLog("EO numberOfRows");
        return directories.count
    }
 
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        NSLog("EO tableView");
        let item = (directories)[row]
        
        let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
        cell?.textField?.stringValue = item
        return cell
    }

}
