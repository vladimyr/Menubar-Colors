//
//  AppDelegate.swift
//  Menubar Colors
//
//  Created by Nikolai Vazquez on 5/30/15.
//  Copyright (c) 2015 Nikolai Vazquez. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSMenuDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var colorsMenuItem: NSMenuItem!
    @IBOutlet weak var resetPositionMenuItem: NSMenuItem!
    
    @IBOutlet weak var aboutWindow: AboutWindow!
    @IBOutlet weak var aboutAppIconImageView: NSImageView!
    @IBOutlet weak var aboutAppNameLabel: NSTextField!
    @IBOutlet weak var aboutVersionLabel: NSTextField!
    @IBOutlet weak var aboutProjectLinkButton: NSButton!
    @IBOutlet weak var aboutCopyrightLabel: NSTextField!
    
    let startTime = NSDate()
    var executionTime: NSTimeInterval {
        get {
            let endTime = NSDate()
            return endTime.timeIntervalSinceDate(startTime)
        }
    }
    
    var preferences: Preferences!
    var colorPanel: MenubarColorPanel?
    
    var statusItem: NSStatusItem?
    var statusButton: NSStatusBarButton?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        //  Set the preferences object
        preferences = ApplicationSupportHandler.defaultHandler().preferences
        if let output = preferences.read() {
            preferences.dictionary = output
        }
        
        //  Set icon image
        let icon = NSImage(named: "statusIcon")
        icon!.setTemplate(true)
        statusItem!.image = icon
    }
    
    override func awakeFromNib() {
        //  Instantiate colorPanel and adjust
        colorPanel = MenubarColorPanel()
        colorPanel?.delegate          = self
        colorPanel?.hidesOnDeactivate = false
        colorPanel?.moveToScreenTopRight()
        
        //  Set up the about window
        aboutWindow.delegate                   = self
        aboutWindow.titlebarAppearsTransparent = true
        aboutWindow.movableByWindowBackground  = true
        aboutWindow.backgroundColor            = NSColor(red:1, green:1, blue:1, alpha:1)
        aboutAppIconImageView.image            = NSApp.applicationIconImage
        aboutAppNameLabel.stringValue          = (NSBundle.mainBundle().infoDictionary!["CFBundleName"]) as! String
        aboutVersionLabel.stringValue          = "Version " + (NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String)
        let projectLinkText                    = "GitHub Project Page"
        aboutProjectLinkButton.title           = projectLinkText
        aboutProjectLinkButton.stringValue     = projectLinkText
        aboutCopyrightLabel.stringValue        = (NSBundle.mainBundle().infoDictionary!["NSHumanReadableCopyright"]) as! String
        
        //  Set status bar item to default size
        let statusBar = NSStatusBar.systemStatusBar()
        statusItem = statusBar.statusItemWithLength(-1)
        
        //  Set status button and action
        statusButton         = statusItem!.button!
        statusButton?.target = self
        statusButton?.action = "statusButtonPressed:"
        statusButton?.sendActionOn(Int((NSEventMask.LeftMouseUpMask | NSEventMask.RightMouseUpMask).rawValue))
        
        statusMenu.delegate  = self
    }
    
    func statusButtonPressed(sender: NSStatusBarButton!) {
        var event: NSEvent! = NSApp.currentEvent!
        if (event.type == NSEventType.RightMouseUp) {
            if  colorPanel!.visible == false {
                colorsMenuItem.title = "Show Colors"
            } else {
                colorsMenuItem.title = "Hide Colors"
            }
            if  preferences.resetPositionUponOpen {
                resetPositionMenuItem.state = NSOnState
            } else {
                resetPositionMenuItem.state = NSOffState
            }
            statusItem?.menu = statusMenu
            statusItem?.popUpStatusItemMenu(statusMenu)
        } else {
            colorPanel?.toggleVisibility()
        }
    }
    
    //  Disable left click menu upon close
    func menuDidClose(menu: NSMenu) {
        statusItem?.menu = nil
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        //  Insert code here to tear down your application
        NSLog("Terminating...\nExecution time = %f seconds", executionTime)
    }
    
    @IBAction func colorsMenuItemSelected(sender: NSMenuItem) {
        colorPanel?.toggleVisibility()
    }
    
    @IBAction func resetPositionMenuItemSelected(sender: NSMenuItem) {
        if sender.state == NSOffState {
            sender.state = NSOnState
            preferences.resetPositionUponOpen = true
        } else {
            sender.state = NSOffState
            preferences.resetPositionUponOpen = false
        }
        preferences.write()
    }
    
    @IBAction func aboutMenuItemSelected(sender: NSMenuItem) {
        if !aboutWindow.visible {
            aboutWindow.open()
        }
    }
    
    @IBAction func projectLinkButtonPushed(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://github.com/nvzqz/Menubar-Colors")!)
    }

}

