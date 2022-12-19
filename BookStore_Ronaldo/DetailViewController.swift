//
//  DetailViewController.swift
//  BookStore_Ronaldo
//
//  Created by Ronaldo Angelo on 18/12/22.
//  Copyright © 2022 Ronaldo Angelo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: - Data
    private var bookViewModel: BookViewModel?
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
        
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!

    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var buyButton: UIButton!
    
    @IBOutlet var detailStackView: UIStackView!
    
    // MARK: - init
    public convenience init(bookViewModel: BookViewModel? = nil) {
        self.init()
        self.bookViewModel = bookViewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        bookViewModel = BookViewModel()
        super.init(coder: aDecoder)
    }

    // MARK: - view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = nil
        navigationController?.navigationItem.leftBarButtonItem = nil

        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) -> Void in            
            if UIApplication.shared.statusBarOrientation.isPortrait {
                self.detailStackView.axis = .vertical
            } else {
                self.detailStackView.axis = .horizontal
            }
            
        }, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func openBuyLink(_ sender: Any) {
        if let link = detailItem?.saleInfo?.buyLink,
            let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }

    @IBAction func favoriteBook(_ sender: UIBarButtonItem) {
        
        if let book = self.detailItem, let bookViewModel = bookViewModel {
            if bookViewModel.favoriteBook(book: book) {
                sender.image = #imageLiteral(resourceName: "FavoriteFullIcon")
            }
        }
        
    }
    
    // MARK: - Methods
    func configureView() {
        // Update the user interface for the detail item.
        if let book = self.detailItem {
            
            if let info = book.volumeInfo {
                
                if let titleLabel = self.titleLabel {
                    titleLabel.text = info.title
                }
                
                if let authorLabel = self.authorLabel {
                    authorLabel.text = info.authors?.joined(separator: ";")
                }
                
                if let descriptionLabel = self.descriptionLabel {
                    descriptionLabel.text = info.description
                }
                
                if let imageView = self.imageView {
                    imageView.image = #imageLiteral(resourceName: "NoImageIcon")
                    APIServices.sharedInstance.loadImage(imageURL: info.imageLinks?.thumbnail) { image in
                        if let image = image {
                            DispatchQueue.main.async() { _ in
                                imageView.image = image
                            }
                        }
                    }
                }
                
                if let buyButton = self.buyButton, let _ = book.saleInfo?.buyLink {
                    buyButton.isEnabled = true
                }
                
            }
            
        }
    }
    
    var detailItem: Book? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
}

