import SwiftUI

// MARK: - Container

struct BattleDemoView: View {
    let onContinue: (Bool) -> Void
    @State private var showScene2 = false

    var body: some View {
        ZStack {
            if showScene2 {
                DemoDefeatScene(onContinue: onContinue)
            } else {
                DemoVictoryScene {
                    withAnimation(.easeInOut(duration: 0.4)) { showScene2 = true }
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showScene2)
    }
}

// MARK: - Scene 1: Victory

private struct DemoVictoryScene: View {
    let onNext: () -> Void

    // Hardcoded assets — forest arena, knight hero, demon monster
    private let arenaAsset   = Battleground.forest.assetName
    private let groundPad: CGFloat = 68   // Battleground.forest.groundPadding
    private let heroH: CGFloat    = 120   // HeroClass.knight.sceneHeight
    private let heroYOff: CGFloat = 6     // HeroClass.knight.sceneYOffset
    private let monH: CGFloat     = 280   // MonsterType.demon.sceneHeight
    private let monYOff: CGFloat  = 40    // MonsterType.demon.sceneYOffset

    private let heroIdle   = HeroClass.knight.idleFrames
    private let heroWalk   = HeroClass.knight.walkFrames
    private let heroAttack = HeroClass.knight.attackFrames
    private let heroJump   = HeroClass.knight.jumpFrames
    private let monIdle    = MonsterType.demon.idleFrames
    private let monDeath   = MonsterType.demon.deathFrames

    private let typeText = "Complete your tasks before the deadline\nto defeat the monsters!"

    @State private var displayed  = ""
    @State private var charIdx    = 0
    @State private var heroImg    = HeroClass.knight.idleFrames[0]
    @State private var monImg     = MonsterType.demon.idleFrames[0]
    @State private var heroXOffset: CGFloat = 0
    @State private var heroFlipped = false
    @State private var heroHP: Double = 1.0
    @State private var monHP:  Double = 1.0
    @State private var monOpacity: Double = 1.0
    @State private var showBtn   = false
    @State private var showNext  = false
    @State private var heroLoopTimer: Timer?
    @State private var heroWaitTimer: Timer?
    @State private var monLoopTimer:  Timer?
    @State private var monWaitTimer:  Timer?
    @State private var animTimers: [Timer] = []
    @State private var phase = 0

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Battle scene (exact replica of BattleSceneView layout) ──
                ZStack(alignment: .bottom) {
                    Color.clear

                    Image(arenaAsset)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 280)
                        .clipped()

                    LinearGradient(
                        colors: [Color.black.opacity(0.35), Color.clear],
                        startPoint: .bottom,
                        endPoint: .init(x: 0.5, y: 0.5)
                    )

                    // Top-left title
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Today")
                            .font(.title.bold())
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                        Text(Date.now.formatted(date: .long, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Characters
                    HStack(alignment: .bottom, spacing: 0) {
                        Image(heroImg)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                            .scaleEffect(x: heroFlipped ? -1 : 1, y: 1)
                            .offset(x: heroXOffset, y: heroYOff)
                            .frame(height: heroH)

                        Spacer()

                        Image(monImg)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                            .scaleEffect(x: -1, y: 1)
                            .offset(y: monYOff)
                            .frame(height: monH)
                            .opacity(monOpacity)
                    }
                    .frame(height: 280 - groundPad, alignment: .bottom)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .padding(.horizontal, 24)
                    .padding(.bottom, groundPad)

                    // HP bars
                    HStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Knight")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 1)
                            HPBarView(fraction: heroHP,
                                      fillImage: "recursos/16Inner_Interface/loading_green_full_bar")
                                .frame(width: 120, height: 14)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Demon")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 1)
                            HPBarView(fraction: monHP,
                                      fillImage: "recursos/16Inner_Interface/loading_red_full_bar")
                                .frame(width: 120, height: 14)
                        }
                        .opacity(monOpacity)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 52)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
                .frame(height: 280)
                .clipped()

                // ── Content below scene ──
                VStack(spacing: 0) {
                    HStack {
                        Text("HOW IT WORKS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.orange)
                            .tracking(1)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 12)

                    Text(displayed)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)

                    Spacer()

                    if showBtn {
                        Button { startBattle() } label: {
                            HStack(spacing: 8) {
                                Text("⚔️")
                                Text("See what happens")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.orange)
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                    } else if showNext {
                        Button(action: onNext) {
                            Text("Next →")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(white: 0.13))
                                .cornerRadius(14)
                                .overlay(RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.orange.opacity(0.5), lineWidth: 1))
                        }
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                    }
                }
                .animation(.easeIn(duration: 0.25), value: showBtn)
                .animation(.easeIn(duration: 0.25), value: showNext)
                .frame(maxHeight: .infinity)
                .padding(.bottom, 48)
            }
        }
        .onAppear { setup() }
        .onDisappear { invalidateAll() }
    }

    // MARK: - Logic

    private func setup() {
        startHeroAmbient(heroIdle)
        startMonAmbient(monIdle)
        typewrite()
    }

    private func typewrite() {
        let t = Timer.scheduledTimer(withTimeInterval: 0.038, repeats: true) { timer in
            if charIdx < typeText.count {
                displayed.append(typeText[typeText.index(typeText.startIndex, offsetBy: charIdx)])
                charIdx += 1
            } else {
                timer.invalidate()
                phase = 1
                withAnimation { showBtn = true }
            }
        }
        animTimers.append(t)
    }

    private func startBattle() {
        guard phase == 1 else { return }
        phase = 2
        withAnimation { showBtn = false }
        heroWaitTimer?.invalidate()
        monWaitTimer?.invalidate()

        // 1. Hero walks toward monster
        startHeroLoop(heroWalk, interval: 0.08)
        withAnimation(.linear(duration: 0.75)) { heroXOffset = 178 }

        after(0.88) {
            // 2. Hero attacks
            heroLoopTimer?.invalidate()
            playOnce(heroAttack, interval: 0.08, update: { heroImg = $0 }) {

                // Monster HP drains to zero
                withAnimation(.easeOut(duration: 0.6)) { monHP = 0 }

                // Monster death frames
                playOnce(monDeath, interval: 0.10, update: { monImg = $0 }) {
                    withAnimation(.easeOut(duration: 0.5)) { monOpacity = 0 }
                }

                // Hero returns home
                after(0.15) {
                    heroFlipped = true
                    startHeroLoop(heroWalk, interval: 0.08)
                    withAnimation(.linear(duration: 0.55)) { heroXOffset = 0 }
                    after(0.6) { heroFlipped = false }
                }

                // Hero jump celebration
                after(0.75) {
                    heroLoopTimer?.invalidate()
                    playOnce(heroJump, interval: 0.08, update: { heroImg = $0 }) {
                        startHeroLoop(heroIdle, interval: 0.10)
                        phase = 3
                        withAnimation { showNext = true }
                    }
                }
            }
        }
    }

    // MARK: - Timer helpers

    private func startHeroAmbient(_ frames: [String]) {
        heroLoopTimer?.invalidate(); heroWaitTimer?.invalidate()
        heroImg = frames[0]
        heroWaitTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
            var i = 1
            heroLoopTimer = Timer.scheduledTimer(withTimeInterval: 0.10, repeats: true) { t in
                if i < frames.count { heroImg = frames[i]; i += 1 }
                else { t.invalidate(); heroImg = frames[0]; startHeroAmbient(frames) }
            }
        }
    }

    private func startMonAmbient(_ frames: [String]) {
        monLoopTimer?.invalidate(); monWaitTimer?.invalidate()
        monImg = frames[0]
        monWaitTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            var i = 1
            monLoopTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { t in
                if i < frames.count { monImg = frames[i]; i += 1 }
                else { t.invalidate(); monImg = frames[0]; startMonAmbient(frames) }
            }
        }
    }

    private func startHeroLoop(_ frames: [String], interval: TimeInterval) {
        heroWaitTimer?.invalidate(); heroLoopTimer?.invalidate()
        var i = 0
        heroLoopTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            i = (i + 1) % frames.count; heroImg = frames[i]
        }
    }

    private func startMonLoop(_ frames: [String], interval: TimeInterval) {
        monWaitTimer?.invalidate(); monLoopTimer?.invalidate()
        var i = 0
        monLoopTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            i = (i + 1) % frames.count; monImg = frames[i]
        }
    }

    private func playOnce(_ frames: [String], interval: TimeInterval, update: @escaping (String) -> Void, done: @escaping () -> Void) {
        update(frames[0]); var i = 1
        let t = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if i < frames.count { update(frames[i]); i += 1 } else { timer.invalidate(); done() }
        }
        animTimers.append(t)
    }

    private func after(_ delay: TimeInterval, _ action: @escaping () -> Void) {
        let t = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in action() }
        animTimers.append(t)
    }

    private func invalidateAll() {
        heroLoopTimer?.invalidate(); heroWaitTimer?.invalidate()
        monLoopTimer?.invalidate(); monWaitTimer?.invalidate()
        animTimers.forEach { $0.invalidate() }; animTimers.removeAll()
    }
}

