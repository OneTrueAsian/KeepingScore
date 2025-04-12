import SwiftUI

struct NewTournamentSetupView: View {
    @State private var tournamentTitle: String = ""
    @State private var numberOfTeamsText: String = ""
    @State private var teamNames: [String] = []
    @State private var showTeamFields: Bool = false
    @State private var navigateToBracket = false
    @State private var autoGenerateMatchups: Bool = true
    @State private var showInfo = false

    @FocusState private var focusedField: Int?

    var numberOfTeams: Int {
        Int(numberOfTeamsText) ?? 0
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("New Tournament Setup")
                            .font(.title)
                            .bold()

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tournament Name")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextField("Tournament Title", text: $tournamentTitle)
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.done)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Number of Teams")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextField("Number of Teams", text: $numberOfTeamsText)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.done)
                                .onChange(of: numberOfTeamsText) {
                                    updateTeamNameFields()
                                }
                        }

                        Toggle(isOn: $autoGenerateMatchups) {
                            HStack {
                                Text("Auto-generate matchups")
                                Button(action: { showInfo = true }) {
                                    Image(systemName: "info.circle")
                                }
                                .alert("Auto-generate matchups", isPresented: $showInfo) {
                                    Button("OK", role: .cancel) { }
                                } message: {
                                    Text("If enabled, the system will randomly assign matchups for each round.")
                                }
                            }
                        }

                        if showTeamFields {
                            Text("Teams")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            ForEach(0..<teamNames.count, id: \.self) { index in
                                TextField("Team \(index + 1) Name", text: $teamNames[index])
                                    .textFieldStyle(.roundedBorder)
                                    .submitLabel(.done)
                                    .focused($focusedField, equals: index)
                            }
                        }

                        Spacer(minLength: 60)
                    }
                    .padding()
                }

                
                .safeAreaInset(edge: .bottom) {
                    Button("Continue") {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .medium
                        dateFormatter.timeStyle = .none
                        
                        let tournament = TournamentResult(
                            title: tournamentTitle,
                            date: dateFormatter.string(from: Date()),
                            teams: teamNames.map { RankedTeam(name: $0, score: 0, placement: 0) }
                        )
                        
                        TournamentResult.save(tournament)
                        navigateToBracket = true
                    }
                    .disabled(!isFormValid())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid() ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal)
                }

                .navigationDestination(isPresented: $navigateToBracket) {
                    TournamentBracketView(teams: teamNames, autoGenerate: autoGenerateMatchups)
                }
                .navigationTitle("New Tournament")
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }

    func updateTeamNameFields() {
        let count = numberOfTeams
        if count > 0 {
            if count != teamNames.count {
                teamNames = Array(repeating: "", count: count)
            }
            showTeamFields = true
        } else {
            showTeamFields = false
            teamNames.removeAll()
        }
    }

    func isFormValid() -> Bool {
        guard !tournamentTitle.isEmpty, numberOfTeams > 1 else { return false }
        return teamNames.allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    NewTournamentSetupView()
}
