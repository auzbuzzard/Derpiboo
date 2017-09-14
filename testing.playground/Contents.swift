//: Playground - noun: a place where people can play

import UIKit

var searches = [ "1", "2" ]

func recentSearches(count: Int) -> [String] {
    var array = [String]()
    for i in 0..<(min(count, searches.count)) {
        array.append(searches[searches.count - 1 - i])
    }
    return array
}

recentSearches(count: 10)