// MARK: - Scene 2: Defeat + Revenge + Difficulty choice

private struct DemoDefeatScene: View {
    let onContinue: (Bool) -> Void

    private let arenaAsset    = Battleground.forest.assetName
    private let groundPad: CGFloat = 68
    private let heroH: CGFloat     = 120
    private let heroYOff: CGFloat  = 6
    private let monH: CGFloat      = 280
    private let monYOff: CGFloat   = 40

    private let heroIdle   = HeroClass.knight.idleFrames
    private let heroWalk   = HeroClass.knight.walkFrames
    private let heroAttack = HeroClass.knight.attackFrames
    private let heroJump   = HeroClass.knight.jumpFrames
    private let monIdle    = MonsterType.demon.idleFrames
    private let monWalk    = MonsterType.demon.walkFrames
    private let monAttack  = MonsterType.demon.attackFrames
    private let monDeath   = MonsterType.demon.deathFrames

    private let text1 = "But miss a deadline and the monster comes for you..."
    private let text2 = "But if you miss a deadline, you still have a chance to avenge yourself!"

    // phase: 0=typing1 1=defeat-sequence 2=typing2 3=avenge-btn 4=revenge-battle 5=mode-choice 6=final-btn
    @State private var phase        = 0
    @State private var displayed    = ""
    @State private var charIdx      = 0
    @State private var heroImg      = HeroClass.knight.idleFrames[0]
    @State private var monImg       = MonsterType.demon.idleFrames[0]
    @State private var heroXOffset: CGFloat = 0
    @State private var heroFlipped          = false
    @State private var monXOffset: CGFloat  = 0
    @State private var monOpacity: Double   = 1.0
    @State private var monFacesHero         = true
    @State private var heroHP: Double       = 1.0
    @State private var monHP:  Double       = 1.0
    @State private var heroRedTint: Double  = 0
    @State private var heroShake: CGFloat   = 0
    @State private var chosenEasy: Bool?    = nil
    @State private var heroLoopTimer: Timer?
    @State private var heroWaitTimer: Timer?
    @State private var monLoopTimer:  Timer?
    @State private var monWaitTimer:  Timer?
    @State private var animTimers: [Timer]  = []

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Battle scene ──
                ZStack(alignment: .bottom) {
                    Color.clear

                    Image(arenaAsset)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 280)
                        .clipped()

