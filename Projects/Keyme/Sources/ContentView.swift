import SwiftUI

public struct ContentView: View {
    public init() {}

    public var body: some View {
        let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as! String
        Text("baseURL\n\n\(baseURL)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
