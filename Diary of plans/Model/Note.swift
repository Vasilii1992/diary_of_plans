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
 Ты IOS разработчик.У нас приложение с заметками. Нам нужно сделать так чтобы при нажатии на ячейку у нас изменялось поле "isComplete" и в зависимости от того какое там значение, срабатывал метод "getImage" и изображение в ячейке менялось

 You are an iOS developer.We have an application with notes. We need to make sure that when we click on a cell, the "isComplete" field changes and, depending on what value is there, the "getImage" method is triggered and the image in the cell changes
 
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

 class NoteViewController: UIViewController, NoteViewProtocol {

     private var presenter: NotePresenterProtocol!
     
     private lazy var tableView: UITableView = {
         let tableView = UITableView()
             tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: NoteTableViewCell.reuseIdentifier)

         return tableView
     }()

     
     override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .white
         title = "Заметки"
         setupViews()
         setupConstraints()
         setupDelegate()
         setupPresenter()
         presenter.loadAndUpdateDisplayData()
         
         navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNoteTapped))

     }
     
     private func setupViews() {

         view.addSubview(tableView)
         
     }
     
     func setupDelegate() {
         tableView.dataSource = self
         tableView.delegate = self
     }
     func setupConstraints() {
         tableView.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
             tableView.topAnchor.constraint(equalTo: view.topAnchor),
             tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         
         ])
     }

     private func setupPresenter() {
         let fileHandler = FileHandler()
         let serviceRepository = ServiceRepository(fileHandler: fileHandler)
         presenter = NotePresenter(view: self, dataRepository: serviceRepository)
     }
     
     @objc private func addNoteTapped() {
         let alertController = UIAlertController(title: "Новая Заметка", message: "Запиши свою заметку", preferredStyle: .alert)
         
         // Title field
         alertController.addTextField { textField in
             textField.placeholder = "Заголовок..."
         }
         
         // Content field
         alertController.addTextField { textField in
             textField.placeholder = "Заметка..."
         }
         
         let addAction = UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
             guard let textFields = alertController.textFields,
                   let titleField = textFields.first, let noteTitle = titleField.text, !noteTitle.isEmpty,
                   let contentField = textFields.last, let noteContent = contentField.text, !noteContent.isEmpty else {
                 self?.showError(title: "Error", message: "Both title and note cannot be empty")
                 return
             }
             
             let newNote = Note(title: noteTitle, isComplete: false, date: Date(), notes: noteContent)
             self?.presenter.addNote(note: newNote)
         }
         
         let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
         
         alertController.addAction(addAction)
         alertController.addAction(cancelAction)
         
         present(alertController, animated: true, completion: nil)
     }


     // MARK: - NoteViewProtocol Methods
     func showError(title: String, message: String) {
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         present(alert, animated: true, completion: nil)
     }
     
     func showLoading() {
         // Optionally implement loading indicator
     }
     
     func hideLoading() {
         // Optionally hide loading indicator
     }
     
     func loadRow(at index: Int) {
         tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
     }
     
     func reloadData() {
         tableView.reloadData()
     }
     
     func didInsertRow(at index: Int) {
         tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
     }
     
     func didDeleteRow(at index: Int) {
         tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
     }
 }

 // MARK: - UITableViewDataSource Methods
 extension NoteViewController: UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return presenter.numberOfNotes()
     }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseIdentifier, for: indexPath) as? NoteTableViewCell else {
             return UITableViewCell()
         }
         let note = presenter.noteAt(index: indexPath.row)
         cell.configure(with: note)
         cell.image.image = UIImage(systemName: presenter.getImage(for: false))
         return cell
     }

 }

 // MARK: - UITableViewDelegate Methods
 extension NoteViewController: UITableViewDelegate {
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         presenter.isToggleNote(for: indexPath.row)
     }
     
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             presenter.deleteNote(at: indexPath.row)
         }
     }
 }

 class NoteTableViewCell: UITableViewCell {
     static let reuseIdentifier = "NoteTableViewCell"

     
     private let titleLabel: UILabel = {
         let label = UILabel()
         label.font = UIFont.boldSystemFont(ofSize: 16)
         label.translatesAutoresizingMaskIntoConstraints = false
         return label
     }()
     
     private let noteLabel: UILabel = {
         let label = UILabel()
         label.font = UIFont.systemFont(ofSize: 14)
         label.numberOfLines = 0
         label.translatesAutoresizingMaskIntoConstraints = false
         return label
     }()
     
      let image: UIImageView = {
         let image = UIImageView()
         image.tintColor = .systemBlue
         image.translatesAutoresizingMaskIntoConstraints = false
         image.heightAnchor.constraint(equalToConstant: 24).isActive = true
         image.widthAnchor.constraint(equalToConstant: 24).isActive = true

         return image
     }()
     
     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
         setupViews()
         setupConstraints()
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
     private func setupViews() {
         contentView.addSubview(image)
         contentView.addSubview(titleLabel)
         contentView.addSubview(noteLabel)
     }
     
     private func setupConstraints() {
         NSLayoutConstraint.activate([
             image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
             
             
             titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
             titleLabel.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 16),
             titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
             
             noteLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
             noteLabel.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 16),
             noteLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
             noteLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
         ])
     }

     func configure(with note: Note) {
         titleLabel.text = note.title
         noteLabel.text = note.notes
         
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
