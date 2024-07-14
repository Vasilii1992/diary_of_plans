//
//  NoteTableViewCell.swift
//  Diary of plans
//
//  Created by Василий Тихонов on 11.07.2024.
//

import UIKit

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
    
    let noteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        return imageView
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
        contentView.addSubview(noteImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(noteLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            noteImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            noteImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: noteImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            noteLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            noteLabel.leadingAnchor.constraint(equalTo: noteImageView.trailingAnchor, constant: 16),
            noteLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            noteLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with note: Note, imageName: String) {
        titleLabel.text = note.title
        noteLabel.text = note.notes
        noteImageView.image = UIImage(systemName: imageName)
    }
}

