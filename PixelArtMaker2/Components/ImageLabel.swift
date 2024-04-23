//
//  ImageLabel.swift
//  PixelArtMaker2
//
//  Created by Changyeol Seo on 4/23/24.
//

import SwiftUI

struct ImageLabel: View {
    let image:Image
    let label:Text
    var body: some View {
        HStack {
            image
                .foregroundStyle(.primary,.secondary, .orange)
            label
        }
    }
}

#Preview {
    ImageLabel(image: .init(systemName: "person.line.dotted.person"), label: .init("test"))
}
