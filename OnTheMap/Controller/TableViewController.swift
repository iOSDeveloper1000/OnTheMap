//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Arno Seidel on 15.12.20.
//

import Foundation
import UIKit


// MARK: TableViewController: UITableViewController

class TableViewController: UITableViewController {

    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!


    // MARK: Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Download data only if it is not available
        if !DataBackend.locations.isEmpty {
            self.tableView.reloadData()
        } else {
            NetworkClient.getLocations(completion: self.handleDownloadResponse(success:errorMessage:))
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func refreshButtonPressed(_ sender: Any) {

        NetworkClient.getLocations(completion: self.handleDownloadResponse(success:errorMessage:))

    }

    @IBAction func addButtonPressed(_ sender: Any) {

        NetworkClient.getUserData(completion: self.handleUserDataResponse(success:errorMessage:))

    }

    @IBAction func logoutButtonPressed(_ sender: Any) {

        // Delete user session
        NetworkClient.deleteSession { (success, error) in
            
            // Clear data in app and destruct backend object
            DataBackend.locations = []
            
            self.dismiss(animated: true, completion: nil)
        }
    }


    // MARK: UITableViewDelegate, UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataBackend.locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let location = DataBackend.locations[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentLocationCell", for: indexPath)

        cell.textLabel?.text = "\(location.firstName) \(location.lastName)"
        cell.detailTextLabel?.text = location.mediaUrl
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = DataBackend.locations[(indexPath as NSIndexPath).row]
        guard let url = URL(string: location.mediaUrl) else {
            FailureHandling.showFailure(onTopOf: self, case: .invalidUrl, detailedDescription: "Given string has no proper url format.")
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { (success) in
            if !success {
                DispatchQueue.main.async {
                    FailureHandling.showFailure(onTopOf: self, case: .invalidUrl, detailedDescription: "Given url cannot be opened.")
                }
            }
        }
    }


    // MARK: Helper and callback methods

    func handleDownloadResponse(success: Bool, errorMessage: ErrorMessage?) {
        if success {
            self.tableView.reloadData()
        } else {
            FailureHandling.showFailure(onTopOf: self, case: .dataDownloadFailed, detailedDescription: errorMessage!)
        }
    }

    func handleUserDataResponse(success: Bool, errorMessage: ErrorMessage?) {
        if success {
            self.performSegue(withIdentifier: "userDataSuccessfulFromTable", sender: nil)
        } else {
            FailureHandling.showFailure(onTopOf: self, case: .userDownloadFailed, detailedDescription: errorMessage!)
        }
    }

}
