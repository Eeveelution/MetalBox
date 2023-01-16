//
//  Scene.swift
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 13.01.23.
//

import Foundation
import Metal
import MetalKit

struct SceneDetailsDescriptor {
    ///Name of the scene, used in Debugging
    let name: String
    ///Allow displaying of the default loading screen
    let allowLoadingScreen: Bool
    ///Whether Asynchronous loading is allowed,
    ///this allows ``Scene.initialize()`` to happen on another thread
    ///Potentially speeding up load times
    let allowAsyncLoading: Bool
}

class Scene {
    init() {
        
    }
    
    /// Retrieves some information about the scene and the way it is supposed to be loaded
    public func getSceneDetails() -> SceneDetailsDescriptor? {
        return nil
    }
    
    ///Initialization function, load all your assets here and prepare for rendering or any game logic here
    public func initialize(renderer: Renderer) {
        
    }
    
    ///Draw things here, happens on a seperate thread from ``update()``
    public func render(in view: MTKView, deltaTime: Float) {
        
    }
    
    ///Update Game logic here, can also be used to prepare work for ``render()``,
    ///runs on a seperate thread from ``render()``
    ///Keep in mind this gets executed after the Task queue
    public func update(deltaTime: Float) {
        
    }
}
