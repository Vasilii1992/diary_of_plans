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
    
    private var presenter: NotePresenterProtocol!
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: NoteTableViewCell.reuseIdentifier)
        
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
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
        view.addSubview(activityIndicator)
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupPresenter() {
        let fileHandler = FileHandler()
        let serviceRepository = ServiceRepository(fileHandler: fileHandler)
        presenter = NotePresenter(view: self, dataRepository: serviceRepository)
    }
    
    @objc private func addNoteTapped() {
        
        showLoading()
        
        let alertController = UIAlertController(title: "Новая Заметка", message: "Запиши свою заметку", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Заголовок"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Заметка..."
        }
        
        let addAction = UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
            guard let textFields = alertController.textFields,
                  let titleField = textFields.first, let noteTitle = titleField.text, !noteTitle.isEmpty,
                  let contentField = textFields.last, let noteContent = contentField.text, !noteContent.isEmpty else {
                self?.showError(title: "Ошибка", message: "Оба поля не могут быть пустыми.")
                return
            }
            
            let newNote = Note(title: noteTitle, isComplete: false, date: Date(), notes: noteContent)
            self?.presenter.addNote(note: newNote)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { [weak self] _ in
            self?.hideLoading()
        }
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func editNote(at index: Int) {
        
        showLoading()
        
        let noteToEdit = presenter.noteAt(index: index)
        
        let alertController = UIAlertController(title: "Редактировать Заметку", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Заголовок"
            textField.text = noteToEdit.title
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Заметка..."
            textField.text = noteToEdit.notes
        }
        
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let textFields = alertController.textFields,
                  let titleField = textFields.first, let noteTitle = titleField.text, !noteTitle.isEmpty,
                  let contentField = textFields.last, let noteContent = contentField.text, !noteContent.isEmpty else {
                self?.showError(title: "Ошибка", message: "Заголовок и заметка не могут быть пустыми")
                return
            }
            
            var updatedNote = noteToEdit
            updatedNote.title = noteTitle
            updatedNote.notes = noteContent
            
            self?.presenter.updateNote(updatedNote, at: index)
            self?.hideLoading()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { [weak self] _ in
            self?.hideLoading()
        }
        alertController.addAction(saveAction)
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNoteTapped))
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
        cell.configure(with: note, imageName: presenter.getImage(for: note.isComplete))
        return cell
    }
}

// MARK: - UITableViewDelegate Methods
extension NoteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) //
        presenter.isToggleNote(for: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.deleteNote(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] action, view, completionHandler in
            self?.editNote(at: indexPath.row)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
            self?.presenter.deleteNote(at: indexPath.row)
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
}
