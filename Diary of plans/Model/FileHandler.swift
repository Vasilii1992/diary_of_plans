//
//  FileHandler.swift
//  Diary of plans
//
//  Created by Василий Тихонов on 11.07.2024.
//

import Foundation

protocol FileHandlerProtocol {
    func fetch(completion: @escaping (Result<Data, Error>) -> Void)
    func write(_ data: Data, completion: @escaping (Result<Void, Error>) -> Void)
}



class FileHandler: FileHandlerProtocol {

    private var url: URL
    
    init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        url = documentsDirectory.appending(component: "todo").appendingPathExtension("plist")
        
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil)
        }
    }
    
    func fetch(completion: @escaping (Result<Data, any Error>) -> Void) {
        do {
           let data = try Data(contentsOf: url)
            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    }
    
    func write(_ data: Data, completion: @escaping (Result<Void, any Error>) -> Void) {
        do {
            try data.write(to: url)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
}
