import SwiftUI

struct AnalogClockView: View {
    var color: Color = .accentColor
    var backgroundColor: Color = Color(.systemBackground)
    var tickColor: Color = .secondary
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let date = context.date
            let calendar = Calendar.current
            let components = calendar.dateComponents([.minute, .second], from: date)
            let minute = Double(components.minute ?? 0)
            let second = Double(components.second ?? 0)
            // Minutes advance smoothly with seconds
            let minuteAngle = Angle.degrees(((minute + second / 60.0) / 60.0) * 360.0)
            let secondAngle = Angle.degrees((second / 60.0) * 360.0)
            GeometryReader { proxy in
                let size = min(proxy.size.width, proxy.size.height)
                let lineWidth = max(2, size * 0.02)
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                    Circle()
                        .stroke(color.opacity(0.2), lineWidth: lineWidth)

                    // Hour ticks (12)
                    ForEach(0..<12) { i in
                        Capsule()
                            .fill(tickColor)
                            .frame(width: lineWidth, height: size * 0.06)
                            .offset(y: -(size * 0.5 - size * 0.08))
                            .rotationEffect(.degrees(Double(i) / 12.0 * 360.0))
                    }

                    // Minute hand
                    Capsule()
                        .fill(color)
                        .frame(width: lineWidth * 1.2, height: size * 0.34)
                        .offset(y: -size * 0.17)
                        .shadow(radius: 1)
                        .rotationEffect(minuteAngle)

                    // Second hand
                    Capsule()
                        .fill(color.opacity(0.9))
                        .frame(width: lineWidth, height: size * 0.44)
                        .offset(y: -size * 0.22)
                        .rotationEffect(secondAngle)

                    // Center pin
                    Circle()
                        .fill(color)
                        .frame(width: lineWidth * 2.2, height: lineWidth * 2.2)
                        .shadow(radius: 1)
                }
                .frame(width: size, height: size)
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Analog clock")
    }
}

#if DEBUG
struct AnalogClockView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AnalogClockView(color: .blue)
                .padding()
                .previewLayout(.sizeThatFits)
            AnalogClockView(color: .red, backgroundColor: .black, tickColor: .gray)
                .padding()
                .background(Color.black)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif


