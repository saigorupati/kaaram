//
//  NoteEditorSheet.swift
//  kaaram
//
//  Sheet presented from RecipeDetailView for creating / editing the
//  user's personal note on a recipe. One note per recipe; clearing the
//  text and tapping Save removes the note entirely.
//
//  The underlying RecipeNote @Model syncs to the user's CloudKit
//  private database automatically — notes follow the Apple ID across
//  devices.
//

import SwiftData
import SwiftUI

struct NoteEditorSheet: View {
    let slug: String

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var matchingNotes: [RecipeNote]

    @State private var draft: String = ""
    @FocusState private var isFocused: Bool

    init(slug: String) {
        self.slug = slug
        _matchingNotes = Query(filter: #Predicate<RecipeNote> { $0.slug == slug })
    }

    private var existing: RecipeNote? { matchingNotes.first }

    var body: some View {
        NavigationStack {
            TextEditor(text: $draft)
                .font(.kaaramBody)
                .scrollContentBackground(.hidden)
                .background(Color.kaaramBackground)
                .padding(Spacing.l)
                .focused($isFocused)
                .navigationTitle("Your notes")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") { save() }
                            .fontWeight(.semibold)
                            .tint(Color.kaaramSpice)
                    }
                    if existing != nil {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button(role: .destructive) {
                                draft = ""
                                save()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Spacer()
                            Button("Done") { isFocused = false }
                        }
                    }
                }
                .onAppear {
                    draft = existing?.body ?? ""
                    isFocused = true
                }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Save / delete

    private func save() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)

        if let existing {
            if trimmed.isEmpty {
                modelContext.delete(existing)
            } else if existing.body != trimmed {
                existing.body = trimmed
                existing.updatedAt = Date()
            }
        } else if !trimmed.isEmpty {
            modelContext.insert(RecipeNote(slug: slug, body: trimmed))
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    NoteEditorSheet(slug: "palak-paneer")
        .modelContainer(for: [FavoriteRecipe.self, RecipeNote.self, CachedRecipe.self], inMemory: true)
}
