import SwiftUI
import SwiftData
import Combine

struct TodayView: View {
    @Query(sort: [SortDescriptor(\MonsterTask.deadlineHour), SortDescriptor(\MonsterTask.deadlineMinute)]) private var tasks: [MonsterTask]
    @Query private var heroes: [Hero]
    @Query private var goals: [Goal90]
    @Query private var dayRecords: [DayRecord]
    @Query private var unlockedAchievements: [UnlockedAchievement]
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(\.scenePhase) private var scenePhase

    var hero: Hero? { heroes.first }
    var firstTask: MonsterTask? { tasks.first(where: { $0.isActive && !$0.isCompleted }) }

    /// Tasks that belong to today's routine (by day-of-week), regardless of isActive state.
    private var todayTasks: [MonsterTask] {
        let rawWeekday = Calendar.current.component(.weekday, from: Date())
        let todayIndex = (rawWeekday - 2 + 7) % 7   // 0=Mon … 6=Sun
        return tasks.filter { $0.daysOfWeek.isEmpty || $0.daysOfWeek.contains(todayIndex) }
    }

    // Victory (user taps Hecho)
    @State private var battleTrigger = false
    @State private var battleMonsterType: MonsterType? = nil
    @State private var currentBattleTask: MonsterTask? = nil

    // Defeat (deadline passed)
    @State private var defeatTrigger = false
    @State private var defeatMonsterType: MonsterType? = nil
    @State private var defeatQueue: [MonsterTask] = []           // sorted by deadline
    @State private var defeatInProgress: Set<PersistentIdentifier> = []
    @State private var currentDefeatTask: MonsterTask? = nil

    // Points floating animation
    @State private var floatingPoints: Int = 0
    @State private var showFloatingPoints = false

    // Periodic check while app is open
    private let checkClock = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State private var isViewVisible = false

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()

            VStack(spacing: 0) {
                if let hero {
                    ZStack {
                        BattleSceneView(
                            hero: hero,
                            ambientMonster: firstTask,
                            battleMonsterType: battleMonsterType,
                            defeatMonsterType: defeatMonsterType,
                            totalTaskCount: max(1, todayTasks.count),
                            battleTrigger: $battleTrigger,
                            defeatTrigger: $defeatTrigger,
                            onBattleComplete: {
                                // Cancel defeat notification — user beat the monster
                                if let task = currentBattleTask {
                                    NotificationService.cancelDefeatNotification(for: task)
                                    currentBattleTask = nil
                                }
                                // Award points
                                hero.points += 10
                                floatingPoints = 10
                                try? modelContext.save()
                                withAnimation(.easeOut(duration: 0.3)) { showFloatingPoints = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                                    withAnimation(.easeIn(duration: 0.3)) { showFloatingPoints = false }
                                }
                                // Check achievements that trigger on individual victories
                                AchievementService.checkAll(
                                    hero: hero,
                                    dayRecords: dayRecords,
                                    unlocked: unlockedAchievements,
                                    hasTwoRoutines: tasks.contains { $0.routineIndex == 1 },
                                    goal90Days: goals.first?.daysCompleted ?? 0,
                                    context: modelContext
                                )
                                battleMonsterType = nil
                                enqueueOverdueDefeats()
                                processNextDefeat()
                            },
                            onDefeatComplete: {
                                // Mark inactive AFTER animation — preserves animation for late entry
                                if let task = currentDefeatTask {
                                    task.isActive = false
                                    try? modelContext.save()
                                    defeatInProgress.remove(task.persistentModelID)
                                    currentDefeatTask = nil
                                }
                                defeatMonsterType = nil
                                // Re-enqueue in case new deadlines passed during this animation
                                enqueueOverdueDefeats()
                                processNextDefeat()
                            }
                        )

                        // Floating points label
                        if showFloatingPoints {
                            Text("+\(floatingPoints) pts")
                                .font(.system(size: 22, weight: .black))
                                .foregroundColor(.yellow)
                                .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 2)
                                .offset(y: showFloatingPoints ? -60 : 0)
                                .opacity(showFloatingPoints ? 1 : 0)
                                .animation(.easeOut(duration: 1.2), value: showFloatingPoints)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                .padding(.leading, 50)
                                .padding(.bottom, 60)
                        }
                    }
                } else {
                    Color(white: 0.1).frame(height: 280)
                }

