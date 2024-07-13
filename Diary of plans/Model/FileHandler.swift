//
//  FileHandler.swift
//  Diary of plans
//
//  Created by Василий Тихонов on 11.07.2024.
//

import Foundation

protocol FileHandlerProtocol {
    typealias FetchCompletion = (Result<Data, Error>) -> Void
    typealias WriteCompletion = (Result<Void, Error>) -> Void
    typealias Encoderesult = Result<Data, Error>
    
    func fetch(completion: @escaping FetchCompletion)
    func write(_ data: Data, completion: @escaping WriteCompletion)
    func encodeNotes(_ notes: [Note]) -> Encoderesult 
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
    
    func fetch(completion: @escaping FetchCompletion) {
        do {
           let data = try Data(contentsOf: url)
            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    }
    
    func write(_ data: Data, completion: @escaping WriteCompletion) {
        do {
            try data.write(to: url)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func encodeNotes(_ notes: [Note]) -> Encoderesult {
        
        let propertyListEncoder = PropertyListEncoder()
        if let encodedList = try? propertyListEncoder.encode(notes) {
            return .success(encodedList)
        } else {
            return.failure(NoteServiceError.fileWriteError("Не удалось закодировать массив заметок в тип Data"))
        }
        
        
        
    }
    
}
