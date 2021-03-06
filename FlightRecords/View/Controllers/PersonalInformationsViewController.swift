//
//  PersonalInformationsViewController.swift
//  FlightRecords
//
//  Created by Martin Zid on 30/11/2017.
//  Copyright © 2017 Martin Zid. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

/**
 A form like UITableViewController for editing of the user's personal informations.
 */
class PersonalInformationsViewController: RecordTableViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var birthDayTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    private var viewModel: PersonalInformationsViewModel!
    var delegate: PersonalInformationsControllerDelegate?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = PersonalInformationsViewModel()
        bindViewModel()
        setEndEditingOnTap()
    }
    
    // MARK: - Bindings
    
    private func bindViewModel() {
        nameTextField.text = viewModel.name.value
        surnameTextField.text = viewModel.surname.value
        birthDayTextField.text = viewModel.birthDayString.value
        addressTextField.text = viewModel.address.value

        viewModel.name <~ nameTextField.reactive.continuousTextValues.filterMap{ $0 }
        viewModel.surname <~ surnameTextField.reactive.continuousTextValues.filterMap{ $0 }
        birthDayTextField.reactive.text <~ viewModel.birthDayString
        viewModel.address <~ addressTextField.reactive.continuousTextValues.filterMap{ $0 }
    }
    
    // MARK: - Actions
    
    @IBAction func save(_ sender: Any) {
        viewModel.saveInfoToRealm()
        if let navController = splitViewController?.viewControllers[0] as? UINavigationController {
            navController.popViewController(animated: true)
        }
        if let delegate = delegate {
            delegate.personalInformationSaved()
        }
    }
    
    @IBAction func birthDayTextFieldEditing(_ sender: UITextField) {
        _ = handleDatePicker(for: sender, with: .date, and: viewModel.birthDay, default: nil)
    }
    
    // MARK: - UITableView data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: nameTextField.becomeFirstResponder()
        case 1: surnameTextField.becomeFirstResponder()
        case 2: birthDayTextField.becomeFirstResponder()
        case 3: addressTextField.becomeFirstResponder()
        default: break
        }
    }
    
}
