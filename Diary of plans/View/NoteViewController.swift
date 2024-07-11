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
            textField.placeholder = "Заголовок"
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
        cell.configure(with: note, imageName: presenter.getImage(for: note.isComplete))
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
