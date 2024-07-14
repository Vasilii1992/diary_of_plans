//
//  ServiceRepository.swift
//  Diary of plans
//
//  Created by Василий Тихонов on 11.07.2024.
//

import Foundation

protocol ServiceRepositoryProtocol {
    typealias FetchNotesCompletion = (Result<[Note], Error>) -> Void
    typealias OperationCompletion  = (Result<Void, Error>) -> Void
    
    func fetchNotes(completion: @escaping FetchNotesCompletion )
    func saveData(note: Note, completion: @escaping OperationCompletion )
    func removeData(note: Note, completion: @escaping OperationCompletion )
    func updateNote(_ note: Note, completion: @escaping OperationCompletion )
}

enum NoteServiceError: Error {
    case fileReadError(String)
    case fileWriteError(String)
    case noteNotFound(String)
}

final class ServiceRepository: ServiceRepositoryProtocol {
    
    private let fileHandler: FileHandler
    
    private var notesCach = [Note]()
    
    init(fileHandler: FileHandler) {
        self.fileHandler = fileHandler
    }
    
    func fetchNotes(completion: @escaping FetchNotesCompletion) {
        !notesCach.isEmpty ? completion(.success(notesCach)) : nil
        
        fileHandler.fetch { result in
            switch result {
            case .success(let dataContent):
                guard !dataContent.isEmpty else {
                    print("Файл пуст")
                    completion(.success([]))
                    return
                }
                let propertyListDecoder = PropertyListDecoder()
                guard let notes = try? propertyListDecoder.decode([Note].self, from: dataContent) else {
                    completion(.failure(NoteServiceError.fileReadError("Не удалось декодировать данные в массив заметок")))
                    return
                }
                self.notesCach = notes
                completion(.success(notes))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func saveData(note: Note, completion: @escaping OperationCompletion) {
        notesCach.append(note)
        switch fileHandler.encodeNotes(notesCach) {
            
        case .success(let data):
            fileHandler.write(data, completion: completion)
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    func removeData(note: Note, completion: @escaping OperationCompletion) {
        guard let index = notesCach.firstIndex(where: { noteElement in
            noteElement == note
        }) else {
            completion(.failure(NoteServiceError.noteNotFound("Не удалось найти заметку")))
            return
        }
        notesCach.remove(at: index)
        
        switch fileHandler.encodeNotes(notesCach) {
            
        case .success(let data):
            fileHandler.write(data, completion: completion)
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    func updateNote(_ noteToUpdate: Note, completion: @escaping OperationCompletion) {
        
        guard let index = notesCach.firstIndex(where: { noteElement in
            noteElement == noteToUpdate
        }) else {
            completion(.failure(NoteServiceError.noteNotFound("Не удалось найти заметку")))
            return
        }
        notesCach[index] = noteToUpdate
        
        switch fileHandler.encodeNotes(notesCach) {
            
        case .success(let data):
            fileHandler.write(data, completion: completion)
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
