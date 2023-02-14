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

struct ConstantBufferStruct {
    let viewProjectionMatrix: simd_float4x4
}

class MainGameScene: Scene {
    var renderer: Renderer?
    var perspectiveCamera: PerspectiveCamera?
    
    var constantBuffer: MTLBuffer?
    var constantBufferData: ConstantBufferStruct?
    
    var meshPipeline: MTLRenderPipelineState?
    var assimpMesh: AssimpMesh?
    
    var positionBuffer, normalBuffer, colorSpecularBuffer: MTLTexture?
    
    override init() {
        
    }
    
    override func getSceneDetails() -> SceneDetailsDescriptor? {
        return SceneDetailsDescriptor(name: "Main Game Scene", allowLoadingScreen: true, allowAsyncLoading: true)
    }
    
    override func initialize(renderer: Renderer) {
        self.renderer = renderer
        self.perspectiveCamera = PerspectiveCamera()
        //self.perspectiveCamera!.position = SIMD4<Float>(75, 1, -1, 1);
        //self.perspectiveCamera!.pitch = -1.5
        self.perspectiveCamera!.setPosition(simd_float3(-100, 50, 0));
        //self.perspectiveCamera!.pitch = -1.5
        
        let meshVertexDescriptor = MTLVertexDescriptor()
        
        //Position
        meshVertexDescriptor.attributes[0].bufferIndex = 0
        meshVertexDescriptor.attributes[0].offset = 0
        meshVertexDescriptor.attributes[0].format = MTLVertexFormat.float3
        
        //Normal
        meshVertexDescriptor.attributes[1].bufferIndex = 0
        meshVertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.size
        meshVertexDescriptor.attributes[1].format = MTLVertexFormat.float3
        
        //TexCoord
        meshVertexDescriptor.attributes[2].bufferIndex = 0
        meshVertexDescriptor.attributes[2].offset = MemoryLayout<SIMD3<Float>>.size * 2
        meshVertexDescriptor.attributes[2].format = MTLVertexFormat.float2
        
        //Buffer layout
        meshVertexDescriptor.layouts[0].stride = MemoryLayout<AssimpMeshVertex>.stride
        meshVertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunction.perVertex
        meshVertexDescriptor.layouts[0].stepRate = 1
        
        //Create Pipeline
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        pipelineDescriptor.vertexDescriptor = meshVertexDescriptor
        pipelineDescriptor.vertexFunction = renderer.defaultLibrary?.makeFunction(name: "assimpSimpleVertexShader")
        pipelineDescriptor.fragmentFunction = renderer.defaultLibrary?.makeFunction(name: "assimpSimpleFragmentShader")
        pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormat.depth32Float_stencil8
        pipelineDescriptor.stencilAttachmentPixelFormat = MTLPixelFormat.depth32Float_stencil8
        pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm
        
        self.meshPipeline = try! renderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        //Set up Rendertargets
        //let defferedTextureDesc = MTLTextureDescriptor()
        //defferedTextureDesc.pixelFormat = MTLPixelFormat.rgba16Float
        //defferedTextureDesc.width = Int(renderer.view.drawableSize.width)
        //defferedTextureDesc.height = Int(renderer.view.drawableSize.height)
        //defferedTextureDesc.usage = [.shaderRead, .renderTarget]
        
        //self.positionBuffer = renderer.device.makeTexture(descriptor: defferedTextureDesc)
        //self.normalBuffer = renderer.device.makeTexture(descriptor: defferedTextureDesc)
        //self.colorSpecularBuffer = renderer.device.makeTexture(descriptor: defferedTextureDesc)
        
        let timeBefore = DispatchTime.now();
        
        let boxGltf = NSDataAsset(name: "CubeModel")!.data;
        
        let importFlags =
            aiProcess_CalcTangentSpace.rawValue       |
            aiProcess_Triangulate.rawValue            |
            aiProcess_GenNormals.rawValue             |
            aiProcess_GenUVCoords.rawValue            |
            aiProcess_SortByPType.rawValue            |
            aiProcess_OptimizeMeshes.rawValue         |
            aiProcess_PreTransformVertices.rawValue   |
            aiProcess_MakeLeftHanded.rawValue         |
            aiProcess_FlipUVs.rawValue                |
            aiProcess_JoinIdenticalVertices.rawValue;
        
        let pointer = UnsafeMutableRawBufferPointer.allocate(byteCount: boxGltf.count, alignment: 1);
        boxGltf.copyBytes(to: pointer);
        
        let scene = aiImportFileFromMemory(pointer.baseAddress, UInt32(boxGltf.count), UInt32(importFlags), "glb")
        if scene == nil {
            let error = NSString(utf8String: aiGetErrorString())
            print(error ?? "Fuck");
        }
        
        self.assimpMesh = AssimpMesh(node: scene!.pointee.mRootNode, scene: scene!)
        self.assimpMesh!.createBuffersAndTextures(device: self.renderer!.device)
        
        let timeNow = DispatchTime.now()
        let diff = Double(timeNow.uptimeNanoseconds - timeBefore.uptimeNanoseconds) / 1000000.0;
        
        print("Model took \(diff)ms to load and create on the device.")
        
        self.constantBufferData = ConstantBufferStruct(viewProjectionMatrix: self.perspectiveCamera!.getViewMatrix())
        self.constantBuffer = self.renderer!.device.makeBuffer(length: MemoryLayout<ConstantBufferStruct>.size)
    }
    
