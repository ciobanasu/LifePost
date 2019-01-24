//
//  ColorExtension.swift
//  LifePost
//
//  Created by Ciobanasu Ion on 1/11/19.
//  Copyright © 2019 Ciobanasu Ion. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
