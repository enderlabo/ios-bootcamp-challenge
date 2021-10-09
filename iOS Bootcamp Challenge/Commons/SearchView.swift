//
//  SearchView.swift
//  iOS Bootcamp Challenge
//
//  Created by Laborit on 9/10/21.
//

import Foundation

import UIKit

class SearchView: UIView {
    
    var delegate: SearchViewDelegate?
    //always need 2 constructor when used the reusable component
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
   private func initView()  {
   
    }
}

extension SearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text {
            delegate?.searchedText(textSearched: text)
        }
        return true
    }
    
}
