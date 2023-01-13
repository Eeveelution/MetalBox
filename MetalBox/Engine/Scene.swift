//
//  Scene.swift
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 13.01.23.
//

import Foundation

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
    /// Retrieves some information about the scene and the way it is supposed to be loaded
    public func getSceneDetails() -> SceneDetailsDescriptor? {
        return nil
    }
    
    ///Initialization function, load all your assets here and prepare for rendering or any game logic here
    public func initialize(renderer: Renderer) {
        
    }
    
    ///Draw things here, happens on a seperate thread from ``update()``
    public func render(deltaTime: Float) {
        
    }
    
    ///Render method independent from ``render()``,
    ///Could be used for compute, or drawing things independent from ``render()``,
    ///For example render() could be drawing the world and this could be drawing the UI
    public func altRender(deltaTime: Float) {
        
    }
    
    ///Update Game logic here, can also be used to prepare work for ``render()``,
    ///runs on a seperate thread from ``render()``
    public func update(deltaTime: Float) {
        
    }
    
    ///Update method independent from ``update()``
    ///Keep in mind this runs on the same thread and after the Renderer
    ///Task Queue does
    public func altUpdate(deltaTime: Float) {
        
    }
}
