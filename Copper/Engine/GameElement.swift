//
//  GameElement.swift
//  Copper
//
//  Created by Lukas on 14.02.21.
//

import Foundation

public protocol CPEGameElement{
    func update() -> Void
    func loadContent() -> Void
}
