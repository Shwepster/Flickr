//
//  HTTPError.swift
//  Flickr
//
//  Created by Maxim Vynnyk on 18.09.2024.
//

enum HTTPError: Error {
    case invalidStatusCode(Int)
    case unexpectedResponseType
    case notFound
    case noPermission
}
