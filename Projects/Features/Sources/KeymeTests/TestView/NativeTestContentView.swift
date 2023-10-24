//
//  NativeTestContentView.swift
//  Features
//
//  Created by ab180 on 10/19/23.
//  Copyright © 2023 team.humanwave. All rights reserved.
//

import Core
import Network
import DSKit
import SwiftUI
import Kingfisher

struct NativeTestContentView: View {    
    let nickname: String
    let onScoreSubmitted: (_ index: Int, _ score: Int) -> Void
    @Binding var questionIndex: Int
    @Binding var showNextCircle: Bool
    @Binding var showPreviousCircle: Bool
    
    @State private var questions: [QuestionWithScore]
    @State private var questionIndexBuffer: Int = 0
    @State private var currentQuestionState: Question?
    @State private var showNextCircleEffect = false
    @State private var showPreviousCircleEffect = false
    
    @State private var currentScore: Double = 3
    
    init(
        nickname: String,
        questions: [Question],
        questionIndex: Binding<Int>,
        showNextCircle: Binding<Bool>,
        showPreviousCircle: Binding<Bool>,
        onScoreSubmitted: @escaping (_ index: Int, _ score: Int) -> Void
    ) {
        self.nickname = nickname
        self.questions = questions.map { QuestionWithScore(question: $0) }
        self.onScoreSubmitted = onScoreSubmitted
        self._questionIndex = questionIndex
        self._showNextCircle = showNextCircle
        self._showPreviousCircle = showPreviousCircle
    }
    
    var body: some View {
        VStack {
            CircleStack(
                questionsWithScore: $questions,
                questionIndex: $questionIndex,
                questionIndexBuffer: $questionIndexBuffer,
                currentScore: $currentScore,
                showNextCircleEffect: $showNextCircleEffect,
                showPreviousCircleEffect: $showPreviousCircleEffect
            )
            .padding(.horizontal, 10)
            
            question(
                label: questions[questionIndex].question.title,
                height: 210, 
                sliderColor: .hex(questions[questionIndex].question.category.color))
        }
        .onAppear { questionIndexBuffer = questionIndex }
        .animation(Animation.customInteractiveSpring(), value: currentScore)
        .onChange(of: showNextCircle) { show in
            guard questionIndex < questions.endIndex - 1 else {
                showNextCircle = false
                return
            }
            
            onScoreSubmitted(questionIndex, Int(currentScore))
            questions[questionIndex].score = Int(currentScore)
            
            let second: CGFloat = 0.5
            if show {
                currentScore = Double(questions[questionIndex + 1].score ?? 3)
                questionIndex += 1
                
                withAnimation(Animation.customInteractiveSpring(duration: second)) {
                    showNextCircleEffect = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + second) {
                    questionIndexBuffer += 1

                    showNextCircle = false
                    showNextCircleEffect = false
                }
            }
        }
        .onChange(of: showPreviousCircle) { show in
            guard questionIndex > 0 else {
                showPreviousCircle = false
                return
            }
            
            onScoreSubmitted(questionIndex, Int(currentScore))
            questions[questionIndex].score = Int(currentScore)
            
            let second: CGFloat = 0.5
            if show {
                currentScore = Double(questions[questionIndex - 1].score ?? 3)
                questionIndex -= 1

                withAnimation(Animation.customInteractiveSpring(duration: second)) {
                    showPreviousCircleEffect = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + second) {
                    questionIndexBuffer -= 1

                    showPreviousCircle = false
                    showPreviousCircleEffect = false
                }
            }
        }
    }
    
