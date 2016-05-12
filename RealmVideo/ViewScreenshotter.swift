//
//  ViewScreenshotter.swift
//  RealmVideo
//
//  Created by Patrick Balestra on 5/12/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import UIKit

extension UIView {
    
    func takeScreenshot() ->  UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0);
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        UIGraphicsGetImageFromCurrentImageContext();
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        return image
    }
    
}
