//
//  Float+Extensions.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/04.
//

import Foundation
extension Float {
    /** 세자리 콤마로 구분하는 포메팅 예) 1,000*/
    var decimalForamtString:String {
        return NumberFormatter.localizedString(from: NSNumber(value: self), number: .decimal)
    }
    
    /** 금액 포멧으로 포메팅 */
    var currencyFormatString:String {
        return NumberFormatter.localizedString(from: NSNumber(value: self), number: .currency)
    }
    /** 특정 로케일 값으로 포메팅 하기.*/
    func getFormatString(locale:Locale, style:NumberFormatter.Style)->String? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = style
        return formatter.string(from: NSNumber(value: self))
    }
}
