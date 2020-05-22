//
//  Request.swift
//  UserSystem
//
//  Created by Антон Тимонин on 21.05.2020.
//  Copyright © 2020 Антон Тимонин. All rights reserved.
//

import Foundation

struct RequestHack {
    var sender: String
    var receiver: String
    var description: String
    var date: String
    var isCompleted: Int
    
    var requesid: String
    
    init() {
        sender = ""
        receiver = ""
        description = ""
        date = ""
        isCompleted = 0
        
        requesid = ""
    }
}
