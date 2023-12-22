import SwiftUI

struct OOBE_WelcomeView: View {
    var words = [
        "Traveler", "Explorer", "Voyager", "Globetrotter", "Explorer",
        "Wayfarer", "Roamer", "Wanderer", "Adventurer", "Journeyer",
        "Sojourner", "Passenger"
    ]
    
    @State private var currentWord: String = ""
    
    var body: some View {
        ZStack{
            StarsBlinkView()
                .ignoresSafeArea()
                .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
            VStack {
                Spacer()
                
                Image(uiImage: UIImage(named: "AppIcon")!)
                    .resizable()
                    .shadow(radius: 10)
                    .frame(width: 128, height: 128)
                    .mask(RoundedRectangle(cornerSize: CGSize(width: 25, height: 25)))
                
                Text("Welcome, \(currentWord)!")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .onAppear {
                        startWordTimer()
                    }
                
    //            Text("In the middle of the journey of our life I came to myself within a dark wood where the straight way was lost.")
                Text("Nel mezzo del cammin di nostra vita mi ritrovai per una selva oscura ché la diritta via era smarrita.")
                    .opacity(0.5)
                    .frame(maxWidth: 300)
                    .fontWeight(.medium)
                    .font(.system(size: 12))
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func startWordTimer() {
        currentWord = words.randomElement() ?? ""
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { timer in
                wordChange()
        }
    }
    
    
    private func wordChange(){
        currentWord = ""
        var word = words.randomElement() ?? ""
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            currentWord += word.split(separator: "").first ?? ""
            word = String(word.dropFirst())
        }
    }
}
