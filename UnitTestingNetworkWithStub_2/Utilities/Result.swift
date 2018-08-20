//
//  Result.swift
//  UnitTestingNetworkWithStub_2
//
//  Created by Vinh Nguyen on 20/8/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(NVError)
}