                ScrollView {
                    VStack(spacing: 0) {
                        HStack {
                            Text("TODAY'S BATTLES")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.orange)
                                .tracking(1)
                            Spacer()
                            Text("\(tasks.filter { $0.isActive && !$0.isCompleted }.count) remaining")
                                .font(.system(size: 11))
                                .foregroundColor(Color(white: 0.4))
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 12)

                        ForEach(tasks.filter { $0.isActive }) { task in
                            TaskRow(task: task, onBattle: { monsterType in
                                currentBattleTask = task
                                battleMonsterType = monsterType
                                battleTrigger = true
                            })
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            isViewVisible = true
            appState.resetTasksIfNewDay(tasks: tasks, hero: hero, context: modelContext)
            enqueueOverdueDefeats()
            processNextDefeat()
        }
        .onDisappear {
            // Reset all transient battle/defeat state — BattleSceneView is destroyed
            // when switching tabs (switch selectedTab), so its internal phase resets too.
            isViewVisible = false
            defeatQueue = []
            defeatInProgress = []
            currentDefeatTask = nil
            defeatMonsterType = nil
            currentBattleTask = nil
            battleMonsterType = nil
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active, isViewVisible else { return }
            enqueueOverdueDefeats()
            processNextDefeat()
        }
        .onReceive(checkClock) { _ in
            guard isViewVisible, scenePhase == .active else { return }
            enqueueOverdueDefeats()
            processNextDefeat()
        }
    }

    /// Collects all overdue tasks not yet queued or in animation, sorted by deadline,
    /// and appends them to defeatQueue. Safe to call multiple times.
    private func enqueueOverdueDefeats() {
        guard battleMonsterType == nil, defeatMonsterType == nil else { return }
        let now = Date()
        let alreadyHandled = defeatInProgress.union(Set(defeatQueue.map { $0.persistentModelID }))
        let overdue = tasks
            .filter {
                $0.isActive && !$0.isCompleted
                && now >= $0.deadlineToday
                && !alreadyHandled.contains($0.persistentModelID)
            }
            .sorted { $0.deadlineToday < $1.deadlineToday }
        defeatQueue.append(contentsOf: overdue)
    }

    /// Pops the next defeat from the queue and starts its animation.
    /// isActive = false is saved only in onDefeatComplete, after the animation plays.
    private func processNextDefeat() {
        guard !battleTrigger && !defeatTrigger else { return }
        guard battleMonsterType == nil && defeatMonsterType == nil else { return }
        guard !defeatQueue.isEmpty else {
            checkIfDayComplete()
            return
        }
        let failedTask = defeatQueue.removeFirst()
        currentDefeatTask = failedTask
        defeatInProgress.insert(failedTask.persistentModelID)
        defeatMonsterType = failedTask.monsterType
        defeatTrigger = true
    }

    /// When all of today's tasks are resolved (completed or defeated), records the DayRecord and shows summary.
    private func checkIfDayComplete() {
        let today = todayTasks   // only this routine's tasks
        guard !today.isEmpty else { return }
        // A task is resolved if completed (victory) or deactivated by the defeat sequence
        let allResolved = today.allSatisfy { $0.isCompleted || !$0.isActive }
        guard allResolved else { return }

        // Guard: only trigger once per calendar day
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        if let last = UserDefaults.standard.object(forKey: "lastSummaryDate") as? Date,
           cal.startOfDay(for: last) == todayStart { return }
        UserDefaults.standard.set(Date(), forKey: "lastSummaryDate")

        // Build battle records — only today's routine tasks
        let battles = today.map { task -> Battle in
            let b = Battle(taskName: task.taskName,
                           monsterType: task.monsterType.rawValue,
                           deadline: task.deadlineToday)
            b.result = task.isCompleted ? .victory : .defeat
            b.completedAt = task.completedAt
            return b
        }

        let victories = battles.filter { $0.result == .victory }.count
        let record = DayRecord(date: Date(), battles: battles)
        record.dayWon = BattleService.isDayWon(victories: victories, total: battles.count)
        modelContext.insert(record)

        // Advance mountain progress if day won
        if record.dayWon, let goal = goals.first {
            goal.daysCompleted += 1
        }

        try? modelContext.save()

        // Check achievements after the day is recorded
        if let h = hero {
            AchievementService.checkAll(
                hero: h,
                dayRecords: dayRecords,
                unlocked: unlockedAchievements,
                hasTwoRoutines: tasks.contains { $0.routineIndex == 1 },
                goal90Days: goals.first?.daysCompleted ?? 0,
                context: modelContext
            )
        }

        // Show day summary after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            appState.showDaySummary = true
        }
    }
}

