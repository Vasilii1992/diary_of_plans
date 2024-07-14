//
//  NotePresenter.swift
//  Diary of plans
//
//  Created by Василий Тихонов on 11.07.2024.
//

import Foundation

protocol NotePresenterProtocol {
    
    func loadAndUpdateDisplayData()
    func addNote(note: Note)
    func deleteNote(at index: Int)
    func numberOfNotes() -> Int
    func noteAt(index: Int) -> Note
    func getImage(for isComplete: Bool) -> String
    func isToggleNote(for index: Int)
    func updateNote(_ note: Note, at index: Int)
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
                self?.notes.insert(note, at: 0)
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
    
    func updateNote(_ note: Note, at index: Int) {
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
