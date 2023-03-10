//
//  AssimpMesh.swift
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 23.01.23.
//

import Foundation
import Metal
import MetalKit

struct AssimpMeshVertex {
    let position: SIMD3<Float>
    let normal: SIMD3<Float>
    let texCoords: SIMD2<Float>
}

struct AssimpMeshTexture {
    let width: UInt32
    let height: UInt32
    let bufferPointer: UnsafeMutablePointer<UInt8>
    // As opposed to ARGB
    let rgba: Bool
}

class AssimpMesh {
    var verticies: [AssimpMeshVertex]
    var indicies: [UInt32]
    var assimpTextures: [AssimpMeshTexture]
    
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    var textures: [MTLTexture]?
    
    init(node: UnsafePointer<aiNode>, scene: UnsafePointer<aiScene>) {
        verticies = []
        assimpTextures = []
        textures = []
        indicies = []
        
        self.processNode(node: node, scene: scene);
    }
    
    private func processNode(node: UnsafePointer<aiNode>, scene: UnsafePointer<aiScene>) {
        for i in 0 ..< node.pointee.mNumMeshes {
            let currentMesh = scene.pointee.mMeshes[ Int( node.pointee.mMeshes[Int(i)] ) ]
            
            self.processMesh(mesh: currentMesh!, scene: scene)
        }
        
        for i in 0 ..< node.pointee.mNumChildren{
            processNode(node: node.pointee.mChildren[ Int(i) ]!, scene: scene)
        }
    }
    
    private func processMesh(mesh: UnsafeMutablePointer<aiMesh>, scene: UnsafePointer<aiScene>) {
        for i in 0 ..< mesh.pointee.mNumVertices {
            let currentVertex = mesh.pointee.mVertices[Int(i)]
            let currentNormal = mesh.pointee.mNormals[Int(i)]
            
            let aiTexCoords = mesh.pointee.mTextureCoords.0;
            
            //let aiColors = mesh.pointee.mColors.0;
            
            let currentTexCoords = SIMD2<Float>(aiTexCoords![Int(i)].x, aiTexCoords![Int(i)].y)
            
            verticies.append(
                AssimpMeshVertex(
                    position: SIMD3<Float>(currentVertex.x, currentVertex.y, currentVertex.z),
                    normal: SIMD3<Float>(currentNormal.x, currentNormal.y, currentNormal.z),
                    texCoords: SIMD2<Float>(currentTexCoords.x, currentTexCoords.y)
                )
            )
        }
        
        for i in 0 ..< mesh.pointee.mNumFaces {
            let currentFace = mesh.pointee.mFaces[ Int(i) ]
            
            for j in 0 ..< currentFace.mNumIndices {
                let currentIndex = currentFace.mIndices[ Int(j) ]
                indicies.append(currentIndex)
            }
        }
        
        if mesh.pointee.mMaterialIndex >= 0 {
            let material = scene.pointee.mMaterials[ Int(mesh.pointee.mMaterialIndex) ];
            
            let texCount = aiGetMaterialTextureCount(material, aiTextureType_DIFFUSE)
            
            for i in 0 ..< texCount {
                var string: aiString = aiString();
                var mapping: aiTextureMapping = aiTextureMapping(0);
                var uvIndex: UInt32 = 0;
                var blend: ai_real = 0;
                var textureOp: aiTextureOp = aiTextureOp(0);
                var mapMode: aiTextureMapMode = aiTextureMapMode(0);
                var flags: UInt32 = 0;
                
                let textureIndex = aiGetMaterialTexture(material, aiTextureType_DIFFUSE, i, &string, &mapping, &uvIndex, &blend, &textureOp, &mapMode, &flags)
                let texture = scene.pointee.mTextures[ Int(textureIndex.rawValue) ]
                
                if texture == nil {
                    continue;
                }
                
                if texture?.pointee.mHeight == 0 && texture?.pointee.mWidth != 0 {
                    var width: UInt32 = 0
                    var height: UInt32 = 0
                    var channels: UInt32 = 0
                    
                    let textureData = STBIImageLoader.loadData(texture!.pointee.pcData, dataSize: texture!.pointee.mWidth, widthPtr: &width, heightPtr: &height, channelPtr: &channels, desiredChannels: 4)
                    
                    self.assimpTextures.append(
                        AssimpMeshTexture(
                            width: width,
                            height: height,
                            bufferPointer: textureData!,
                            rgba: true
                        )
                    )
                    
                } else {
                    texture!.pointee.pcData.withMemoryRebound(
                        to: UInt8.self,
                        capacity: Int(texture!.pointee.mWidth * texture!.pointee.mHeight) * 4,
                        {
                            self.assimpTextures.append(
                                AssimpMeshTexture(
                                    width: texture!.pointee.mWidth,
                                    height: texture!.pointee.mHeight,
                                    bufferPointer: $0,
                                    rgba: false
                                )
                            )
                        }
                    )
                }
            }
        }
    }
    
    func createBuffersAndTextures(device: MTLDevice) {
        //TODO: maybe make a staging buffer and make data live exclusively on the GPU
        
        self.vertexBuffer = device.makeBuffer(bytes: &self.verticies, length: MemoryLayout<AssimpMeshVertex>.stride * self.verticies.count);
        self.indexBuffer = device.makeBuffer(bytes: &self.indicies, length: MemoryLayout<UInt32>.stride * self.indicies.count);
        
        for value in self.assimpTextures {
            let textureDescriptor = MTLTextureDescriptor()
            
            textureDescriptor.width = Int(value.width)
            textureDescriptor.height = Int(value.height)
            textureDescriptor.usage = [.shaderRead]
            
            if value.rgba {
                textureDescriptor.pixelFormat = MTLPixelFormat.rgba8Unorm
            } else {
                textureDescriptor.pixelFormat = MTLPixelFormat.bgra8Unorm
            }
            
            let deviceTexture = device.makeTexture(descriptor: textureDescriptor)
            
            if deviceTexture == nil {
                return
            }
            
            deviceTexture!.replace(
                region:
                    MTLRegionMake3D(0, 0, 0,
                                    textureDescriptor.width,
                                    textureDescriptor.height,
                                    1),
                mipmapLevel: 0,
                withBytes: value.bufferPointer,
                bytesPerRow: 4 * textureDescriptor.width
            )
            
            self.textures!.append(deviceTexture!)
        }
    }
}