    var fuck: Float = 0
    
    override func update(deltaTime: Float) {
        //self.perspectiveCamera!.position = SIMD4<Float>(0, 0, 0, 1);
        //self.perspectiveCamera!.setYaw( fuck * 10 )
        ///self.perspectiveCamera!.setPosition(simd_float3( -100,  50,  0));
        
        fuck += deltaTime;
        
        self.constantBufferData = ConstantBufferStruct(
            viewProjectionMatrix: self.perspectiveCamera!.getViewMatrix()
        )
        
        if InputManager.isKeyHeld(KeyCodes.w) {
            self.perspectiveCamera!.processKeyboardMovement(.Forward, deltaTime: deltaTime)
            self.perspectiveCamera!.printPosition()
        }
        
        if InputManager.isKeyHeld(KeyCodes.s) {
            self.perspectiveCamera!.processKeyboardMovement(.Backward, deltaTime: deltaTime)
            self.perspectiveCamera!.printPosition()
        }
        
        if InputManager.isKeyHeld(KeyCodes.a) {
            self.perspectiveCamera!.processKeyboardMovement(.Left, deltaTime: deltaTime)
            self.perspectiveCamera!.printPosition()
        }
        
        if InputManager.isKeyHeld(KeyCodes.d) {
            self.perspectiveCamera!.processKeyboardMovement(.Right, deltaTime: deltaTime)
            self.perspectiveCamera!.printPosition()
        }
    }
    
    override func render(in view: MTKView, deltaTime: Float) {
        //let geometryPassDescriptor = MTLRenderPassDescriptor()
        //
        //Position Buffer
        //geometryPassDescriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
        //geometryPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
        //geometryPassDescriptor.colorAttachments[0].storeAction = MTLStoreAction.store
        //geometryPassDescriptor.colorAttachments[0].texture = self.positionBuffer
        //
        //Normal Buffer
        //geometryPassDescriptor.colorAttachments[1].loadAction = MTLLoadAction.clear
        //geometryPassDescriptor.colorAttachments[1].clearColor = MTLClearColorMake(0, 0, 0, 0)
        //geometryPassDescriptor.colorAttachments[1].storeAction = MTLStoreAction.store
        //geometryPassDescriptor.colorAttachments[1].texture = self.normalBuffer
        //
        //Specular & Color Buffer
        //geometryPassDescriptor.colorAttachments[2].loadAction = MTLLoadAction.clear
        //geometryPassDescriptor.colorAttachments[2].clearColor = MTLClearColorMake(0, 0, 0, 0)
        //geometryPassDescriptor.colorAttachments[2].storeAction = MTLStoreAction.store
        //geometryPassDescriptor.colorAttachments[2].texture = self.colorSpecularBuffer
        
        self.constantBuffer!
            .contents()
            .copyMemory(from: &self.constantBufferData, byteCount: MemoryLayout<ConstantBufferStruct>.size)
                
        if let commandBuffer = self.renderer!.commandQueue.makeCommandBuffer() {
            if let renderPassDescription = view.currentRenderPassDescriptor {
                renderPassDescription.depthAttachment.storeAction = MTLStoreAction.store
                renderPassDescription.depthAttachment.loadAction = MTLLoadAction.clear
                renderPassDescription.stencilAttachment.storeAction = MTLStoreAction.store
                renderPassDescription.stencilAttachment.loadAction = MTLLoadAction.clear
                
                if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescription) {
                    renderEncoder.setCullMode(MTLCullMode.back)
                    renderEncoder.setFrontFacing(MTLWinding.counterClockwise)
                    renderEncoder.setDepthStencilState(renderer!.depthStencilState)
                    renderEncoder.setRenderPipelineState(self.meshPipeline!)
        
                    renderEncoder.setViewport(
                        MTLViewport(
                            originX: 0,
                            originY: 0,
                            width: self.renderer!.view.drawableSize.width,
                            height: self.renderer!.view.drawableSize.height,
                            znear: 0.0001,
                            zfar: 1
                        )
                    )
                    
                    renderEncoder.setVertexBuffer(self.assimpMesh?.vertexBuffer, offset: 0, index: 0)
                    renderEncoder.setVertexBuffer(self.constantBuffer, offset: 0, index: 1)
                    renderEncoder.setFragmentTexture(self.assimpMesh?.textures?.first, index: 0)
                    
                    renderEncoder.drawIndexedPrimitives(type: MTLPrimitiveType.triangle, indexCount: self.assimpMesh!.indicies.count, indexType: MTLIndexType.uint32, indexBuffer: self.assimpMesh!.indexBuffer!, indexBufferOffset: 0)
                    //renderEncoder.drawIndexedPrimitives(type: MTLPrimitiveType.triangle, indexCount: self.assimpMesh!.indicies.count, indexType: MTLIndexType.uint32, indexBuffer: self.assimpMesh!.indexBuffer!, indexBufferOffset: 0)
                    
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