                    LinearGradient(
                        colors: [Color.black.opacity(0.35), Color.clear],
                        startPoint: .bottom,
                        endPoint: .init(x: 0.5, y: 0.5)
                    )

                    // Top-left title
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Today")
                            .font(.title.bold())
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                        Text(Date.now.formatted(date: .long, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Characters
                    HStack(alignment: .bottom, spacing: 0) {
                        ZStack {
                            Image(heroImg)
                                .resizable().scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                .frame(height: heroH)
                            if heroRedTint > 0 {
                                Image(heroImg)
                                    .resizable().scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                    .frame(height: heroH)
                                    .colorMultiply(Color(red: 1.0, green: 1.0 - heroRedTint * 0.6, blue: 1.0 - heroRedTint * 0.6))
                                    .opacity(heroRedTint)
                            }
                        }
                        .scaleEffect(x: heroFlipped ? -1 : 1, y: 1)
                        .offset(x: heroXOffset, y: heroYOff)
                        .offset(x: heroShake)

                        Spacer()

                        Image(monImg)
                            .resizable().scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                            .scaleEffect(x: monFacesHero ? -1 : 1, y: 1)
                            .offset(x: monXOffset, y: monYOff)
                            .frame(height: monH)
                            .opacity(monOpacity)
                    }
                    .frame(height: 280 - groundPad, alignment: .bottom)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .padding(.horizontal, 24)
                    .padding(.bottom, groundPad)

                    // HP bars
                    HStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Knight")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 1)
                            HPBarView(fraction: heroHP,
                                      fillImage: "recursos/16Inner_Interface/loading_green_full_bar")
                                .frame(width: 120, height: 14)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Demon")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 1)
                            HPBarView(fraction: monHP,
                                      fillImage: "recursos/16Inner_Interface/loading_red_full_bar")
                                .frame(width: 120, height: 14)
                        }
                        .opacity(monOpacity)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 52)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
                .frame(height: 280)
                .clipped()

