//
//  InputManager.swift
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 13.02.23.
//

import Foundation

class InputManager {
    static var keyPressed: [UInt16: Bool] = [:]
    static var heldTimes: [UInt16: Int] = [:]
    
    static var keyLock: NSLock = NSLock()
    
    class func retrieveHeldTime(_ keyCode: UInt16) -> Int {
        keyLock.lock()
        
        if heldTimes[keyCode] == nil {
            keyLock.unlock()
            
            return -1
        } else {
            keyLock.unlock()
            
            return heldTimes[keyCode]!
        }
    }
    
    class func setHeldTime(_ keyCode: UInt16, value: Int = 0) {
        keyLock.lock()
        
        heldTimes[keyCode] = value
        
        keyLock.unlock()
    }
    
    class func retrievePressed(_ keyCode: UInt16) -> Bool {
        keyLock.lock()
        
        if keyPressed[keyCode] == nil {
            keyLock.unlock()
            
            return false
        } else {
            keyLock.unlock()
            
            return keyPressed[keyCode]!
        }
    }
    
    class func setPressed(_ keyCode: UInt16, value: Bool = false) {
        keyLock.lock()
        
        keyPressed[keyCode] = value
        
        keyLock.unlock()
    }
    
    /* Handlers */
    
    class func onKeyPressed(_ keycode: UInt16) {
        setPressed(keycode, value: true)
    }
    
    class func onKeyReleased(_ keycode: UInt16) {
        setPressed(keycode, value: false)
        setHeldTime(keycode, value: 0)
    }
    
    /* Keypress checks */
    
    class func isKeyPressed(_ keycode: UInt16) -> Bool {
        return retrieveHeldTime(keycode) >= 0
    }
    
    class func isKeyPressed(_ keycode: KeyCodes) -> Bool {
        return isKeyPressed(keycode.rawValue)
    }
    
    class func isKeyFirstPressed(_ keycode: UInt16) -> Bool {
        return retrieveHeldTime(keycode) == 1
    }
    
    class func isKeyFirstPressed(_ keycode: KeyCodes) -> Bool {
        return isKeyFirstPressed(keycode.rawValue)
    }
    
    class func isKeyHeld(_ keycode: UInt16) -> Bool {
        return retrieveHeldTime(keycode) > 1
    }
    
    class func isKeyHeld(_ keycode: KeyCodes) -> Bool {
        return isKeyHeld(keycode.rawValue)
    }
}
