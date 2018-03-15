//
//  RecordsTableViewController.swift
//  FlightRecords
//
//  Created by Martin Zid on 12/10/2017.
//  Copyright © 2017 Martin Zid. All rights reserved.
//

import UIKit

class RecordsTableViewController: UITableViewController, SearchViewControllerDelegate {
    
    @IBOutlet var headerView: UIView!
    
    private let viewModel = RecordsViewModel()
    
    private struct Identifiers {
        static let searchSegueIdentifier = "search"
        static let recordCellIdentifier = "RecordCell"
        static let flightDetailSequeIdentifier = "detailFlight"
        static let ftsdDetailSequeIdentifier = "detailFSTD"
        static let addFlightRecordSB = "addFlightRecord"
        static let addSimulatorRecordSB = "addSimulatorRecord"
        static let pdfSegueIdentifier = "PDF"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        tableView.tableHeaderView = nil
        self.becomeFirstResponder()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if(event?.subtype == UIEventSubtype.motionShake) {
            print("did shake")
            viewModel.undoDelete()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintAdjustmentMode = .normal
        self.navigationController?.navigationBar.tintAdjustmentMode = .automatic
    }
    
    private func bindViewModel() {
        viewModel.searchConfigurationChangedSignal.observeValues { [weak self] value in
            self?.tableView.tableHeaderView = (value) ? nil : self?.headerView
        }
        observeSignalForTableDataChanges(with: viewModel.collectionChangedSignal)
    }
    
    // MARK: - Actions
    
    @IBAction func disableFilters(_ sender: UIButton) {
        viewModel.disableFilters()
    }
    
    
    // MARK: - SearchViewControllerDelegate
    
    func apply(searchViewModel viewModel: SearchViewModel) {
        self.viewModel.apply(searchViewModel: viewModel)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.numberOfRecordsInSection() > 0 {
            deleteEmptyTableMessage()
            return viewModel.numberOfRecordsInSection()
        } else {
            if tableView.tableHeaderView == nil {
                displayEmptyTableMessage(message: NSLocalizedString("Empty records table", comment: ""),
                                         subMessage: NSLocalizedString("Add new record info", comment: ""))
            } else {
                displayEmptyTableMessage(message: NSLocalizedString("No records after filtering", comment: ""), subMessage: "")
            }
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.recordCellIdentifier, for: indexPath) as! RecordCell

        cell.viewModel = viewModel.getCellViewModel(for: indexPath)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            confirmDeleteAction { [weak self] _ in
                self?.viewModel.deleteRecord(at: indexPath)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = viewModel.getTypeOfRecord(at: indexPath)
        if  type == .flight {
            performSegue(withIdentifier: Identifiers.flightDetailSequeIdentifier, sender: indexPath)
        } else if type == .simulator {
            performSegue(withIdentifier: Identifiers.ftsdDetailSequeIdentifier, sender: indexPath)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.searchSegueIdentifier {
            if let searchVC = segue.destination.contentViewController as? SearchViewController {
                searchVC.delegate = self
                searchVC.viewModel = viewModel.getSearchViewModel()
            }
        }
        if segue.identifier == Identifiers.pdfSegueIdentifier {
            if let pdfVC = segue.destination.contentViewController as? PDFGeneratorViewController {
                pdfVC.viewModel = viewModel.getPDFGeneratorViewModel()
            }
        }
        if segue.identifier == Identifiers.flightDetailSequeIdentifier {
            if let flightDetailVC = segue.destination.contentViewController as? AddFlightRecordTableViewController {
                if let indexPath = sender as? IndexPath {
                    flightDetailVC.viewModel = viewModel.getAddFlightViewModel(for: indexPath)
                }
            }
        }
        if segue.identifier == Identifiers.ftsdDetailSequeIdentifier {
            if let simulatorDetailVC = segue.destination.contentViewController as? AddSimulatorRecordTableViewController {
                if let indexPath = sender as? IndexPath {
                    simulatorDetailVC.viewModel = viewModel.getAddSimulatorViewModel(for: indexPath)
                }
            }
        }
        
    }

}