                // ── Content below scene ──
                ScrollView {
                    VStack(spacing: 0) {
                        HStack {
                            Text("HOW IT WORKS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.orange)
                                .tracking(1)
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 12)

                        Text(displayed)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 20)

                        // Avenge button (phase 3)
                        if phase == 3 {
                            Button { startRevenge() } label: {
                                HStack(spacing: 8) {
                                    Text("⚔️")
                                    Text("Avenge!")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.7, green: 0.15, blue: 0.15))
                                .cornerRadius(14)
                            }
                            .padding(.horizontal, 24)
                            .transition(.opacity)
                        }

                        // Mode choice (phase 5+)
                        if phase >= 5 {
                            VStack(spacing: 12) {
                                Text("Choose your game mode:")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(white: 0.6))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 24)

                                // Easy
                                Button { chosenEasy = true } label: {
                                    HStack(spacing: 12) {
                                        Text("🌟")
                                            .font(.system(size: 22))
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text("Easy")
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(.white)
                                            Text("Revenges count as victories")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(white: 0.5))
                                        }
                                        Spacer()
                                        if chosenEasy == true {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding(16)
                                    .background(Color(white: chosenEasy == true ? 0.15 : 0.10))
                                    .overlay(RoundedRectangle(cornerRadius: 14)
                                        .stroke(chosenEasy == true ? Color.green.opacity(0.5) : Color(white: 0.15), lineWidth: 1.5))
                                    .cornerRadius(14)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 24)

                                // Hard
                                Button { chosenEasy = false } label: {
                                    HStack(spacing: 12) {
                                        Text("💀")
                                            .font(.system(size: 22))
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text("Hard")
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(.white)
                                            Text("A missed deadline is a defeat")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(white: 0.5))
                                        }
                                        Spacer()
                                        if chosenEasy == false {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding(16)
                                    .background(Color(white: chosenEasy == false ? 0.15 : 0.10))
                                    .overlay(RoundedRectangle(cornerRadius: 14)
                                        .stroke(chosenEasy == false ? Color.red.opacity(0.5) : Color(white: 0.15), lineWidth: 1.5))
                                    .cornerRadius(14)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 24)
                            }
                            .transition(.opacity)
                        }

                        // Final button (phase 6)
                        if phase == 6, let easy = chosenEasy {
                            Button { onContinue(easy) } label: {
                                Text("Create your own ⚔️")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.orange)
                                    .cornerRadius(14)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .transition(.opacity)
                        }

                        Spacer(minLength: 48)
                    }
                    .animation(.easeIn(duration: 0.25), value: phase)
                    .animation(.easeIn(duration: 0.2), value: chosenEasy)
                }
            }
        }
        .onAppear { setup() }
        .onDisappear { invalidateAll() }
        .onChange(of: chosenEasy) {
            if chosenEasy != nil && phase == 5 {
                after(0.3) { phase = 6 }
            }
        }
    }

    // MARK: - Logic

    private func setup() {
        startHeroAmbient(heroIdle)
        startMonAmbient(monIdle)
        typewrite(text1) {
            phase = 1
            after(0.5) { startDefeat() }
        }
    }

    private func startDefeat() {
        heroWaitTimer?.invalidate(); monWaitTimer?.invalidate()

        // Monster walks toward hero
        startMonLoop(monWalk, interval: 0.10)
        withAnimation(.linear(duration: 1.2)) { monXOffset = -160 }

        after(1.3) {
            monLoopTimer?.invalidate()
            playOnce(monAttack, interval: 0.10, update: { monImg = $0 }) {
                // Monster retreats
                monFacesHero = false
                startMonLoop(monWalk, interval: 0.10)
                withAnimation(.linear(duration: 1.6)) { monXOffset = 380 }
                after(0.9) { withAnimation(.easeIn(duration: 0.6)) { monOpacity = 0 } }

                // Start second typewriter after retreat
                after(1.8) {
                    phase = 2
                    displayed = ""
                    charIdx = 0
                    typewrite(text2) {
                        phase = 3  // show avenge button
                    }
                }
            }

            // Hero takes damage
            withAnimation(.easeOut(duration: 0.5)) { heroHP = 0.65 }
            heroShake = -14
            after(0.08) { withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) { heroShake = 0 } }
            withAnimation(.easeOut(duration: 0.07)) { heroRedTint = 0.9 }
            after(1.0) { withAnimation(.easeOut(duration: 0.8)) { heroRedTint = 0 } }
        }
    }

    private func startRevenge() {
        guard phase == 3 else { return }
        phase = 4

        // Reset monster
        monXOffset = 0; monFacesHero = true
        withAnimation(.easeIn(duration: 0.4)) { monOpacity = 1.0; monHP = 1.0 }
        startMonAmbient(monIdle)

        // Hero walks toward monster
        startHeroLoop(heroWalk, interval: 0.08)
        withAnimation(.linear(duration: 0.75)) { heroXOffset = 178 }

        after(0.88) {
            heroLoopTimer?.invalidate()
            playOnce(heroAttack, interval: 0.08, update: { heroImg = $0 }) {
                // Monster dies
                withAnimation(.easeOut(duration: 0.6)) { monHP = 0 }
                monLoopTimer?.invalidate(); monWaitTimer?.invalidate()
                playOnce(monDeath, interval: 0.10, update: { monImg = $0 }) {
                    withAnimation(.easeOut(duration: 0.5)) { monOpacity = 0 }
                }

                // Hero returns
                after(0.15) {
                    heroFlipped = true
                    startHeroLoop(heroWalk, interval: 0.08)
                    withAnimation(.linear(duration: 0.55)) { heroXOffset = 0 }
                    after(0.6) { heroFlipped = false }
                }

                // Hero jump + show choice
                after(0.75) {
                    heroLoopTimer?.invalidate()
                    playOnce(heroJump, interval: 0.08, update: { heroImg = $0 }) {
                        startHeroAmbient(heroIdle)
                        phase = 5  // show mode choice
                    }
                }
            }
        }
    }

    // MARK: - Timer helpers

    private func typewrite(_ text: String, done: @escaping () -> Void) {
        charIdx = 0
        let t = Timer.scheduledTimer(withTimeInterval: 0.038, repeats: true) { timer in
            if charIdx < text.count {
                displayed.append(text[text.index(text.startIndex, offsetBy: charIdx)])
                charIdx += 1
            } else {
                timer.invalidate()
                done()
            }
        }
        animTimers.append(t)
    }

    private func startHeroAmbient(_ frames: [String]) {
        heroLoopTimer?.invalidate(); heroWaitTimer?.invalidate()
        heroImg = frames[0]
        heroWaitTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
            var i = 1
            heroLoopTimer = Timer.scheduledTimer(withTimeInterval: 0.10, repeats: true) { t in
                if i < frames.count { heroImg = frames[i]; i += 1 }
                else { t.invalidate(); heroImg = frames[0]; startHeroAmbient(frames) }
            }
        }
    }

    private func startMonAmbient(_ frames: [String]) {
        monLoopTimer?.invalidate(); monWaitTimer?.invalidate()
        monImg = frames[0]
        monWaitTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            var i = 1
            monLoopTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { t in
                if i < frames.count { monImg = frames[i]; i += 1 }
                else { t.invalidate(); monImg = frames[0]; startMonAmbient(frames) }
            }
        }
    }

    private func startHeroLoop(_ frames: [String], interval: TimeInterval) {
        heroWaitTimer?.invalidate(); heroLoopTimer?.invalidate()
        var i = 0
        heroLoopTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            i = (i + 1) % frames.count; heroImg = frames[i]
        }
    }

    private func startMonLoop(_ frames: [String], interval: TimeInterval) {
        monWaitTimer?.invalidate(); monLoopTimer?.invalidate()
        var i = 0
        monLoopTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            i = (i + 1) % frames.count; monImg = frames[i]
        }
    }

    private func playOnce(_ frames: [String], interval: TimeInterval, update: @escaping (String) -> Void, done: @escaping () -> Void) {
        update(frames[0]); var i = 1
        let t = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if i < frames.count { update(frames[i]); i += 1 } else { timer.invalidate(); done() }
        }
        animTimers.append(t)
    }

    private func after(_ delay: TimeInterval, _ action: @escaping () -> Void) {
        let t = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in action() }
        animTimers.append(t)
    }

    private func invalidateAll() {
        heroLoopTimer?.invalidate(); heroWaitTimer?.invalidate()
        monLoopTimer?.invalidate(); monWaitTimer?.invalidate()
        animTimers.forEach { $0.invalidate() }; animTimers.removeAll()
    }
}
