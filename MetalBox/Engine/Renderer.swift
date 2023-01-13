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
	
	var depthStencilState: MTLDepthStencilState
	
	var drawDeltaSnapshot: DispatchTime
	var altDrawDeltaSnapshot: DispatchTime
	var updateDeltaSnapshot: DispatchTime
	var altUpdateDeltaSnapshot: DispatchTime
	
	//Async Structures
	var drawMethodSemaphore: DispatchSemaphore
	var taskQueue: TaskQueue
	
	var updateThread: Thread?
	var altUpdateThread: Thread?
	var altDrawThread: Thread?
	
	var currentWindowSize: CGSize
	
	var currentScene: Scene
	var applicationRunning: Bool

    init?(metalKitView: MTKView) {
		self.view = metalKitView;
        self.device = metalKitView.device!
        self.commandQueue = self.device.makeCommandQueue()!
		
		self.applicationRunning = true
		
		//Configure Color and Depth Buffer
		metalKitView.depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8;
		metalKitView.colorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb;
		metalKitView.sampleCount = 1;
		
		let depthStencilDesc = MTLDepthStencilDescriptor();
		
		depthStencilDesc.depthCompareFunction = MTLCompareFunction.less;
		depthStencilDesc.isDepthWriteEnabled = true;
		
		self.depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDesc)!
		
		self.drawMethodSemaphore = DispatchSemaphore(value: 1);
		self.taskQueue = TaskQueue()
		
		self.drawDeltaSnapshot = DispatchTime.now()
		self.updateDeltaSnapshot = DispatchTime.now()
		self.altDrawDeltaSnapshot = DispatchTime.now()
		self.altUpdateDeltaSnapshot = DispatchTime.now()
		
		self.currentWindowSize = view.drawableSize
		
		self.currentScene = MainGameScene()

		self.drawCount = 0
		self.altDrawCount = 0
		
        super.init()
		
		self.updateThread = Thread(block: self.update)
		self.altUpdateThread = Thread(block: self.altUpdate)
		self.altDrawThread = Thread(block: self.altDraw)
		
		self.updateThread?.start()
		self.altUpdateThread?.start()
		self.altDrawThread?.start()
    }
	
	var drawCount: Int
	var altDrawCount: Int

    func draw(in view: MTKView) {
		//Get delta time
		let deltaTimeSnapshotNow = DispatchTime.now()
		let deltaTime = Float(deltaTimeSnapshotNow.uptimeNanoseconds - self.drawDeltaSnapshot.uptimeNanoseconds) / 1000000000.0
		self.drawDeltaSnapshot = deltaTimeSnapshotNow
		
		self.currentScene.render(deltaTime: deltaTime)
		drawCount += 1
		
		self.drawMethodSemaphore.signal()
    }
	
	func altDraw() {
		while self.applicationRunning {
			//Get delta time
			let deltaTimeSnapshotNow = DispatchTime.now()
			let deltaTime = Float(deltaTimeSnapshotNow.uptimeNanoseconds - self.altDrawDeltaSnapshot.uptimeNanoseconds) / 1000000000.0
			self.altDrawDeltaSnapshot = deltaTimeSnapshotNow
			
			self.currentScene.render(deltaTime: deltaTime)
			
			altDrawCount += 1
			
			self.drawMethodSemaphore.wait()
		}
	}
	
	func update() {
		while self.applicationRunning {
			let deltaTimeSnapshotNow = DispatchTime.now()
			let deltaTime = Float(deltaTimeSnapshotNow.uptimeNanoseconds - self.updateDeltaSnapshot.uptimeNanoseconds) / 1000000000.0
			
			self.currentScene.update(deltaTime: deltaTime)
			
			self.updateDeltaSnapshot = deltaTimeSnapshotNow
		}
	}
	
	func altUpdate() {
		while self.applicationRunning {
			while self.taskQueue.hasWork() {
				let item = self.taskQueue.pop()
				item!()
			}
			
			let deltaTimeSnapshotNow = DispatchTime.now()
			let deltaTime = Float(deltaTimeSnapshotNow.uptimeNanoseconds - self.altUpdateDeltaSnapshot.uptimeNanoseconds) / 1000000000.0
			
			self.altUpdateDeltaSnapshot = deltaTimeSnapshotNow
			
			self.currentScene.altUpdate(deltaTime: deltaTime)
		}
	}

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        /// Respond to drawable size or orientation changes here
		self.currentWindowSize = size
		
		print(size)
    }
}
