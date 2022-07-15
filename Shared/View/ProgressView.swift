//
//  ProgressView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/05/09.
//

import SwiftUI

struct KProgressView: View {
    let total:Int
    let progress:Int
    let title:Text
    var value:Double {
        return Double(progress)/Double(total)
    }
    
    var body: some View {
        VStack {
            title
            ProgressView(value: value)
        }.background(Color.k_dim)
    }
}

