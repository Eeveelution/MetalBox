//
//  TaskQueue.swift
//  MetalBox
//
//  Created by Arkadiusz Brzoza on 13.01.23.
//

import Foundation

class TaskQueue {
    var list: [() -> Void]
    
    init() {
        self.list = []
    }
    
    func append(task: @escaping () -> Void) {
        self.list.append(task)
    }
    
    func pop() -> (() -> Void)? {
        if !self.list.isEmpty {
            return self.list.removeLast()
        }
        
        return nil
    }
    
    func hasWork() -> Bool {
        return !self.list.isEmpty
    }
}
