//
//  NameEditorSheet.swift
//  kaaram
//
//  Small sheet for editing the user's display name on UserPreferences.
//  Kept separate from NoteEditorSheet so each sheet has a single purpose.
//

import SwiftUI

struct NameEditorSheet: View {
    @Binding var name: String
    var onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Spacing.m) {
                MonoCap("YOUR NAME", color: .kaaramSpice)

                TextField("", text: $draft, prompt: Text("Sai").foregroundStyle(Color.kaaramInkMuted))
                    .font(.system(size: 28, weight: .medium, design: .serif))
                    .tracking(-0.5)
                    .foregroundStyle(Color.kaaramInk)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .focused($isFocused)
                    .onSubmit(save)

                Text("Shown at the top of your profile. You can change it anytime.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.kaaramInkMuted)

                Spacer()
            }
            .padding(Spacing.xl)
            .background(Color.kaaramBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.kaaramInkMuted)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .fontWeight(.semibold)
                        .tint(Color.kaaramSpice)
                }
            }
            .onAppear {
                draft = name
                isFocused = true
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func save() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        name = trimmed
        onSave(trimmed)
        dismiss()
    }
}

#Preview {
    @Previewable @State var name = "Sai"
    return NameEditorSheet(name: $name, onSave: { _ in })
}
