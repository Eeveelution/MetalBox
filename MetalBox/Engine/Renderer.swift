//
//  Renderer.swift
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 12.01.23.
//

// Our platform independent renderer class

import Metal
import MetalKit
import simd

enum RendererErrors: Error {
	case badVertexDescriptor
}

class Renderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
	let view: MTKView
    let commandQueue: MTLCommandQueue
	
	//Resources
	var defaultLibrary: MTLLibrary?
	
	var depthStencilState: MTLDepthStencilState
	
	var drawDeltaSnapshot: DispatchTime
	var updateDeltaSnapshot: DispatchTime
	
	//Async Structures
	var taskQueue: TaskQueue
	
	var updateThread: Thread?
	var altDrawThread: Thread?
	
	var currentWindowSize: CGSize
	
	var currentScene: Scene?
	var applicationRunning: Bool

    init?(metalKitView: MTKView) {
		self.view = metalKitView;
        self.device = metalKitView.device!
        self.commandQueue = self.device.makeCommandQueue()!
		self.defaultLibrary = self.device.makeDefaultLibrary()
		
		self.applicationRunning = true
		
		//Configure Color and Depth Buffer
		metalKitView.depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8;
		metalKitView.colorPixelFormat = MTLPixelFormat.bgra8Unorm;
		metalKitView.sampleCount = 1;
		
		let depthStencilDesc = MTLDepthStencilDescriptor();
		
		depthStencilDesc.depthCompareFunction = MTLCompareFunction.less;
		depthStencilDesc.isDepthWriteEnabled = true;
		
		self.depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDesc)!
		
		self.taskQueue = TaskQueue()
		
		self.drawDeltaSnapshot = DispatchTime.now()
		self.updateDeltaSnapshot = DispatchTime.now()
		
		self.currentWindowSize = view.drawableSize

		self.drawCount = 0
		self.altDrawCount = 0
		
        super.init()
		
		self.currentScene = MainGameScene()
		self.currentScene!.initialize(renderer: self)
		
		self.updateThread = Thread(block: self.update)
		self.updateThread?.start()
    }
	
	var drawCount: Int
	var altDrawCount: Int

    func draw(in view: MTKView) {
		//Get delta time
		let deltaTimeSnapshotNow = DispatchTime.now()
		let deltaTime = Float(deltaTimeSnapshotNow.uptimeNanoseconds - self.drawDeltaSnapshot.uptimeNanoseconds) / 1000000000.0
		self.drawDeltaSnapshot = deltaTimeSnapshotNow
		
		self.currentScene!.render(in: view, deltaTime: deltaTime)
		drawCount += 1
    }
	
	func update() {
		while self.applicationRunning {
			while self.taskQueue.hasWork() {
				let item = self.taskQueue.pop()
				item!()
			}
			
			let deltaTimeSnapshotNow = DispatchTime.now()
			let deltaTime = Float(deltaTimeSnapshotNow.uptimeNanoseconds - self.updateDeltaSnapshot.uptimeNanoseconds) / 1000000000.0
			
			self.updateDeltaSnapshot = deltaTimeSnapshotNow
			
			self.currentScene!.update(deltaTime: deltaTime)
		}
	}

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        /// Respond to drawable size or orientation changes here
		self.currentWindowSize = size
		
		print(size)
    }
}
