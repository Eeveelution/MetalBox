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
    
    var positionBuffer, normalBuffer, colorSpecularBuffer: MTLTexture?
    
    override init() {
        
    }
    
    override func getSceneDetails() -> SceneDetailsDescriptor? {
        return SceneDetailsDescriptor(name: "Main Game Scene", allowLoadingScreen: true, allowAsyncLoading: true)
    }
    
    override func initialize(renderer: Renderer) {
        self.renderer = renderer
        
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
        
        //Set up Rendertargets
        let defferedTextureDesc = MTLTextureDescriptor()
        defferedTextureDesc.pixelFormat = MTLPixelFormat.rgba16Float
        defferedTextureDesc.width = Int(renderer.view.drawableSize.width)
        defferedTextureDesc.height = Int(renderer.view.drawableSize.height)
        defferedTextureDesc.usage = [.shaderRead, .renderTarget]
        
        self.positionBuffer = renderer.device.makeTexture(descriptor: defferedTextureDesc)
        self.normalBuffer = renderer.device.makeTexture(descriptor: defferedTextureDesc)
        self.colorSpecularBuffer = renderer.device.makeTexture(descriptor: defferedTextureDesc)
        
        let timeBefore = DispatchTime.now();
        
        let boxGltf = NSDataAsset(name: "CubeModel")!.data;
        
        let importFlags =
            aiProcess_CalcTangentSpace.rawValue |
            aiProcess_Triangulate.rawValue      |
            aiProcess_GenNormals.rawValue       |
            aiProcess_GenUVCoords.rawValue      |
            aiProcess_SortByPType.rawValue      |
            aiProcess_OptimizeMeshes.rawValue   |
            aiProcess_JoinIdenticalVertices.rawValue;
        
        let pointer = UnsafeMutableRawBufferPointer.allocate(byteCount: boxGltf.count, alignment: 1);
        boxGltf.copyBytes(to: pointer);
        
        let scene = aiImportFileFromMemory(pointer.baseAddress, UInt32(boxGltf.count), UInt32(importFlags), "glb")
        if scene == nil {
            let error = NSString(utf8String: aiGetErrorString())
            print(error ?? "Fuck");
        }
        
        let timeNow = DispatchTime.now()
        
        let diff = Double(timeNow.uptimeNanoseconds - timeBefore.uptimeNanoseconds) / 1000000.0;
        
        print("Model took \(diff)ms to load.")
    }
    
    override func update(deltaTime: Float) {
        
    }
    
    override func render(in view: MTKView, deltaTime: Float) {
        let geometryPassDescriptor = MTLRenderPassDescriptor()
        
        //Position Buffer
        geometryPassDescriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
        geometryPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
        geometryPassDescriptor.colorAttachments[0].storeAction = MTLStoreAction.store
        geometryPassDescriptor.colorAttachments[0].texture = self.positionBuffer
        
        //Normal Buffer
        geometryPassDescriptor.colorAttachments[1].loadAction = MTLLoadAction.clear
        geometryPassDescriptor.colorAttachments[1].clearColor = MTLClearColorMake(0, 0, 0, 0)
        geometryPassDescriptor.colorAttachments[1].storeAction = MTLStoreAction.store
        geometryPassDescriptor.colorAttachments[1].texture = self.normalBuffer
        
        //Specular & Color Buffer
        geometryPassDescriptor.colorAttachments[2].loadAction = MTLLoadAction.clear
        geometryPassDescriptor.colorAttachments[2].clearColor = MTLClearColorMake(0, 0, 0, 0)
        geometryPassDescriptor.colorAttachments[2].storeAction = MTLStoreAction.store
        geometryPassDescriptor.colorAttachments[2].texture = self.colorSpecularBuffer
                
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
