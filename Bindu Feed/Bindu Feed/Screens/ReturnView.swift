import SwiftUI

// THE RETURN — re-meeting a sealed story (Wave 5). Eight movements as one flow:
// Summons → (the fall) → Aged Room → Story Again → Record → Field Settled → Rings
// → Reply → Sealing. The story is the one unaged thing; everything around it wears
// the patina. He adds his own ring; the story does not move.
//
// The past self is NEVER regenerated — the Reply quotes his verbatim sealed words
// via the forward detector, or shows the four native words (ReturnCanon.replyPrompt).
//
// The story shown, its record, its sealed self, and its "how long ago" are all REAL —
// the returned story the user actually sealed (ReturnStoryData, built by the store), or
// canon only when nothing is reachable. The ring (the reply) is PERSISTED — a durable
// Ash-comment write, the same retry-queued path Compose uses.
//
// Wave-5 scope (flagged): the aged patina is a saturate/warm treatment on the aged
// elements, not the full canvas strata; the fall is a fade (the axis fall ships Wave 6).

private enum ReturnStage { case summons, fall, room, story, record, field, rings, reply, sealed }

struct ReturnView: View {
    @Binding var path: [FeedRoute]
    var storyData: ReturnStoryData = .canon        // TODAY's sealed story (rotating), or canon
    @EnvironmentObject private var soundEngine: SoundEngine
    @EnvironmentObject private var store: FeedStore

    @State private var stage: ReturnStage = .summons
    @State private var anewShown = 0
    @State private var ringAdded = false
    @State private var replyText = ""
    @State private var sealPhase = 0
    @State private var fallZoom: CGFloat = 1        // the inward rush of the fall
    @State private var fallFade: Double = 1

    // The Reply quotes his real prior words (never generated) — from THIS story's sealed self.
    private var prompt: ReturnCanon.ReplyPrompt { ReturnCanon.replyPrompt(prior: storyData.sealedSelf) }

