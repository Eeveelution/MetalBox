//
//  MainGameScene.swift
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 13.01.23.
//

import Foundation
import Metal
import MetalKit
import simd

struct VertexBufferStruct {
    let position: SIMD3<Float>;
    let color: SIMD4<Float16>;
}

class MainGameScene: Scene {
    var renderer: Renderer?
    
    var vertexBuffer: MTLBuffer?
    var vertexBufferDescriptor: MTLVertexDescriptor?
    var trianglePipeline: MTLRenderPipelineState?
    
    override init() {
        
    }
    
    override func getSceneDetails() -> SceneDetailsDescriptor? {
        return SceneDetailsDescriptor(name: "Main Game Scene", allowLoadingScreen: true, allowAsyncLoading: true)
    }
    
    override func initialize(renderer: Renderer) {
        self.renderer = renderer
        
        var gltfModel = GLTFModel(data: nil, dataSize: 0)
        var a: GLTFBuffer = gltfModel?.retrieveBuffers()[0] as! GLTFBuffer
        
        var vertices: [VertexBufferStruct] = [];
        
        vertices.append(
            VertexBufferStruct(position: SIMD3<Float>(0, 0.0, 0), color: SIMD4<Float16>(1.0, 0.0, 0.0, 1.0))
        )
        vertices.append(
            VertexBufferStruct(position: SIMD3<Float>( 1, 0, 0), color: SIMD4<Float16>(0.0, 1.0, 0.0, 1.0))
        )
        vertices.append(
            VertexBufferStruct(position: SIMD3<Float>( 0.5, 1.0, 0), color: SIMD4<Float16>(0.0, 0.0, 1.0, 1.0))
        )
        
        self.vertexBuffer = renderer.device.makeBuffer(bytes: &vertices, length: MemoryLayout<VertexBufferStruct>.stride * vertices.count)
        
        if self.vertexBuffer == nil {
            print("Failed to create Vertex Buffer!")
            exit(-1)
        }
        
        //Create Vertex Layout
        let vertexDescriptor = MTLVertexDescriptor()
        
        //Position
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = MTLVertexFormat.float3
    
        //Color
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.size
        vertexDescriptor.attributes[1].format = MTLVertexFormat.half4
        
        //Buffer layout
        vertexDescriptor.layouts[0].stride = MemoryLayout<VertexBufferStruct>.stride
        vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunction.perVertex
        vertexDescriptor.layouts[0].stepRate = 1
        
        self.vertexBufferDescriptor = vertexDescriptor
        
        //Create Pipeline
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        pipelineDescriptor.vertexDescriptor = self.vertexBufferDescriptor
        pipelineDescriptor.vertexFunction = renderer.defaultLibrary?.makeFunction(name: "triangleVertexShader")
        pipelineDescriptor.fragmentFunction = renderer.defaultLibrary?.makeFunction(name: "trianglePixelShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm_srgb
        pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormat.depth32Float
        
        self.trianglePipeline = try! renderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    override func update(deltaTime: Float) {
        
    }
    
    override func render(in view: MTKView, deltaTime: Float) {
        if let commandBuffer = self.renderer!.commandQueue.makeCommandBuffer() {
            if let renderPassDescription = view.currentRenderPassDescriptor {
                if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescription) {
                    renderEncoder.setCullMode(MTLCullMode.back)
                    renderEncoder.setFrontFacing(MTLWinding.counterClockwise)
                    renderEncoder.setDepthStencilState(renderer!.depthStencilState)
                    renderEncoder.setRenderPipelineState(self.trianglePipeline!)
                    
                    renderEncoder.setVertexBuffer(self.vertexBuffer!, offset: 0, index: 0)
                    
                    renderEncoder.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: 3)
                    
                    renderEncoder.endEncoding()
                    
                    if let drawable = view.currentDrawable {
                        commandBuffer.present(drawable)
                    }
                }
            }
            
            commandBuffer.commit()
        }
    }
}
