//
//  ManualEntryView.swift
//  HealthApp
//
//  Created by DREAMWORLD on 29/08/25.
//

import SwiftUI

struct ManualEntryView: View {
    @Binding var manualSteps: String
    let onSave: (Double) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Number of steps", text: $manualSteps)
                        .keyboardType(.numberPad)
                } header: {
                    Text("Add Manual Steps")
                }
                
                Section {
                    Button("Save Steps") {
                        if let steps = Double(manualSteps) {
                            onSave(steps)
                        }
                    }
                    .disabled(manualSteps.isEmpty || Double(manualSteps) == nil)
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}
