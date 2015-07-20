//
//  AppDelegate.swift
//  Menubar Colors
//
//  Created by Nikolai Vazquez on 7/19/15.
//  Copyright (c) 2015 Nikolai Vazquez. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Cocoa

@NSApplicationMain

// - MARK: AppDelegate Class
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: Status Variables

    @IBOutlet weak var statusMenu: StatusMenu!
    
    var statusItem: NSStatusItem!
    
    // MARK: NSWindow-Related Variables
    
    let aboutWindowController: AboutWindowController = AboutWindowController(windowNibName: "AboutWindow")
    
    // MARK: NSApplicationDelegate Methods
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        let statusBar = NSStatusBar.systemStatusBar()
        statusItem = statusBar.statusItemWithLength(-1)
        
        let icon = NSImage(named: "menu-icon")
        icon?.setTemplate(true)
        statusItem.image = icon
        
        let button = statusItem.button
        button?.toolTip = "Click to show color panel\nRight click to show menu"
        button?.target = self
        button?.action = "statusButtonPressed:"
        button?.sendActionOn(Int((NSEventMask.LeftMouseUpMask | NSEventMask.RightMouseUpMask).rawValue))
        
        statusMenu.delegate = self
        
    }
    
    // MARK: Selector Methods
    
    func statusButtonPressed(sender: NSStatusBarButton) {
        if let event = NSApplication.sharedApplication().currentEvent {
            if (event.modifierFlags & NSEventModifierFlags.ControlKeyMask).rawValue != 0 || event.type == .RightMouseUp {
                // Handle right mouse click
                statusItem.menu = statusMenu
                statusItem.popUpStatusItemMenu(statusMenu)
            } else {
                // Handle left mouse click
                
            }
        }
    }
    
    // MARK: IB Methods
    
    @IBAction func toggleStartAtLogin(sender: AnyObject) {
        let manager = LoginItemsManager()
        manager.toggleStartAtLogin()
    }
    
    @IBAction func showAbout(sender: AnyObject?) {
        aboutWindowController.showWindow(sender)
    }

}

// MARK: - NSMenuDelegate Extension

extension AppDelegate: NSMenuDelegate {
    
    // MARK: NSMenuDelegate Methods

    func menuDidClose(menu: NSMenu) {
        statusItem.menu = nil
    }
    
    func menuWillOpen(menu: NSMenu) {
        if let statusMenu = menu as? StatusMenu {
            if let startAtLoginItem = statusMenu.itemWithTitle("Start at Login") {
                let manager = LoginItemsManager()
                if manager.startAtLogin {
                    startAtLoginItem.state = NSOnState
                } else {
                    startAtLoginItem.state = NSOffState
                }
            }
        }
    }

}

