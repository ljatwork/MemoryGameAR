//
//  ViewController+View.swift
//  MemoryGameAR
//
//  Created by Leah Joy Ylaya on 1/19/21.
//

import Foundation
import UIKit
import SnapKit

extension ViewController {
    func addHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
       
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
    }
    
    func addNumOfMatchedLabel() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
       
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
    }
}
