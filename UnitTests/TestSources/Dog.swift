//
//  Dog.swift
//  iActiveRecord
//
//  Created by JAMES WHITFIELD on 10/18/14.
//  Copyright (c) NEiLAB, INC. All rights reserved.
//

import Foundation


struct VRMappings {}

struct VRConstraints {}

class Dog : Animal {

 @NSManaged var breed:NSString;

/*  // NOTE: PROPOSED STYLES to configure ORM:
     class var mapping: VRMappings {
        return VRMappings();
     }

     class var constraints1: VRConstraints {
         return VRConstraints();
     }


    class var hasMany :[String:String] {
         return ["foo" : "Animal"];
    }

*/

    
}