    var body: some View {
        ZStack {
            Color(hex: "#08070B").ignoresSafeArea()
            // The strata — the aged rings, the seed, the settling dust — living behind every
            // movement (return-strata.js), not a static wash. His own returns, warmed by age.
            ReturnStrata(rings: 3, age: 0.5)

            content.transition(.opacity)

            // Always a quiet way out — never trapped in the Return.
            VStack {
                HStack {
                    Button { if !path.isEmpty { $path.popToRootDissolve() } } label: {
                        Text("‹ leave").font(.spaceMono(9)).tracking(2)
                            .foregroundStyle(ReturnCanon.ashColor.opacity(0.5)).padding(16)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .sonicContext(.base)
    }

    @ViewBuilder private var content: some View {
        switch stage {
        case .summons: summons
        case .fall:    fall
        case .room:    room
        case .story:   storyAgain
        case .record:  record
        case .field:   fieldAnew
        case .rings:   rings
        case .reply:   reply
        case .sealed:  sealing
        }
    }

    private func cross(_ hz: Double, _ next: ReturnStage) {
        soundEngine.riteThreshold(hz: hz, dur: 5)
        withAnimation(.easeInOut(duration: 1.1)) { stage = next }
    }

    // I · Summons
    private var summons: some View {
        centered {
            Text(ReturnCanon.summonsKicker).font(.spaceMono(9)).tracking(2).foregroundStyle(BinduTheme.inkTertiary)
            Text(ReturnCanon.summonsLine).font(.lora(14)).italic().foregroundStyle(BinduTheme.inkSecondary)
            Text(storyData.title).font(.lora(26, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary)
                .multilineTextAlignment(.center).padding(.top, 6)
            // The sealed line, cut in — debossed, not printed (the seal is pressed, not written).
            Text("\(storyData.codexId) · sealed \(storyData.sealedWhen)")
                .font(.spaceMono(9)).tracking(1).foregroundStyle(BinduTheme.inkTertiary)
                .shadow(color: .black.opacity(0.55), radius: 0, x: 0, y: 1)
            if !storyData.firstMet.isEmpty {
                Text("you first met this · \(storyData.firstMet)")
                    .font(.spaceMono(9)).tracking(1).foregroundStyle(ReturnCanon.ashColor.opacity(0.6))
            }
            hint(ReturnCanon.summonsHint)
        }
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.easeInOut(duration: 1.2)) { stage = .fall } }
    }

    // The fall — an inward rush toward the sealed story: the mark accelerates past you as
    // you drop in, the strata behind widening. (A localized inward-zoom; the full axis-driven
    // fall shares the Universe's four-layer descent and ships with the Wave-6 axis.)
    private var fall: some View {
        centered {
            Text("\(storyData.codexId)")
                .font(.spaceMono(10)).tracking(2).foregroundStyle(ReturnCanon.ashColor.opacity(0.6))
        }
        .scaleEffect(fallZoom)
        .opacity(fallFade)
        .onAppear {
            soundEngine.riteBowl(hz: 168)
            fallZoom = 0.6; fallFade = 0.2
            withAnimation(.easeIn(duration: 2.4)) { fallZoom = 3.2; fallFade = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                fallZoom = 1; fallFade = 1
                withAnimation(.easeInOut(duration: 1.2)) { stage = .room }
            }
        }
    }

    // II · Aged Room
    private var room: some View {
        centered {
            Text(ReturnCanon.roomRemembers(room: storyData.roomName)).font(.spaceMono(9)).tracking(1.5).foregroundStyle(BinduTheme.inkTertiary)
            Text(ReturnCanon.roomLine(when: storyData.sealedWhen)).font(.lora(16)).lineSpacing(6).foregroundStyle(BinduTheme.inkSecondary)
                .multilineTextAlignment(.center).padding(.top, 10)
            hint(ReturnCanon.roomHint)
        }
        .contentShape(Rectangle())
        .onTapGesture { cross(126, .story) }
    }

    // III · The Story, Again (the one unaged thing)
    private var storyAgain: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text(storyData.title).font(.lora(23, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary).padding(.top, 56)
                Text(ReturnCanon.storyUnchanged).font(.loraItalic(13)).foregroundStyle(BinduTheme.inkTertiary)
                ForEach(Array(storyData.body.enumerated()), id: \.offset) { _, p in
                    Text(p).font(.lora(16)).lineSpacing(7).foregroundStyle(BinduTheme.inkPrimary)
                }
                Button { cross(168, .record) } label: {
                    Text(ReturnCanon.storyButton).font(.loraItalic(14)).foregroundStyle(ReturnCanon.ashColor).padding(.vertical, 20)
                }
                Color.clear.frame(height: 60)
            }
            .padding(.horizontal, 34)
        }
        .scrollIndicators(.hidden)
    }

    // IV · The Record (the gathering, pressed; the self he sealed, in ash)
    private var record: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(ReturnCanon.recordIntro).font(.lora(15)).italic().foregroundStyle(BinduTheme.inkSecondary).padding(.top, 56)
                ForEach(storyData.record) { v in
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(v.name) · \(v.role)").font(.spaceMono(9)).tracking(0.5).foregroundStyle(v.color.opacity(0.7))
                        Text(v.lines.first ?? "").font(.lora(14)).lineSpacing(5).foregroundStyle(BinduTheme.inkSecondary)
                    }
                    .saturation(0.5).brightness(-0.04)     // .pressed — the aged gathering
                }
                Text(ReturnCanon.recordSealedYou(when: storyData.sealedWhen)).font(.spaceMono(9)).tracking(0.5).foregroundStyle(ReturnCanon.ashColor).padding(.top, 8)
                Text(storyData.sealedSelf)
                    .font(.loraItalic(15)).lineSpacing(6)
                    .foregroundStyle(ReturnCanon.ashColor)
                    .saturation(0.85)                       // .dried — the past self, ash terracotta
                    .shadow(color: .black.opacity(0.55), radius: 0, x: 0, y: 1)
                Text(ReturnCanon.recordSettled).font(.loraItalic(13)).foregroundStyle(BinduTheme.inkTertiary).padding(.top, 6)
                Button { cross(189, .field) } label: {
                    Text(ReturnCanon.recordButton).font(.loraItalic(14)).foregroundStyle(ReturnCanon.ashColor).padding(.vertical, 18)
                }
                Color.clear.frame(height: 40)
            }
            .padding(.horizontal, 34)
        }
        .scrollIndicators(.hidden)
    }

    // V · The Field, Settled (1–2 voices speak anew, living ink)
    private var fieldAnew: some View {
        centered {
            Text(ReturnCanon.fieldAnewTitle).font(.spaceMono(9)).tracking(1.5).foregroundStyle(BinduTheme.inkTertiary)
            ForEach(Array(storyData.anew.prefix(max(1, anewShown)).enumerated()), id: \.offset) { _, v in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(v.name) · now").font(.spaceMono(9)).tracking(0.5).foregroundStyle(BinduTheme.inkTertiary)
                    Text(v.line).font(.lora(16)).lineSpacing(6).foregroundStyle(BinduTheme.inkPrimary)
                }
                .transition(.opacity).padding(.top, 8)
            }
            Text("\(min(max(1, anewShown), storyData.anew.count)) / \(storyData.anew.count) · the rest keep their record")
                .font(.spaceMono(8)).tracking(1).foregroundStyle(BinduTheme.inkTertiary).padding(.top, 10)
        }
        .contentShape(Rectangle())
        .onAppear { if anewShown == 0 { anewShown = 1; soundEngine.riteVoice(hz: 285, dur: 7) } }
        .onTapGesture {
            if anewShown < storyData.anew.count {
                withAnimation(.easeInOut(duration: 1.2)) { anewShown += 1 }
                soundEngine.riteVoice(hz: 396, dur: 7)
            } else {
                cross(252, .rings)
            }
        }
    }

    // VI · The Rings
    private var rings: some View {
        centered {
            Text(ReturnCanon.ringsTitle).font(.spaceMono(9)).tracking(1.5).foregroundStyle(BinduTheme.inkTertiary)
            ReturnRings(newRing: false, priorRings: storyData.returnCount).frame(height: 180)
            Text(ReturnCanon.ringsBody).font(.lora(14)).lineSpacing(6).foregroundStyle(BinduTheme.inkSecondary)
                .multilineTextAlignment(.center)
            hint(ReturnCanon.ringsHint)
        }
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.easeInOut(duration: 1.0)) { stage = .reply } }
    }

    // VII · The Reply (quote-or-four-words; his words, never generated)
    private var reply: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("◉ you, now · in reply to you, \(storyData.sealedWhen)")
                .font(.spaceMono(9)).tracking(0.5).foregroundStyle(ReturnCanon.ashColor)
            if let frame = prompt.frame, let quote = prompt.quote {
                Text(frame).font(.spaceMono(9)).tracking(1).foregroundStyle(BinduTheme.inkTertiary)
                Text("\u{201C}\(quote)\u{201D}")
                    .font(.loraItalic(15)).foregroundStyle(ReturnCanon.ashColor).saturation(0.85)
                    .multilineTextAlignment(.center)
            }
            Text(prompt.ask).font(.lora(18)).italic().foregroundStyle(BinduTheme.inkPrimary)
            TextEditor(text: $replyText)
                .font(.lora(15)).foregroundStyle(BinduTheme.inkPrimary)
                .scrollContentBackground(.hidden).frame(height: 120)
                .tint(ReturnCanon.ashColor)
                .padding(8).background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
                .overlay(alignment: .topLeading) {
                    if replyText.isEmpty {
                        Text(ReturnCanon.replyPlaceholder).font(.lora(15)).foregroundStyle(BinduTheme.inkTertiary)
                            .padding(.horizontal, 13).padding(.vertical, 16).allowsHitTesting(false)
                    }
                }
            Text(ReturnCanon.replyKept).font(.spaceMono(9)).tracking(1).foregroundStyle(BinduTheme.inkTertiary)
            Button {
                guard !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                addRing()
            } label: {
                Text(ReturnCanon.addTheRing).font(.lora(16))
                    .foregroundStyle(replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                     ? ReturnCanon.ashColor.opacity(0.35) : ReturnCanon.ashColor)
            }
            Spacer()
        }
        .padding(.horizontal, 34)
    }

    private func addRing() {
        soundEngine.riteBowl(hz: 210)          // the ring's bowl
        // KEEP the ring. The reply is the user's new response to their past self — written
        // as a durable Ash comment on the returned story (the same robust, retry-queued
        // path Compose uses). Before, "The ring is added" was a lie: nothing persisted.
        let text = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty, !storyData.storyId.isEmpty {
            let storyId = storyData.storyId
            Task { await store.postComment(storyId: storyId, body: text, parentId: nil) }
        }
        withAnimation(.easeInOut(duration: 1.0)) { stage = .sealed }
    }

    // VIII · The Sealing
    private var sealing: some View {
        centered {
            Text("◉ you, now · today").font(.spaceMono(9)).tracking(0.5).foregroundStyle(ReturnCanon.ashColor)
            ReturnRings(newRing: true, priorRings: storyData.returnCount).frame(height: 150)
            if sealPhase == 0 {
                Text(ReturnCanon.sealPlain).font(.loraItalic(14)).foregroundStyle(BinduTheme.inkSecondary).multilineTextAlignment(.center)
            }
            if sealPhase >= 1 {
                Text(ReturnCanon.sealAdded).font(.lora(17, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary).transition(.opacity)
            }
            if sealPhase >= 2 {
                VStack(spacing: 14) {
                    Text(ReturnCanon.sealDwell1).font(.lora(13)).italic().foregroundStyle(BinduTheme.inkTertiary).multilineTextAlignment(.center)
                    Text(ReturnCanon.sealDwell2).font(.lora(13)).italic().foregroundStyle(BinduTheme.inkTertiary).multilineTextAlignment(.center)
                    Button { if !path.isEmpty { $path.popToRootDissolve() } } label: {
                        Text(ReturnCanon.archiveWaits).font(.spaceMono(10)).tracking(2).foregroundStyle(ReturnCanon.ashColor).padding(.top, 8)
                    }
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) { withAnimation(.easeInOut(duration: 1.2)) { sealPhase = 1 } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.6) { withAnimation(.easeInOut(duration: 1.4)) { sealPhase = 2 } }
        }
    }

    // MARK: - Helpers

    private func centered<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        VStack(spacing: 16) { Spacer(); content(); Spacer() }
            .padding(.horizontal, 40).frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    private func hint(_ text: String) -> some View {
        Text(text).font(.spaceMono(9)).tracking(2).foregroundStyle(BinduTheme.inkTertiary).modifier(RiteBreathe()).padding(.top, 20)
    }
}

// The strata: a seed with a ring for EACH return he sealed here (not a fixed two), the
// oldest dimmest; the new ring — the reply he adds today — is the plainest, growing.
private struct ReturnRings: View {
    let newRing: Bool
    var priorRings: Int = 2
    @State private var grow: CGFloat = 0

    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2, cy = size.height / 2
            let n = max(1, priorRings)
            // Keep the whole strata inside the frame however many rings there are.
            let gap = min(size.width, size.height) * 0.45 / Double(n + 1)
            // The seed.
            ctx.fill(Path(ellipseIn: CGRect(x: cx - 4, y: cy - 4, width: 8, height: 8)),
                     with: .color(Color(hex: "#E4DCC8")))
            // Past rings — aged (amber), dimming outward toward the oldest.
            for i in 1...n {
                let r = 8 + Double(i) * gap
                let age = Double(i) / Double(n + 1)               // 0 newest-of-old … →1 oldest
                ctx.stroke(Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                           with: .color(Color(hex: "#D0A048").opacity(0.5 - age * 0.30)), lineWidth: 1)
            }
            // The new ring — today's reply, the plainest thing on the screen, growing.
            if newRing {
                let r = (8 + Double(n + 1) * gap) * grow
                ctx.stroke(Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                           with: .color(Color(hex: "#E4DCC8").opacity(0.85 * grow)), lineWidth: 1.2)
            }
        }
        .onAppear {
            if newRing { withAnimation(.easeOut(duration: 2.6)) { grow = 1 } }
        }
    }
}
