//
//  Dog.swift
//  iActiveRecord
//
//  Created by JAMES WHITFIELD on 10/18/14.
//  Copyright (c) NEiLAB, INC. All rights reserved.
//

import Foundation

/*
struct VRMappings {}

struct VRConstraints {
    var UNIQUE:Int
} */

class Dog : Animal {
/*
    static let mapping = [
        "breed":["column":"breed"]
    ]
    static let constraints = [
            "breed": ["unique":true]
    ] */
    @NSManaged var breed:NSString?


    var foo:NSString?

    
}