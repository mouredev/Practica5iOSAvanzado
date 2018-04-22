//
//  CustomUIVViewController.swift
//  Everpobre
//
//  Created by Brais Moure on 16/4/18.
//  Copyright © 2018 Brais Moure. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // Embebe un UIViewController en un UINavigationController
    func wrappedInNavigation() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
    
}
