//
//  Note.swift
//  Diary of plans
//
//  Created by Василий Тихонов on 11.07.2024.
//

import Foundation

struct Note: Codable, Identifiable, Equatable {
    
    var id = UUID()
    var title: String
    var isComplete: Bool
    var date: Date
    var notes: String
  // должны реализовать для протокола Equatable
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}


/*
 Ты IOS разработчик.У нас есть часть кода для приложение Заметок. Нужно дописать код, отобразить таблицу на экране, сделать так чтобы в верхнем правом углу была кнопка для добавления заметки, и чтобы заметку можно было удалять из таблицы и помечать как завершенную (isComplete).
 
 You are an iOS developer.We have a piece of code for the Notes app. You need to add the code, display the table on the screen, make sure that there is a button in the upper right corner to add a note, and that the note can be deleted from the table and marked as completed (isComplete).
 
 Here is the code:
 
 import Foundation
 import UIKit
 
 protocol NoteViewProtocol: AnyObject {
     func showError(title: String, message: String)
     func showLoading()
     func hideLoading()
     func loadRow(at index: Int)
     func reloadData()
     func didInsertRow(at index: Int)
     func didDeleteRow(at index: Int)
 }



 class NoteViewController: UIViewController {

     override func viewDidLoad() {
         super.viewDidLoad()
     }


 }
 
 
 

 struct Note: Codable, Identifiable, Equatable {
     
     var id = UUID()
     var title: String
     var isComplete: Bool
     var date: Date
     var notes: String
 
     static func == (lhs: Self, rhs: Self) -> Bool {
         lhs.id == rhs.id
     }
 }
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
 protocol NotePresenterProtocol {
     
     func loadAndUpdateDisplayData()
     func addNote(note: Note)
     func deleteNote(at index: Int)
     func numberOfNotes() -> Int
     func noteAt(index: Int) -> Note
     func getImage(for isComplete: Bool) -> String
     func isToggleNote(for index: Int)
 }

 class NotePresenter: NotePresenterProtocol {
     
     private weak var view: NoteViewProtocol?
     private var dataRepository: ServiceRepositoryProtocol
     private var notes: [Note] = []
     
     init(view: NoteViewProtocol, dataRepository: ServiceRepositoryProtocol) {
         self.view = view
         self.dataRepository = dataRepository
     }
     
     func loadAndUpdateDisplayData() {
         view?.showLoading()
         dataRepository.fetchNotes { [weak self] result in
             switch result {
             case .success(let notesData):
                 self?.notes = notesData.sorted(by: {$0.date > $1.date })
                 self?.view?.reloadData()
                 self?.view?.hideLoading()
             case .failure(let error):
                 self?.view?.showError(title: "Ошибка", message: error.localizedDescription)
                 self?.view?.hideLoading()
             }
         }
     }
     
     func addNote(note: Note) {
         view?.showLoading()
         dataRepository.saveData(note: note) { [weak self] result in
             switch result {
             case .success():
                 self?.notes = self?.notes.sorted(by: {$0.date > $1.date }) ?? []
                 self?.view?.didInsertRow(at: 0)
                 self?.view?.hideLoading()
             case .failure(let error):
                 self?.view?.hideLoading()
                 self?.view?.showError(title: "Ошибка", message: error.localizedDescription)
             }
         }
     }
     
     func deleteNote(at index: Int) {
         let note = notes[index]
         dataRepository.removeData(note: note) { [weak self] result in
             switch result {
             case .success():
                 self?.notes.remove(at: index)
                 self?.view?.didDeleteRow(at: index)
                 
             case .failure(let error):
                 self?.view?.showError(title: "Ошибка", message: error.localizedDescription)
             }
         }
     }
     
     func numberOfNotes() -> Int {
         return notes.count
     }
     
     func noteAt(index: Int) -> Note {
         return notes[index]
     }
     
     func getImage(for isComplete: Bool) -> String {
         return isComplete ? "checkmark.circle.fill" : "circle"
     }
     
     func isToggleNote(for index: Int) {
         var note = notes[index]
         note.isComplete.toggle()
         
         dataRepository.updateNote(note) { [weak self] result in
             switch result {
                 
             case .success():
                 self?.notes[index] = note
                 self?.view?.loadRow(at: index)
             case .failure(let error):
                 self?.view?.showError(title: "Ошибка", message: error.localizedDescription)
             }
             
         }
     }
 }
 
 */
