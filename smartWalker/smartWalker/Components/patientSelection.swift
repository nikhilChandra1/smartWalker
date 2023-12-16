//
//  patientSelection.swift
//  smartWalker
//
//  Created by Nikhil Chandra on 11/6/23.
//

import SwiftUI

struct patientSelection: View {
    @Binding var patients: [String]
    @Binding var selectedPatient: String
    @State var newPatient: String = ""
    @Binding var showPatientSelection: Bool
    var body: some View {
        VStack {
                    ForEach(patients, id: \.self) { patient in
                        Button {
                            selectedPatient = patient
                            withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                                showPatientSelection.toggle()
                            }
                        } label: {
                            
                            Text(patient)
                                
                                .font(.body)
                                .foregroundColor((selectedPatient == patient) ? Color.white : Color.black)
                                .frame(maxWidth: .infinity)
                                .padding(6)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill((selectedPatient == patient) ? Color.red : Color.white)
                                        .shadow(color: .gray, radius: 5, x: 0, y: 2)
                                        
                                )
                                .overlay(
                                    VStack() {
                                        HStack {
                                            Spacer()
                                            Button {
                                                
                                                patients.removeAll { $0 == patient }
                                                if selectedPatient == patient {
                                                    selectedPatient = patients[0]
                                                }
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .resizable()
                                                .scaledToFit()
                                                .frame(width:22, height: 22)
                                                .foregroundColor(.black)
                                                    
                                            }
                                            .offset(CGSize(width: 5, height: -5))
                                        }
                                        Spacer()
                                        
                                            
                                    }
                                        .frame(maxWidth:.infinity, maxHeight:.infinity)
                                    
                                        
                                        
                                
                                )
                                
                                                            
                        }
                        .padding(.vertical, 5)
                        
                }
                
                .padding(.horizontal, 30)
 
            
            VStack {
                        TextField("Enter new patient", text: $newPatient)
                            .font(.body)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.white) // White background
                            .cornerRadius(8) // Rounded corners
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red, lineWidth: 1) // Black border
                            )
                            
                            .padding(.vertical, 10)

                        Button("Submit") {
                            if !newPatient.isEmpty {
                                patients.append(newPatient)
                                selectedPatient = newPatient
                                
                            }
                            newPatient = ""
                            
                            
                        }
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.black) // Black background
                        .cornerRadius(8) // Rounded corners
                        
                    }
            .padding(.horizontal, 30)
                    
                
            
            
        }
        .frame(maxWidth:.infinity)
        .frame(height: 300)
        
        
    }
}

#Preview {
    patientSelection(patients: .constant(["John Smith", "John Doe", "John John"]), selectedPatient: .constant("John Doe"), showPatientSelection: .constant(false))
}
