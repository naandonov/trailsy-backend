//
//  Environment+Utilities.swift
//  App
//
//  Created by Nikolay Andonov on 6.08.19.
//

import Vapor

extension Environment {
    
    static var DATABASE_URL: String? {
        return Environment.get("DATABASE_URL")
    }
}
