//
// Created by Maxim Krimskiy on 5/6/21.
//

import iActivityIndicator
import SwiftUI

struct Preloader: View {

    var body: some View {
        iActivityIndicator(style: .bars(count: 5, spacing: 5, cornerRadius: 5, scaleRange: 0.7...1, opacityRange: 1...1)).foregroundColor(.red)
    }
}