//
//  ListParser.swift
//  Derpiboo
//
//  Created by Austin Chau on 9/16/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import Foundation
import PromiseKit

struct ListParser {
    static func parse(data: Data, as listType: ListRequester.ListType) -> Promise<ListResult> {
        return Promise<Array<NSDictionary>> { fulfill, reject in
            do {
                let key: String = {
                    switch listType {
                    case .images, .lists: return "images"
                    case .search: return "search"
                    }
                }()
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary,
                    let items = json[key] as? Array<NSDictionary> {
                    fulfill(items)
                } else { reject(ParserError.CannotCastJsonIntoNSDictionary(data: data)) }
            } catch { reject(error) }
        }.then(on: .global(qos: .userInitiated)) { items in
            return when(resolved: items.map{ return ImageParser.parse(dictionary: $0) })
        }.then(on: .global(qos: .userInitiated)) { results -> [ImageResult] in
            return results.flatMap {
                if case let .fulfilled(value) = $0 {
                    return value
                } else if case let .rejected(error) = $0 {
                    print(error)
                    return nil
                } else {
                    return nil
                }
            }
        }.then {
            return Promise(value: ListResult(result: $0))
        }
    }
}
