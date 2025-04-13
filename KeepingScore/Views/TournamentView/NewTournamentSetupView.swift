import SwiftUI

struct NewTournamentSetupView: View {
    // MARK: - Focus State
    @FocusState private var focusedField: Field?
    
    // MARK: - State Properties
    @State private var tournamentTitle = ""
    @State private var teamCountText = ""
    @State private var autoGenerateMatchups = false
    @State private var teamNames: [String] = []
    @State private var navigateToBracket = false
    
    // MARK: - Field Enum
    private enum Field: Int, Hashable {
        case title, teamCount, teamName
    }
    
    // MARK: - Computed Properties
    private var teamCount: Int {
        min(max(Int(teamCountText) ?? 0, 0), 64) // Clamp between 0-64
    }
    
    private var isFormValid: Bool {
        !tournamentTitle.isEmpty && 
        teamCount >= 2 && 
        teamNames.prefix(teamCount).allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
    
    // MARK: - Main View
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Tournament Details")) {
                    tournamentTitleField
                    teamCountField
                    autoGenerateToggle
                }
                
                if !teamNames.isEmpty {
                    Section(header: Text("Team Names")) {
                        teamNameFields
                    }
                }
            }
            .navigationTitle("New Tournament")
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            hideKeyboard()
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                continueButton
            }
            .navigationDestination(isPresented: $navigateToBracket) {
                TournamentBracketView(
                    teams: Array(teamNames.prefix(teamCount)),
                    autoGenerate: autoGenerateMatchups,
                    tournamentTitle: tournamentTitle
                )
            }
        }
    }
    
    // MARK: - View Components
    private var tournamentTitleField: some View {
        TextField("Tournament Title", text: $tournamentTitle)
            .focused($focusedField, equals: .title)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .teamCount
            }
    }
    
    private var teamCountField: some View {
        TextField("Number of Teams (2-64)", text: $teamCountText)
            .keyboardType(.numberPad)
            .focused($focusedField, equals: .teamCount)
            .onChange(of: teamCountText) { _ in
                teamCountText = teamCountText.filter { $0.isNumber }
                updateTeamFields()
            }
            .onSubmit {
                if teamCount >= 2 {
                    focusedField = .teamName
                }
            }
    }
    
    private var autoGenerateToggle: some View {
        Toggle("Auto-generate matchups", isOn: $autoGenerateMatchups)
    }
    
    private var teamNameFields: some View {
        ForEach(0..<teamCount, id: \.self) { index in
            TextField("Team \(index + 1)", text: $teamNames[index])
                .focused($focusedField, equals: .teamName)
                .submitLabel(index == teamCount - 1 ? .done : .next)
                .onSubmit {
                    if index < teamCount - 1 {
                        focusedField = .teamName
                    } else {
                        hideKeyboard()
                    }
                }
        }
    }
    
    private var continueButton: some View {
        Button(action: createTournament) {
            Text("Create Tournament")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!isFormValid)
        .padding()
    }
    
    // MARK: - Private Methods
    private func updateTeamFields() {
        teamNames = Array(repeating: "", count: teamCount)
    }
    
    private func hideKeyboard() {
        focusedField = nil
    }
    
    private func createTournament() {
        hideKeyboard()
        navigateToBracket = true
    }
}

// MARK: - Preview
struct NewTournamentSetupView_Previews: PreviewProvider {
    static var previews: some View {
        NewTournamentSetupView()
    }
}
