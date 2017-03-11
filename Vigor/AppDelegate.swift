//
//  AppDelegate.swift
//  Vigor
//
//  Created by YOONJAE on 2017. 1. 28.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window.setIsVisible(false)

        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        AXIsProcessTrustedWithOptions(options)

        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyDown.rawValue)
        if let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask), callback: { proxy, type, event, pointer in
            let keyCodeBindings = [
                4: 123, // h -> left arrow
                38: 125, // j -> down arrow
                40: 126, // k -> up arrow
                37: 124 // l -> right arrow
            ] as [Int64: Int64]

            if [.keyDown, .keyUp].contains(type) && event.flags.contains(CGEventFlags.maskSecondaryFn) {
                if let newKeyCode = keyCodeBindings[event.getIntegerValueField(.keyboardEventKeycode)] {
                    event.flags.remove(.maskSecondaryFn)
                    event.setIntegerValueField(.keyboardEventKeycode, value: newKeyCode)
                }
            }
            return Unmanaged.passRetained(event)
        }, userInfo: nil) {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            CFRunLoopRun()
        }
    }
}
