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



class NoteViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

