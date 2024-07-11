//
//  ViewController.swift
//  Diary of plans
//
//  Created by Василий Тихонов on 11.07.2024.
//

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

    private var tableView: UITableView!
    private var presenter: NotePresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPresenter()
        presenter.loadAndUpdateDisplayData()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Notes"
        
        // Setup TableView
        tableView = UITableView(frame: view.bounds)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NoteCell")
        view.addSubview(tableView)
        
        // Setup Add Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNoteTapped))
    }
    
    private func setupPresenter() {
        let fileHandler = FileHandler()
        let serviceRepository = ServiceRepository(fileHandler: fileHandler)
        presenter = NotePresenter(view: self, dataRepository: serviceRepository)
    }
    
    @objc private func addNoteTapped() {
        let alertController = UIAlertController(title: "New Note", message: "Enter note title", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Note title"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first, let noteTitle = textField.text, !noteTitle.isEmpty else {
                self?.showError(title: "Error", message: "Note title cannot be empty")
                return
            }
            let newNote = Note(title: noteTitle, isComplete: false, date: Date(), notes: "")
            self?.presenter.addNote(note: newNote)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        let note = presenter.noteAt(index: indexPath.row)
        cell.textLabel?.text = note.title
        cell.accessoryType = note.isComplete ? .checkmark : .none
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
