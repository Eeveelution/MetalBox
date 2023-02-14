//
//  GameViewController.swift
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 12.01.23.
//

import Cocoa
import MetalKit

// Our macOS specific view controller
class GameViewController: NSViewController {
    var renderer: Renderer!
    var mtkView: MTKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtkView = self.view as? MTKView else {
            print("View attached to GameViewController is not an MTKView")
            return
        }

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }

        mtkView.device = defaultDevice

        guard let newRenderer = Renderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer
        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        mtkView.delegate = renderer
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: {
            self.keyDown(with: $0)
            
            return $0
        })
        
        NSEvent.addLocalMonitorForEvents(matching: .keyUp, handler: {
            self.keyUp(with: $0)
            
            return $0
        })
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        return true
    }
    
    override func keyDown(with theEvent: NSEvent) {
        InputManager.onKeyPressed(theEvent.keyCode)
    }
    
    override func keyUp(with theEvent: NSEvent) {
        print("keyup")
        InputManager.onKeyReleased(theEvent.keyCode)
    }
}
