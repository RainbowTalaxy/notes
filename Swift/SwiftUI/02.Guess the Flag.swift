
struct ContentView: View {
    // 在视图中，大部分的属性都是状态，所有要加上 @State 包装器
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    
    @State private var score = 0
    
    var body: some View {
        ZStack {
            // 线性渐变
            LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .top, endPoint: .bottom)
                // 忽略四周的安全区
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                VStack {
                    Text("Tap the flag of")
                    Text(countries[correctAnswer])
                        .font(.largeTitle)
                        .fontWeight(.black)
                }
                
                ForEach(0 ..< 3) { number in
                    Button(action: {
                        self.flagTapped(number)
                    }) {
                        Image(self.countries[number])
                            // 显示原来的图片颜色
                            .renderingMode(.original)
                            // 裁剪图片
                            .clipShape(Capsule())
                            // 覆盖一个边框
                            .overlay(Capsule().stroke(Color.black, lineWidth: 1))
                            .shadow(color: .black, radius: 2)
                    }
                }
                
                Text("Score: \(score)")
                    .font(.largeTitle)

            }.foregroundColor(.white)

        // 将 showingScore 与之绑定
        }.alert(isPresented: $showingScore) {
            Alert(
                title: Text(scoreTitle),
                message: Text("Your score is \(score)"),
                dismissButton: .default(Text("Continue")) { self.askQuestion() }
            )
        }
    }
    
    @State private var showingScore = false
    @State private var scoreTitle = ""
    
    // 处理图片点击事件
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct"
            score += 1
        } else {
            scoreTitle = "Wrong! That’s the flag of \(countries[number])."
        }
        showingScore = true
    }
    
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }
    
}
