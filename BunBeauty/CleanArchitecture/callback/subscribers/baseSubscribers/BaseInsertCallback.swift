//
//  BaseInsertCallback.swift
//  BunBeauty
//
//  Created by Марк Шавловский on 24.06.2020.
//  Copyright © 2020 BunBeauty. All rights reserved.
//

import Foundation
 protocol BaseInsertCallback{
    func returnCreatedCallback<T>(obj:T)
}
