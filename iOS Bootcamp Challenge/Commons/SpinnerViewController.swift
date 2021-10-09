//
//  SpinnerViewController.swift
//  iOS Bootcamp Challenge
//
//  Created by Laborit on 8/10/21.
//

import UIKit

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = UIView()
                view.backgroundColor = UIColor(white: 0, alpha: 0.7)

                spinner.translatesAutoresizingMaskIntoConstraints = false
                spinner.startAnimating()
                view.addSubview(spinner)

                spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        // Do any additional setup after loading the view.
    }

}
