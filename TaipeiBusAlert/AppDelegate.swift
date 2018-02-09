//
//  AppDelegate.swift
//  TaipeiBusAlert
//
//  Created by Wayne Yeh on 2018/2/9.
//  Copyright © 2018年 Wayne Yeh. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let 🗃 = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let 🗯 = NSPopover()
    
    private var 👁‍🗨: Any?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        guard let 🚌 = 🗃.button else { return }
        🚌.image = #imageLiteral(resourceName: "Bus")
        🚌.action = #selector(提示框(_:))
        公車.臺北市.路線清單{ (routes) in
            let buses = routes.filter{ (route) -> Bool in
                return route.nameZh.contains("617")
            }
            for bus in buses {
                公車.臺北市.站牌清單(route: bus, goBack: true) { (🚏s) in
                    let stops = 🚏s.filter{ (🚏) -> Bool in
                        return 🚏.nameZh.contains("時報廣場")
                    }
                    for stop in stops {
                        公車.臺北市.到站時間(route: bus, stop: stop, goBack: true) { (時間) in
                            print(時間)
                        }
                    }
                }
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

extension AppDelegate {
    @objc func 提示框(_ sender: Any?) {
        if 🗯.contentViewController == nil {
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            //2.
            let identifier = NSStoryboard.SceneIdentifier(rawValue: "ViewController")
            🗯.contentViewController = (storyboard.instantiateController(withIdentifier: identifier) as! NSViewController)
        }
        
        if 🗯.isShown {
            關閉提示框(sender: sender)
        } else {
            👁‍🗨 = NSEvent.addGlobalMonitorForEvents(matching:  [.leftMouseDown, .rightMouseDown], handler: { [weak self] (event) in
                if let 💪self = self, 💪self.🗯.isShown {
                    💪self.關閉提示框(sender: event)
                }
            })
            彈出提示框(sender: sender)
        }
    }
    
    func 彈出提示框(sender: Any?) {
        guard let 🚌 = 🗃.button else { return }
        🗯.show(relativeTo: 🚌.bounds, of: 🚌, preferredEdge: NSRectEdge.minY)
    }
    
    func 關閉提示框(sender: Any?) {
        if let 👀 = 👁‍🗨 {
            NSEvent.removeMonitor(👀)
            👁‍🗨 = nil
        }
        🗯.performClose(sender)
    }
}
