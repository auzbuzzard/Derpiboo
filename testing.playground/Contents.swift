//: Playground - noun: a place where people can play

import UIKit

let html = "<meta name=\"csrf-token\" content=\"mtMIH0XO2rLka2nyfLcvggTsoEmoUGF9MgtgydDOvaXO+ILuLLCL4Vq0DMV036CG1QpZEGNkj0rjmXnXpGM1VA==\">"

let s = html.range(of: "<meta name=\"csrf-token\" content=\"")
let sub = html.substring(from: s!.upperBound)
let sub2 = sub.substring(to: html.index(html.startIndex, offsetBy: 88))

let m = "mtMIH0XO2rLka2nyfLcvggTsoEmoUGF9MgtgydDOvaXO+ILuLLCL4Vq0DMV036CG1QpZEGNkj0rjmXnXpGM1VA=="
let i = m.characters.count
let m2 = "oPQwTbsQSkLQ0+ilalppl08qEGFSwv8kwCwUfl3+rMX037q80m4bEW4MjZJiMuaTnszpOJn2ERMRvg1gKVMkNA=="
let i2 = m2.characters.count