// MARK: - Battle Phase

private enum BattlePhase {
    // Idle
    case idle
    // Victory
    case approaching, attacking, monsterDying, celebrating, returning
    // Defeat
    case defeatApproaching, defeatAttacking, defeatRetreating
}

// MARK: - Battle Scene

struct BattleSceneView: View {
    let hero: Hero
    let ambientMonster: MonsterTask?
    let battleMonsterType: MonsterType?
    let defeatMonsterType: MonsterType?
    let totalTaskCount: Int
    @Binding var battleTrigger: Bool
    @Binding var defeatTrigger: Bool
    let onBattleComplete: () -> Void
    let onDefeatComplete: () -> Void

    @State private var monsterHP: Double = 1.0

    // Hero
    @State private var heroXOffset: CGFloat = 0
    @State private var heroFlipped: Bool = false
    @State private var heroImage: String = ""
    @State private var heroHurtAmount: Double = 0  // 0 = normal, 1 = full red tint
    @State private var heroShake: CGFloat = 0      // recoil offset

    // Monster
    @State private var sceneMonsterType: MonsterType? = nil
    @State private var monsterImage: String = ""
    @State private var monsterXOffset: CGFloat = 0
    @State private var monsterOpacity: Double = 1
    @State private var monsterFacesHero: Bool = true  // false = faces right (retreating)

    @State private var phase: BattlePhase = .idle

    // Monster intro overlay
    @State private var showIntro: Bool = false
    @State private var introMonsterName: String = ""
    @State private var introDeadline: String = ""

