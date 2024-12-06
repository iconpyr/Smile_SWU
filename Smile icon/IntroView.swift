import SwiftUI

struct IntroView: View {
    @State private var showEmoji = false
    @State private var showText = false
    @State private var showButton = false
    @State private var navigateToDetector = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Text("😊")
                        .font(.system(size: 120))
                        .opacity(showEmoji ? 1 : 0)
                        .scaleEffect(showEmoji ? 1 : 0.5)
                    
                    Text("Did you smile today?")
                        .font(.title)
                        .fontWeight(.medium)
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : 20)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    NavigationLink(destination: SmileDetectorView(), isActive: $navigateToDetector) {
                        Button(action: {
                            navigateToDetector = true
                        }) {
                            Text("Go smile!")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(Color(red: 0, green: 0.47, blue: 0.39))
                                .cornerRadius(25)
                                .shadow(radius: 5)
                        }
                    }
                    .opacity(showButton ? 1 : 0)
                    .offset(y: showButton ? 0 : 20)
                    
                    
                    Spacer()
                        .frame(height: 50)
                }
            }
            .onAppear {
                // Sequence of animations
                withAnimation(.easeIn(duration: 1).delay(0.5)) {
                    showEmoji = true
                }
                
                withAnimation(.easeIn(duration: 1).delay(1.5)) {
                    showText = true
                }
                
                withAnimation(.easeIn(duration: 1).delay(2.5)) {
                    showButton = true
                }
            }
        }
        .tint(Color(red: 0, green: 0.47, blue: 0.39))
    }
}

#Preview {
    IntroView()
}
