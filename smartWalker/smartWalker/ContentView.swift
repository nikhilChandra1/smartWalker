//
//  ContentView.swift
//  smartWalker
//
//  Created by Nikhil Chandra on 10/29/23.
//

import SwiftUI

struct ContentView: View {
    @State var showPatientSelection = false
    
    @StateObject var realTimeData = dataProcessing()
    
    @State private var counter = 0
    @State private var timer: Timer?

    var body: some View {
        VStack {
            HStack {
                Text("Patient: " + realTimeData.selectedPatient)
                    .font(.system(.body, design: .rounded).bold())
                    .foregroundColor(.blue)
                    
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showPatientSelection.toggle()
                }
            }
            
            
            StartButton(ColorSelection: realTimeData.start ? "Red" : "Green", buttonTitle: realTimeData.start ? "Stop Recording" : "Start Recording")
                .disabled(!realTimeData.loadedPatients)
                .onTapGesture {
                    withAnimation(.spring()) {
                        realTimeData.start.toggle()
                    }
                }
                .scaleEffect(realTimeData.start ? 1 : 0.95) // Add a subtle bounce effect
                
            Button {
                realTimeData.zeroButton.toggle()
            } label:{
                Text("Zero")
                    .padding(4)
                    .font(.system(.body, design: .rounded).bold())
                    
            }
            
            Spacer()
                    .frame(height: 10)
            
            
            PressureComponent(leftPressure: $realTimeData.leftPressure, rightPressure: $realTimeData.rightPressure)
            Spacer()
                .frame(height: 30)
            SpeedComponent( value: $realTimeData.speed)
                Spacer()
                    .frame(height: 30)
            SpeedComponent(title: "Distance", value: $realTimeData.distance)
        }
        .frame(maxWidth:.infinity, maxHeight:.infinity)
        .overlay(
            VStack {
                if showPatientSelection {
                    patientSelection(patients: $realTimeData.patients, selectedPatient: $realTimeData.selectedPatient, showPatientSelection: $showPatientSelection)
                        .frame(maxWidth:.infinity, maxHeight:.infinity)
                        .background(
                            Color.white.opacity(0.9)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                                        showPatientSelection.toggle()
                                    }
                                }
                                
                        )
                }
            }
                .frame(maxWidth:.infinity, maxHeight:.infinity)
                .onAppear {
                    // Start the timer when the view appears
                    self.startTimer()
                }
                

        
        )
 
    }
    func startTimer() {
        // Invalidate any existing timer
        timer?.invalidate()

        // Create a new timer that fires every second
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            // Update the counter
            self.realTimeData.counter += 1
        }

        // Make sure the timer is in the run loop
        RunLoop.current.add(timer!, forMode: .common)
    }

    func stopTimer() {
        // Stop the timer
        timer?.invalidate()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
struct StartButton: View {
    var ColorSelection = "Green"
    var buttonTitle = "Start Recording"
    var body: some View {
        Text(buttonTitle)
            .font(.title)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(width: 250, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(ColorSelection=="Green" ? Color.green : Color.red) // Set the desired button color
            )
            .shadow(color: .gray, radius: 5, x: 0, y: 5) // Add shadow effect
    }
}
