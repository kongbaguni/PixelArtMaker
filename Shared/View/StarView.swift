//
//  StarView.swift
//  GaweeBaweeBoh
//
//  Created by Changyeol Seo on 2023/07/12.
//

import SwiftUI

struct StarView: View {
    let rating:NSDecimalNumber
    let color:Color
    var body: some View {
        HStack {
            let range = rating.intValue
            
            ForEach(0..<range,id:\.self) { idx in
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(color)
            }
            if(Double(range) < rating.doubleValue) {
                Image(systemName: "star.leadinghalf.filled")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(color)
            }
        }.shadow(color:.orange,radius: 20,x:10,y:10)
            
    }
}

struct StarView_Previews: PreviewProvider {
    static var previews: some View {
        StarView(rating: 5.5,color: .orange)
    }
}