    // Timers
    @State private var heroWaitTimer: Timer?
    @State private var heroFrameTimer: Timer?
    @State private var monsterWaitTimer: Timer?
    @State private var monsterFrameTimer: Timer?
    @State private var walkLoopTimer: Timer?       // hero walk loop
    @State private var monsterLoopTimer: Timer?    // monster walk loop (approach/retreat/walk-in)
    @State private var battleDelayTimer: Timer?    // one-shot sequencer
    @State private var hurtLingerTimer: Timer?     // fades hero tint after 6s

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear   // forces ZStack to adopt the offered 280pt height
            Image(hero.battleground.assetName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: 280)
                .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.35), Color.clear],
                startPoint: .bottom,
                endPoint: .init(x: 0.5, y: 0.5)
            )

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

            HStack(alignment: .bottom, spacing: 0) {
                // Hero
                Image(heroImage.isEmpty ? hero.heroClass.idleFrames[0] : heroImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .colorMultiply(Color(
                        red: 1.0,
                        green: 1.0 - heroHurtAmount * 0.6,
                        blue: 1.0 - heroHurtAmount * 0.6
                    ))
                    .scaleEffect(x: heroFlipped ? -1 : 1, y: 1)
                    .offset(x: heroXOffset + heroShake, y: hero.heroClass.sceneYOffset)
                    .frame(height: hero.heroClass.sceneHeight)

                Spacer()

                // Monster — opacity instead of if/else to avoid layout shifts
                if let mt = sceneMonsterType {
                    Image(monsterImage.isEmpty ? mt.idleFrames[0] : monsterImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .scaleEffect(x: monsterFacesHero ? -1 : 1, y: 1)
                        .offset(x: monsterXOffset, y: mt.sceneYOffset)
                        .frame(height: mt.sceneHeight)
                        .opacity(monsterOpacity)
                }
            }
            // Fixed height = scene height minus ground padding, so the HStack never
            // expands the ZStack beyond 280pt regardless of sprite size.
            .frame(height: 280 - hero.battleground.groundPadding, alignment: .bottom)
            .frame(maxWidth: .infinity)
            .clipped()
            .padding(.horizontal, 24)
            .padding(.bottom, hero.battleground.groundPadding)

            // HP bars — top of scene, one per side
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(hero.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 1)
                    HPBarView(fraction: hero.hp, fillImage: "recursos/16Inner_Interface/loading_green_full_bar")
                        .frame(width: 120, height: 14)
                }

                Spacer()

                if let mt = sceneMonsterType {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(mt.displayName)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 1)
                        HPBarView(fraction: monsterHP, fillImage: "recursos/16Inner_Interface/loading_red_full_bar")
                            .frame(width: 120, height: 14)
                    }
                    .opacity(monsterOpacity)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 52)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            // Monster intro overlay
            if showIntro {
                ZStack {
                    Color.black.opacity(0.55)
                    VStack(spacing: 6) {
                        Text("⚔️ NEW ENEMY")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.orange)
                            .tracking(2)
                        Text(introMonsterName)
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.white)
                        Text("Until \(introDeadline)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(white: 0.7))
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showIntro)
        .frame(height: 280)
        .clipped()
        .onAppear {
            heroImage = hero.heroClass.idleFrames[0]
            sceneMonsterType = ambientMonster?.monsterType
            if let mt = sceneMonsterType { monsterImage = mt.idleFrames[0] }
            startAmbientHero()
            startAmbientMonster()
        }
        .onDisappear { stopAllTimers() }
        .onChange(of: battleTrigger) { _, newVal in
            guard newVal else { return }
            battleTrigger = false
            startBattle()
        }
        .onChange(of: defeatTrigger) { _, newVal in
            guard newVal else { return }
            defeatTrigger = false
            startDefeat()
        }
        .onChange(of: ambientMonster?.id) { _, _ in
            // Only walk in the new monster if no defeat is already queued.
            // When defeatMonsterType != nil, startDefeat() will handle putting
            // the monster on screen — calling walkInNextMonster at the same time
            // causes visual conflicts (both fight over monsterXOffset/sprite).
            guard phase == .idle, defeatMonsterType == nil else { return }
            walkInNextMonster()
        }
    }

    // MARK: - Ambient

    private func startAmbientHero() {
        guard phase == .idle else { return }
        heroWaitTimer?.invalidate()
        let frames = hero.heroClass.jumpFrames
        let idle = hero.heroClass.idleFrames[0]
        heroWaitTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
            var idx = 0
            heroImage = frames[0]
            heroFrameTimer?.invalidate()
            heroFrameTimer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { t in
                idx += 1
                if idx < frames.count {
                    heroImage = frames[idx]
                } else {
                    t.invalidate()
                    heroImage = idle
                    startAmbientHero()
                }
            }
        }
    }

    private func startAmbientMonster() {
        guard phase == .idle, let mt = sceneMonsterType else { return }
        monsterWaitTimer?.invalidate()
        let frames = mt.walkFrames
        let idle = mt.idleFrames[0]
        monsterWaitTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
            var idx = 0
            monsterImage = frames[0]
            monsterFrameTimer?.invalidate()
            monsterFrameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
                idx += 1
                if idx < frames.count {
                    monsterImage = frames[idx]
                } else {
                    t.invalidate()
                    monsterImage = idle
                    startAmbientMonster()
                }
            }
        }
    }

    // MARK: - Victory sequence

    private func startBattle() {
        guard phase == .idle, let mt = battleMonsterType else { return }
        stopAllTimers()
        phase = .approaching

        if sceneMonsterType == nil || sceneMonsterType == mt {
            // Monster already on screen (or none) — fight directly
            sceneMonsterType = mt
            monsterImage = mt.idleFrames[0]
            monsterXOffset = 0
            monsterOpacity = 1
            monsterFacesHero = true
            beginApproach(mt: mt)
        } else {
            // Different monster on screen — walk it out, then walk battle monster in
            walkOutCurrentMonster {
                walkInBattleMonster(mt: mt) {
                    beginApproach(mt: mt)
                }
            }
        }
    }

    private func walkOutCurrentMonster(then: @escaping () -> Void) {
        guard let currentMT = sceneMonsterType else { then(); return }
        monsterFacesHero = false  // face right to exit
        let duration = 1.4
        startMonsterWalkLoop(frames: currentMT.walkFrames)
        withAnimation(.linear(duration: duration)) { monsterXOffset = 380 }
        battleDelayTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            stopMonsterWalkLoop()
            monsterOpacity = 0
            monsterFacesHero = true
            then()
        }
    }

    private func walkInBattleMonster(mt: MonsterType, then: @escaping () -> Void) {
        sceneMonsterType = mt
        monsterImage = mt.walkFrames[0]
        monsterXOffset = 320
        monsterOpacity = 1
        monsterFacesHero = true
        let duration = 1.2
        withAnimation(.linear(duration: duration)) { monsterXOffset = 0 }
        startMonsterWalkLoop(frames: mt.walkFrames)
        battleDelayTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            stopMonsterWalkLoop()
            monsterImage = mt.idleFrames[0]
            monsterXOffset = 0
            then()
        }
    }

    private func beginApproach(mt: MonsterType) {
        let walkFrames = hero.heroClass.walkFrames
        let approachDuration = Double(walkFrames.count) * 0.08 * 3
        startHeroWalkLoop(frames: walkFrames)
        withAnimation(.linear(duration: approachDuration)) { heroXOffset = 180 }
        battleDelayTimer = Timer.scheduledTimer(withTimeInterval: approachDuration, repeats: false) { _ in
            attackPhase(mt: mt)
        }
    }

    private func attackPhase(mt: MonsterType) {
        phase = .attacking
        stopHeroWalkLoop()
        let chosenAttack = hero.heroClass.allAttackSets.randomElement() ?? hero.heroClass.allAttackSets[0]
        playOnce(frames: chosenAttack, speed: 0.08, setCurrent: { heroImage = $0 }) {
            heroImage = hero.heroClass.idleFrames[0]
            monsterDyingPhase(mt: mt)
        }
    }

    private func monsterDyingPhase(mt: MonsterType) {
        phase = .monsterDying
        let deathDuration = Double(mt.deathFrames.count) * 0.1
        withAnimation(.linear(duration: deathDuration)) { monsterHP = 0 }
        playOnce(frames: mt.deathFrames, speed: 0.1, setCurrent: { monsterImage = $0 }) {
            monsterOpacity = 0
            celebratePhase()
        }
    }

    private func celebratePhase() {
        phase = .celebrating
        playOnce(frames: hero.heroClass.jumpFrames, speed: 0.07, setCurrent: { heroImage = $0 }) {
            heroImage = hero.heroClass.idleFrames[0]
            returnPhase()
        }
    }

    private func returnPhase() {
        phase = .returning
        heroFlipped = true

        let walkFrames = hero.heroClass.walkFrames
        let returnDuration = Double(walkFrames.count) * 0.08 * 3

        startHeroWalkLoop(frames: walkFrames)
        withAnimation(.linear(duration: returnDuration)) { heroXOffset = 0 }

        battleDelayTimer = Timer.scheduledTimer(withTimeInterval: returnDuration, repeats: false) { _ in
            stopHeroWalkLoop()
            heroImage = hero.heroClass.idleFrames[0]
            heroFlipped = false
            phase = .idle
            onBattleComplete()
            startAmbientHero()
            // walkInNextMonster is triggered by onChange(of: ambientMonster?.id) to avoid
            // conflicts when a defeat is also pending at the same time
        }
    }

    // MARK: - Defeat sequence

    private func startDefeat() {
        guard phase == .idle, let mt = defeatMonsterType else { return }
        stopAllTimers()
        showIntro = false  // clear any pending intro overlay from a previous walk-in
        sceneMonsterType = mt
        monsterImage = mt.idleFrames[0]
        monsterXOffset = 0
        monsterOpacity = 1
        monsterFacesHero = true
        phase = .defeatApproaching

        let approachDuration = 1.2
        startMonsterWalkLoop(frames: mt.walkFrames)
        withAnimation(.linear(duration: approachDuration)) { monsterXOffset = -160 }
        battleDelayTimer = Timer.scheduledTimer(withTimeInterval: approachDuration, repeats: false) { _ in
            defeatAttackPhase(mt: mt)
        }
    }

    private func defeatAttackPhase(mt: MonsterType) {
        phase = .defeatAttacking
        stopMonsterWalkLoop()
        playOnce(frames: mt.attackFrames, speed: 0.1, setCurrent: { monsterImage = $0 }) {
            monsterImage = mt.idleFrames[0]

            // Impact: strong red tint + shake left
            withAnimation(.easeIn(duration: 0.08)) {
                heroHurtAmount = 1.0
                heroShake = -14
            }
            // Recoil right
            battleDelayTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                withAnimation(.easeOut(duration: 0.1)) { heroShake = 7 }
                battleDelayTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: false) { _ in
                    withAnimation(.spring(duration: 0.15)) { heroShake = 0 }
                    // Reduce hero HP by 1/totalTaskCount
                    let damage = 1.0 / Double(totalTaskCount)
                    withAnimation(.easeOut(duration: 0.4)) {
                        hero.hp = max(0, hero.hp - damage)
                    }
                    // Settle to linger tint (~0.4 of full red) — stays for 6s
                    withAnimation(.easeOut(duration: 0.35)) { heroHurtAmount = 0.45 }

                    // Schedule fade-out after 6s
                    hurtLingerTimer?.invalidate()
                    hurtLingerTimer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { _ in
                        withAnimation(.easeOut(duration: 1.5)) { heroHurtAmount = 0 }
                    }

                    defeatRetreatPhase(mt: mt)
                }
            }
        }
    }

    private func defeatRetreatPhase(mt: MonsterType) {
        phase = .defeatRetreating
        monsterFacesHero = false  // flip to face right (walking away)
        let retreatDuration = 2.0
        startMonsterWalkLoop(frames: mt.walkFrames)
        withAnimation(.linear(duration: retreatDuration)) { monsterXOffset = 380 }
        battleDelayTimer = Timer.scheduledTimer(withTimeInterval: retreatDuration, repeats: false) { _ in
            stopMonsterWalkLoop()
            monsterOpacity = 0
            monsterFacesHero = true
            phase = .idle
            onDefeatComplete()
            startAmbientHero()
            // walkInNextMonster is triggered by onChange(of: ambientMonster?.id) to avoid
            // conflicts when another defeat is also pending at the same time
        }
    }

    // MARK: - Shared helpers

    /// Walks the next pending monster in from the right after hero is back in position.
    private func walkInNextMonster() {
        guard let nextMT = ambientMonster?.monsterType else { return }
        sceneMonsterType = nextMT
        monsterImage = nextMT.walkFrames[0]
        monsterXOffset = 320
        monsterOpacity = 1
        monsterFacesHero = true
        monsterHP = 1.0   // new monster, full health
        let walkInDuration = 1.4
        withAnimation(.linear(duration: walkInDuration)) { monsterXOffset = 0 }
        startMonsterWalkLoop(frames: nextMT.walkFrames)
        monsterWaitTimer = Timer.scheduledTimer(withTimeInterval: walkInDuration, repeats: false) { _ in
            stopMonsterWalkLoop()
            monsterXOffset = 0
            if let mt = sceneMonsterType { monsterImage = mt.idleFrames[0] }
            startAmbientMonster()
            // Show intro overlay for the new monster
            if let next = ambientMonster {
                introMonsterName = next.monsterType.displayName
                introDeadline = next.deadlineFormatted
                withAnimation(.easeIn(duration: 0.25)) { showIntro = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeOut(duration: 0.4)) { showIntro = false }
                }
            }
        }
    }

    // MARK: - Timer helpers

    private func playOnce(frames: [String], speed: Double, setCurrent: @escaping (String) -> Void, onComplete: @escaping () -> Void) {
        battleDelayTimer?.invalidate()
        var idx = 0
        setCurrent(frames[0])
        battleDelayTimer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { t in
            idx += 1
            if idx < frames.count {
                setCurrent(frames[idx])
            } else {
                t.invalidate()
                onComplete()
            }
        }
    }

    private func startHeroWalkLoop(frames: [String]) {
        walkLoopTimer?.invalidate()
        var idx = 0
        heroImage = frames[0]
        walkLoopTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
            idx = (idx + 1) % frames.count
            heroImage = frames[idx]
        }
    }

    private func stopHeroWalkLoop() {
        walkLoopTimer?.invalidate()
        walkLoopTimer = nil
    }

    private func startMonsterWalkLoop(frames: [String]) {
        monsterLoopTimer?.invalidate()
        var idx = 0
        monsterImage = frames[0]
        monsterLoopTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            idx = (idx + 1) % frames.count
            monsterImage = frames[idx]
        }
    }

    private func stopMonsterWalkLoop() {
        monsterLoopTimer?.invalidate()
        monsterLoopTimer = nil
    }

    private func stopMonsterAmbientTimers() {
        monsterWaitTimer?.invalidate(); monsterWaitTimer = nil
        monsterFrameTimer?.invalidate(); monsterFrameTimer = nil
    }

    private func stopAllTimers() {
        heroWaitTimer?.invalidate(); heroWaitTimer = nil
        heroFrameTimer?.invalidate(); heroFrameTimer = nil
        monsterWaitTimer?.invalidate(); monsterWaitTimer = nil
        monsterFrameTimer?.invalidate(); monsterFrameTimer = nil
        walkLoopTimer?.invalidate(); walkLoopTimer = nil
        monsterLoopTimer?.invalidate(); monsterLoopTimer = nil
        battleDelayTimer?.invalidate(); battleDelayTimer = nil
        hurtLingerTimer?.invalidate(); hurtLingerTimer = nil
    }
}

