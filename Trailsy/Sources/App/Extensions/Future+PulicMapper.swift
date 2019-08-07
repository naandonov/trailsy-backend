//
//  Future+PulicParser.swift
//  App
//
//  Created by Nikolay Andonov on 6.08.19.
//

import Vapor

protocol PublicMappable: Content {
    associatedtype PublicElement: Content
    func mapToPublic() -> PublicElement
}

extension Future where T: PublicMappable {
    
    func mapToPublic() -> Future<T.PublicElement> {
        return map(to: T.PublicElement.self, { element in
            return element.mapToPublic()
        })
    }
}
