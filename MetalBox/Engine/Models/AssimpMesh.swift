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

class AssimpMesh {
    var verticies: [AssimpMeshVertex]
    var indicies: [UInt32]
    var assimpTextures: [aiTexture]
    
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
            
            self.processMesh(mesh: currentMesh!)
        }
        
        for i in 0 ..< node.pointee.mNumChildren{
            processNode(node: node.pointee.mChildren[ Int(i) ]!, scene: scene)
        }
    }
    
    private func processMesh(mesh: UnsafeMutablePointer<aiMesh>) {
        for i in 0 ..< mesh.pointee.mNumVertices {
            let currentVertex = mesh.pointee.mVertices[Int(i)]
            let currentNormal = mesh.pointee.mNormals[Int(i)]
            
            let aiTexCoords = mesh.pointee.mTextureCoords.0;
            //let aiColors = mesh.pointee.mColors.0;
            
            let currentTexCoords = SIMD2<Float>(aiTexCoords![Int(i)].x, aiTexCoords![Int(i)].x)
            
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
    }
    
    func createBuffersAndTextures(device: MTLDevice) {
        //TODO: maybe make a staging buffer and make data live exclusively on the GPU
        self.vertexBuffer = device.makeBuffer(bytes: &self.verticies, length: MemoryLayout<AssimpMeshVertex>.stride * self.verticies.count);
        self.indexBuffer = device.makeBuffer(bytes: &self.indicies, length: MemoryLayout<UInt32>.stride * self.indicies.count);
        
    }
}