    private func question(label: String, height: CGFloat, sliderColor: Color) -> some View {
        let commonCornerRadius: CGFloat = 24
        
        return RoundedRectangle(cornerRadius: commonCornerRadius)
            .foregroundColor(.hex("232323"))
            .frame(height: height)
            .overlay {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    
                    Text.keyme(nickname + label.dropLast(1), font: .body2)
                        .lineLimit(2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Divider
                    Rectangle()
                        .foregroundColor(.white.opacity(0.1))
                        .frame(height: 1)
                        .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: commonCornerRadius)
                        .frame(height: height * 0.41)
                        .overlay {
                            VStack(spacing: 19) {
                                CustomSlider(value: $currentScore, range: 1...5, color: sliderColor, needSnap: true, showLabel: true)
                                    .frame(maxWidth: .infinity)
                                
                                HStack(spacing: 0) {
                                    ForEach(0..<5, id: \.self) { elem in
                                        Circle().frame(width: 4)
                                            .foregroundColor(.white.opacity(0.5))
                                        
                                        if elem != 4 {
                                            Spacer()
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                            }
                            .padding(.horizontal, 30)
                        }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: commonCornerRadius)
                    .stroke(DSKitAsset.Color.keymeStrokegray.swiftUIColor)
            }
    }
}

private extension NativeTestContentView {
    struct CircleStack: View {
        @Binding var questionsWithScore: [QuestionWithScore]
        
        @Binding var questionIndex: Int
        @Binding var questionIndexBuffer: Int

        @Binding var currentScore: Double
        @Binding var showNextCircleEffect: Bool
        @Binding var showPreviousCircleEffect: Bool
        
        var body: some View {
            let limit = questionsWithScore.count
            
            let current = questionsWithScore[questionIndexBuffer]
            let previous = questionsWithScore[max(questionIndexBuffer - 1, 0)]
            let next = questionsWithScore[min(questionIndexBuffer + 1, limit - 1)]
            
            func calculateRadius(score: Double?, width: CGFloat) -> CGFloat {
                (width / CGFloat(5)) * CGFloat(score ?? 3)
            }
            
            func scoreFromIndex(_ index: Int) -> Double {
                guard 0 <= index, index < limit else {
                    return 3
                }
                
                return Double(questionsWithScore[index].score ?? 3)
            }

            return GeometryReader { proxy in
                ZStack(alignment: .top) {
                    // Topmost circle
                    TestContentCircle(
                        question: current.question,
                        circleRadius: calculateRadius(score: currentScore, width: proxy.size.width)
                    )
                    .giveEffect(
                        showNext: showNextCircleEffect,
                        showPrevious: showPreviousCircleEffect, 
                        innerCircleRadius: (
                            next: nil,
                            previous: calculateRadius(
                                score: scoreFromIndex(questionIndexBuffer),
                                width: proxy.size.width)
                        ),
                        color: (
                            originalColor: .hex("CBCBCB"),
                            nextColor: .hex("CBCBCB"),
                            previousColor: .white
                        ),
                        opacity: (
                            originalOpacity: 1,
                            nextOpacity: 0,
                            previousOpacity: 0.2
                        ),
                        offset: (
                            nextOffset: -300,
                            previousOffset: 25
                        )
                    )                    .zIndex(3)

                    if showPreviousCircleEffect, questionIndexBuffer > 0 {
                        // Previous circle(originally hidden)
                        TestContentCircle(
                            question: previous.question,
                            circleRadius: calculateRadius(
                                score: scoreFromIndex(questionIndexBuffer - 1),
                                width: proxy.size.width),
                            color: .hex("CBCBCB")
                        )
                        .zIndex(3)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    if questionIndexBuffer < limit - 1 {
                        // Second circle
                        VStack {
                            Spacer().frame(height: 25)
                            TestContentCircle(
                                question: next.question,
                                circleRadius: calculateRadius(
                                    score: scoreFromIndex(questionIndexBuffer + 1),
                                    width: proxy.size.width),
                                color: .white
                            )
                            .giveEffect(
                                showNext: showNextCircleEffect,
                                showPrevious: showPreviousCircleEffect, 
                                innerCircleRadius: (
                                    next: calculateRadius(
                                        score: scoreFromIndex(questionIndexBuffer + 1),
                                        width: proxy.size.width),
                                    previous: calculateRadius(
                                        score: 1.0, // Hide
                                        width: proxy.size.width)
                                ),
                                color: (
                                    originalColor: .white,
                                    nextColor: .hex("CBCBCB"),
                                    previousColor: .white
                                ),
                                opacity: (
                                    originalOpacity: 0.2,
                                    nextOpacity: 1,
                                    previousOpacity: 0.1
                                ),
                                offset: (
                                    nextOffset: -25,
                                    previousOffset: 25
                                )
                            )
                        }
                        .zIndex(2)
                        
                        if questionIndex < limit - 2 {
                            // Third circle
                            VStack {
                                Spacer().frame(height: 25 * 2)
                                TestContentCircle(
                                    question: questionsWithScore[min(questionIndexBuffer + 2, limit)].question,
                                    circleRadius: calculateRadius(score: 3, width: proxy.size.width),
                                    color: .white
                                )
                                .giveEffect(
                                    showNext: showNextCircleEffect,
                                    showPrevious: showPreviousCircleEffect,
                                    innerCircleRadius: (
                                        next: calculateRadius(
                                            score: scoreFromIndex(questionIndexBuffer + 2),
                                            width: proxy.size.width),
                                        previous: nil
                                    ),
                                    color: (
                                        originalColor: .white,
                                        nextColor: .white,
                                        previousColor: .clear
                                    ),
                                    opacity: (
                                        originalOpacity: 0.1,
                                        nextOpacity: 0.2,
                                        previousOpacity: 0.0
                                    ),
                                    offset: (
                                        nextOffset: -25,
                                        previousOffset: 0
                                    )
                                )
                            }
                            .zIndex(1)
                            
                            // Unveiling circle
                            if showNextCircleEffect, questionIndexBuffer < limit - 3 {
                                VStack {
                                    Spacer().frame(height: 25 * 2)
                                    TestContentCircle(
                                        question: nil,
                                        circleRadius: (proxy.size.width / CGFloat(5)) * CGFloat(3),
                                        color: .white.opacity(0.1)
                                    )
                                }
                                .zIndex(1)
                                .transition(.opacity)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TestContentCircle: View {
    let question: Question?
    let circleRadius: CGFloat
    let color: Color
    
    init(question: Question?, circleRadius: CGFloat, color: Color = .hex("CBCBCB")) {
        self.question = question
        self.circleRadius = circleRadius
        self.color = color
    }
    
    var body: some View {
        Circle()
            .foregroundColor(color)
            .blur(radius: 0) // TODO: FIxME
            .overlay {
                ZStack {
                    if let question {
                        Circle()
                            .foregroundColor(.hex(question.category.color))
                            .frame(width: circleRadius, height: circleRadius)
                        
                        KFImage(try? question.category.iconUrl.asURL())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                    }
                }
            }
            .zIndex(3)
    }
}

extension TestContentCircle {
    func giveEffect(
        showNext: Bool,
        showPrevious: Bool,
        innerCircleRadius: (
            next: CGFloat?,
            previous: CGFloat?
        ),
        color: (
            originalColor: Color,
            nextColor: Color,
            previousColor: Color
        ),
        opacity: (
            originalOpacity: CGFloat,
            nextOpacity: CGFloat,
            previousOpacity: CGFloat
        ),
        offset: (
            nextOffset: CGFloat,
            previousOffset: CGFloat
        )
    ) -> some View {
        if showNext {
            return TestContentCircle(
                question: self.question,
                circleRadius: innerCircleRadius.next ?? self.circleRadius,
                color: color.nextColor
            )
            .offset(y: offset.nextOffset)
            .opacity(opacity.nextOpacity)
        } else if showPrevious {
            return TestContentCircle(
                question: self.question,
                circleRadius: innerCircleRadius.previous ?? self.circleRadius,
                color: color.previousColor
            )
            .offset(y: offset.previousOffset)
            .opacity(opacity.previousOpacity)
        } else {
            return TestContentCircle(
                question: self.question,
                circleRadius: self.circleRadius,
                color: color.originalColor
            )
            .offset(y: 0)
            .opacity(opacity.originalOpacity)
        }
    }
}