// MARK: - HP Bar

struct HPBarView: View {
    let fraction: Double   // 0.0–1.0
    let fillImage: String

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Image("recursos/16Inner_Interface/hp_bar_bg")
                    .resizable()
                    .frame(width: geo.size.width, height: geo.size.height)

                Image(fillImage)
                    .resizable()
                    .frame(width: geo.size.width * max(0, min(1, fraction)), height: geo.size.height)
                    .clipped()

                Image("recursos/16Inner_Interface/hp_bar_border")
                    .resizable()
                    .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

// MARK: - Task Row

struct TaskRow: View {
    let task: MonsterTask
    let onBattle: (MonsterType) -> Void
    @Environment(\.modelContext) private var modelContext

    private let clock = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    @State private var now = Date.now

    private var deadlinePassed: Bool { now >= task.deadlineToday }
    private var canComplete: Bool { !task.isCompleted && !deadlinePassed }

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(task.isCompleted ? Color.green : (deadlinePassed ? Color.red.opacity(0.5) : Color.orange.opacity(0.8)))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.taskName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(deadlinePassed && !task.isCompleted ? Color(white: 0.4) : .white)
                Text(task.monsterType.displayName)
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.35))
            }

            Spacer()

            HStack(spacing: 10) {
                Text(task.deadlineFormatted)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(
                        task.isCompleted ? Color(white: 0.35) :
                        deadlinePassed   ? Color(white: 0.25) :
                                           Color(white: 0.45)
                    )
                    .monospacedDigit()

                if task.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.green)
                } else if canComplete {
                    Button {
                        let mt = task.monsterType
                        task.isCompleted = true
                        task.completedAt = Date.now
                        try? modelContext.save()
                        onBattle(mt)
                    } label: {
                        Text("Done ✓")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color.orange)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 13)
        .onReceive(clock) { now = $0 }

        Rectangle()
            .fill(Color(white: 1, opacity: 0.06))
            .frame(height: 1)
            .padding(.horizontal, 24)
    }
}
