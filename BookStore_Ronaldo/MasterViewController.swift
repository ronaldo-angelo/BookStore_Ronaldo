//
//  MasterViewController.swift
//  BookStore_Ronaldo
//
//  Created by Ronaldo Angelo on 18/12/22.
//  Copyright © 2022 Ronaldo Angelo. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {
    
    // MARK: - Data
    private var bookViewModel: BookViewModel
    
    var detailViewController: DetailViewController? = nil
    
    // MARK: - UI
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    // MARK: - init
    public convenience init() {
        self.init()
        bookViewModel = BookViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        bookViewModel = BookViewModel()
        super.init(coder: aDecoder)
    }
    
    // MARK: - view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        tableView.backgroundView = spinner
        
        bookViewModel.fetchData { [weak self] success in
            if success {
                self?.tableView.reloadData()
                self?.spinner.stopAnimating()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = bookViewModel.object(at: indexPath)
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func showFavorites(_ sender: UIBarButtonItem) {
        
        let filtered = bookViewModel.filterByFavorites() { [weak self] _ in
            self?.tableView.reloadData()
        }
        sender.image = filtered ? #imageLiteral(resourceName: "FunnelFullIcon") : #imageLiteral(resourceName: "FunnelIcon")
        
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = bookViewModel.numberOfRowsInSection(section: section)
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "BookInfoCell", for: indexPath) as? BookInfoTableViewCell {
                if let info = bookViewModel.infoForRowAt(indexPath: indexPath) {
                    cell.thumbnailImageView.image = #imageLiteral(resourceName: "NoImageIcon")
                    cell.titleLabel.text = info.title
                    
                    APIServices.sharedInstance.loadImage(imageURL: info.imageLinks?.smallThumbnail) { image in
                        if let image = image {
                            DispatchQueue.main.async() { _ in
                                cell.thumbnailImageView.image = image
                            }
                        }
                    }
                }
                return cell
            }
            
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingTableViewCell", for: indexPath) as? LoadingTableViewCell {
                return cell
            }
            
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        bookViewModel.updateBottomLoader(indexPath: indexPath) { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
}

