//
//  ServiceRepository.swift
//  Diary of plans
//
//  Created by Василий Тихонов on 11.07.2024.
//

import Foundation

protocol ServiceRepositoryProtocol {
    func fetchNotes(completion: @escaping (Result<[Note], Error>) -> Void)
    func saveData(note: Note, completion: @escaping (Result<Void, Error>) -> Void)
    func removeData(note: Note, completion: @escaping (Result<Void, Error>) -> Void)
    func updateNote(_ note: Note, completion: @escaping (Result<Void, Error>) -> Void)
}


final class ServiceRepository: ServiceRepositoryProtocol {
    
    enum NoteServiceError: Error {
        case fileReadError(String)
        case fileWriteError(String)
        case noteNotFound(String)
    }
    
    private let fileHandler: FileHandler
    
    private var notesCach = [Note]()
    
    init(fileHandler: FileHandler) {
        self.fileHandler = fileHandler
    }
    
    func fetchNotes(completion: @escaping (Result<[Note], any Error>) -> Void) {
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
    
    func saveData(note: Note, completion: @escaping (Result<Void, any Error>) -> Void) {
        notesCach.append(note)
        let propertyListEncoder = PropertyListEncoder()
        guard let encodedList = try? propertyListEncoder.encode(notesCach) else {
            completion(.failure(NoteServiceError.fileWriteError("Не удалось закодировать массив заметок в директорию устройства")))
            return
        }
        
        fileHandler.write(encodedList) { result in
            completion(result)
        }
        
    }
    
    func removeData(note: Note, completion: @escaping (Result<Void, any Error>) -> Void) {
        guard let index = notesCach.firstIndex(where: { noteElement in
            noteElement == note
        }) else {
            completion(.failure(NoteServiceError.noteNotFound("Не удалось найти заметку")))
            return
        }
        notesCach.remove(at: index)
        
        let propertyListEncoder = PropertyListEncoder()
        guard let encoderList = try? propertyListEncoder.encode(notesCach) else {
            completion(.failure(NoteServiceError.fileWriteError("Не удалось закодировать данные в массив")))
            return
        }
        fileHandler.write(encoderList) { result in
            completion(result)
        }
    }
    
    func updateNote(_ noteToUpdate: Note, completion: @escaping (Result<Void, any Error>) -> Void) {
     
        guard let index = notesCach.firstIndex(where: { noteElement in
            noteElement == noteToUpdate
        }) else {
            completion(.failure(NoteServiceError.noteNotFound("Не удалось найти заметку")))
            return
        }
        notesCach[index] = noteToUpdate
        
        let propertyListEncoder = PropertyListEncoder()
        guard let encoderList = try? propertyListEncoder.encode(notesCach) else {
            completion(.failure(NoteServiceError.fileWriteError("Не удалось закодировать данные в массив")))
            return
        }
        fileHandler.write(encoderList) { result in
            completion(result)
        }
        
    }
}
