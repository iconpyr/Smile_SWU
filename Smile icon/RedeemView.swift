import SwiftUI

struct CouponView: View {
    let couponCode: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Coupon Container
            VStack(alignment: .leading, spacing: 20) {
                // Top Section
                VStack(alignment: .leading) {
                    Text("SPECIAL OFFER")
                        .multilineTextAlignment(.leading)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0, green: 0.47, blue: 0.39))
                    
                    Text("20% OFF")
                        .font(.system(size: 40))
                        .fontWeight(.black)
                        .foregroundColor(Color(red: 0, green: 0.47, blue: 0.39))
                    
                    Text("Your Next Purchase")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding()
                
//                // Dotted Line
//                HStack(spacing: 0) {
//                    ForEach(0..<30) { _ in
//                        Circle()
//                            .fill(Color.gray.opacity(0.5))
//                            .frame(width: 4, height: 4)
//                            .padding(.horizontal, 2)
//                    }
//                }
                
                // Coupon Code Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Coupon Code")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(couponCode)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                .padding()
                
                // Valid Until Section
                Text("Valid until Dec 31, 2024")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding()
            }
            .padding(5)
            .frame(
                        maxWidth: .infinity,
                        alignment: .topLeading
            )
//            .frame(maxWidth: .infinity)
//            .background(
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(Color.white)
//                    .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
//            )
            .background(
                Image("Lisa") // Replace with your image name
                        .resizable()
                        .aspectRatio(contentMode: .fill)
            )
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(red: 0, green: 0.47, blue: 0.39), lineWidth: 2)
            )
            .padding()
            
            // Copy Button
            Button(action: {
                UIPasteboard.general.string = couponCode
            }) {
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("Copy Code")
                }
                .foregroundColor(.white)
                .padding()
                .frame(width: 200)
                .background(Color(red: 0, green: 0.47, blue: 0.39))
                .cornerRadius(10)
            }
        }
    }
}

struct RedeemView: View {
    @Environment(\.dismiss) private var dismiss
    let couponCode = "SMILE2024"
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 10) {
                    // Emoji and Text
                    VStack(spacing: 15) {
                        Text("🎉")
                            .font(.system(size: 70))
                        
                        Text("Thank you for smiling!")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 0, green: 0.47, blue: 0.39))
                        
                        Text("Here's your reward")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Coupon
                    CouponView(couponCode: couponCode)
                    
                    Spacer()
                    
                    // Done Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color(red: 0, green: 0.47, blue: 0.39))
                            .cornerRadius(25)
                    }
                    .padding(.bottom, 30)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    RedeemView()
}
