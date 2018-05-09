//
//  Query.swift
//  Monizze
//
//  Created by Stijn Willems on 21/04/2017.
//  Copyright © 2017 iCapps. All rights reserved.
//

import Foundation

public protocol URLQueryParameterStringConvertible {
	var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
	/**
	This computed property returns a query parameters string from the given NSDictionary. For
	example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
	string will be @"day=Tuesday&month=January".
	@return The computed parameters string.
	*/
	public var queryParameters: String {
		var parts: [String] = []
		for (key, value) in self {
            let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted

			let part = String(format: "%@=%@",
			                  String(describing: key).addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!,
			                  String(describing: value).addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!)
			parts.append(part as String)
		}
		return parts.joined(separator: "&")
	}

}
