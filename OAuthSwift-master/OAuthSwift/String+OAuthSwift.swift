//
//  String+OAuthSwift.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 6/21/14.
//  Copyright (c) 2014 Dongri Jin. All rights reserved.
//

import Foundation

extension String {

    internal func indexOf(_ sub: String) -> Int? {
        var pos: Int?
        
        if let range = self.range(of: sub) {
            if !range.isEmpty {
                pos = self.characters.distance(from: self.startIndex, to: range.lowerBound)
            }
        }
        
        return pos
    }
    
    internal subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.characters.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.characters.index(self.startIndex, offsetBy: r.upperBound - r.lowerBound) //todo:swift3
            
            let digitRange = startIndex..<endIndex
            return self[digitRange]
        }
    }

    func urlEncodedStringWithEncoding(_ encoding: String.Encoding) -> String {
        let charactersToBeEscaped = ":/?&=;+!@#$()',*" as CFString
        let charactersToLeaveUnescaped = "[]." as CFString

        let raw: NSString = self as NSString
        
        let result = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, raw, charactersToLeaveUnescaped, charactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding.rawValue))

        return result as! String
    }

    func parametersFromQueryString() -> Dictionary<String, String> {
        var parameters = Dictionary<String, String>()

        let scanner = Scanner(string: self)

        var key: NSString?
        var value: NSString?

        while !scanner.isAtEnd {
            key = nil
            scanner.scanUpTo("=", into: &key)
            scanner.scanString("=", into: nil)

            value = nil
            scanner.scanUpTo("&", into: &value)
            scanner.scanString("&", into: nil)

            if (key != nil && value != nil) {
                parameters.updateValue(value! as String, forKey: key! as String)
            }
        }
        
        return parameters
    }
    //分割字符
    func split(_ s:String)->[String]{
        if s.isEmpty{
            var x=[String]()
            for y in self.characters{
                x.append(String(y))
            }
            return x
        }
        return self.components(separatedBy: s)
    }
    //去掉左右空格
    func trim()->String{
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    //是否包含字符串
    func has(_ s:String)->Bool{
        if (self.range(of: s) != nil) {
            return true
        }else{
            return false
        }
    }
    //是否包含前缀
    func hasBegin(_ s:String)->Bool{
        if self.hasPrefix(s) {
            return true
        }else{
            return false
        }
    }
    //是否包含后缀
    func hasEnd(_ s:String)->Bool{
        if self.hasSuffix(s) {
            return true
        }else{
            return false
        }
    }
    //统计长度
    func length()->Int{
        return self.utf16.count
    }
    //统计长度(别名)
    func size()->Int{
        return self.utf16.count
    }
    //重复字符串
    func `repeat`(_ times: Int) -> String{
        var result = ""
        for _ in 0..<times {
            result += self
        }
        return result
    }
    //反转
    func reverse()-> String{
        let s=Array(self.split("").reversed())
        var x=""
        for y in s{
            x+=y
        }
        return x
    }
}

