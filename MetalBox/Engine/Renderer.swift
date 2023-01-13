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
	var mainRenderTarget: MTLTexture?
	
	//Async Structures
	var renderTargetSemaphore: DispatchSemaphore
	var taskQueue: DispatchQueue
	
	//Triangle Related
	var trianglePipeline: MTLRenderPipelineState?
	var planeMesh: MTKMesh?
	var colorBuffer: [SIMD4<Float16>]?
	var vertexBuffer: [SIMD3<Float>]?
	var colorBufferPointer: UnsafeRawPointer?
	var vertexBufferPointer: UnsafeRawPointer?

    init?(metalKitView: MTKView) {
		self.view = metalKitView;
        self.device = metalKitView.device!
        self.commandQueue = self.device.makeCommandQueue()!
		
		//Configure Color and Depth Buffer
		//metalKitView.depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8;
		metalKitView.colorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb;
		
		//Configure sample count
		var sampleCount: Int = 1;
		
		//Check which is supported
		//for i in 4...1 {
		//	if self.device.supportsTextureSampleCount(i) {
		//		sampleCount = i;
		//		break;
		//	}
		//}
		
		metalKitView.sampleCount = sampleCount;
		
		let depthStencilDesc = MTLDepthStencilDescriptor();
		
		depthStencilDesc.depthCompareFunction = MTLCompareFunction.less;
		depthStencilDesc.isDepthWriteEnabled = true;
		
		self.depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDesc)!
		
		self.renderTargetSemaphore = DispatchSemaphore(value: 0);
		self.taskQueue = DispatchQueue(label: "async render task queue")

        super.init()
		
		self.recreateAndResizeRenderTarget(size: metalKitView.drawableSize)
		self.createTrianglePipeline()
		
		self.colorBuffer = []
		self.vertexBuffer = []
		
		self.colorBuffer!.append(SIMD4<Float16>(1.0, 0.0, 0.0, 1.0))
		self.colorBuffer!.append(SIMD4<Float16>(0.0, 1.0, 0.0, 1.0))
		self.colorBuffer!.append(SIMD4<Float16>(0.0, 0.0, 1.0, 1.0))
		
		self.vertexBuffer!.append(SIMD3<Float>(0.0, 0.0, 0.0))
		self.vertexBuffer!.append(SIMD3<Float>(1.0, 0.0, 0.0))
		self.vertexBuffer!.append(SIMD3<Float>(0.5, 1.0, 0.0))
		
		self.colorBufferPointer = UnsafeRawPointer(self.colorBuffer)
		self.vertexBufferPointer = UnsafeRawPointer(self.vertexBuffer)
    }
	
	func recreateAndResizeRenderTarget(size: CGSize) {
		let textureDescriptor = MTLTextureDescriptor();
		
		textureDescriptor.width = Int(size.width);
		textureDescriptor.height = Int(size.height);
		textureDescriptor.pixelFormat = MTLPixelFormat.bgra8Unorm_srgb;
		textureDescriptor.usage = MTLTextureUsage( rawValue: (
			MTLTextureUsage.renderTarget.rawValue |
			MTLTextureUsage.shaderRead.rawValue
		));
		
		self.mainRenderTarget = device.makeTexture(descriptor: textureDescriptor)!
	}
	
	func createTrianglePipeline() {
		let defaultLibrary = device.makeDefaultLibrary()
		let pipelineDescriptor = MTLRenderPipelineDescriptor()
		
		pipelineDescriptor.label = "Triangle Pipeline"
		
		let triangleLayout = self.createBufferLayout()
		
		pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm_srgb;
		pipelineDescriptor.vertexFunction = defaultLibrary?.makeFunction(name: "triangleVertexShader")
		pipelineDescriptor.fragmentFunction = defaultLibrary?.makeFunction(name: "trianglePixelShader")
		pipelineDescriptor.vertexDescriptor = triangleLayout;
		
		let renderPipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
		
		self.trianglePipeline = renderPipelineState
	}
	
	func createBufferLayout() -> MTLVertexDescriptor {
		//Input layout
		let vertexDescriptor = MTLVertexDescriptor()
		
		vertexDescriptor.attributes[0].format = MTLVertexFormat.float3;
		vertexDescriptor.attributes[0].offset = 0;
		vertexDescriptor.attributes[0].bufferIndex = 0;
		
		vertexDescriptor.attributes[1].format = MTLVertexFormat.half4;
		vertexDescriptor.attributes[1].offset = 0;
		vertexDescriptor.attributes[1].bufferIndex = 1;
		
		vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride;
		vertexDescriptor.layouts[0].stepRate = 1;
		vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunction.perVertex;
		
		vertexDescriptor.layouts[1].stride = 8;
		vertexDescriptor.layouts[1].stepRate = 1;
		vertexDescriptor.layouts[1].stepFunction = MTLVertexStepFunction.perVertex;
		
		return vertexDescriptor;
	}

    func draw(in view: MTKView) {
        //let renderPassDescriptor = MTLRenderPassDescriptor()
		//
		//renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadAction.clear;
		//renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
		//renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreAction.store;
		//renderPassDescriptor.colorAttachments[0].texture = self.mainRenderTarget
		
		if let commandBuffer = self.commandQueue.makeCommandBuffer() {
			if let renderPassDesc = view.currentRenderPassDescriptor {
				if let renderPassEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc) {
					renderPassEncoder.label = "Triangle Render Pass"
					
					renderPassEncoder.setCullMode(MTLCullMode.back)
					renderPassEncoder.setFrontFacing(MTLWinding.counterClockwise)
					renderPassEncoder.setRenderPipelineState(self.trianglePipeline!)
					
					renderPassEncoder.setVertexBytes(self.vertexBufferPointer!, length: MemoryLayout<SIMD3<Float>>.size * 3, index: 0)
					renderPassEncoder.setVertexBytes(self.colorBufferPointer!, length: MemoryLayout<SIMD4<Float16>>.size * 3, index: 1)
					
					renderPassEncoder.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: 3)
					
					renderPassEncoder.endEncoding()
					
					if let drawable = view.currentDrawable {
						commandBuffer.present(drawable)
					}
				}
			}
			
			commandBuffer.commit()
		}
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        /// Respond to drawable size or orientation changes here
    }
}
