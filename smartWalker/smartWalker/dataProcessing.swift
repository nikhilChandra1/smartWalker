//
//  dataProcessing.swift
//  smartWalker
//
//  Created by Nikhil Chandra on 11/21/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import Combine
class dataProcessing: ObservableObject {
    
        init() {
                setupFirebaseListener()
                loadData()
        }
        @Published var zeroButton = false {
            didSet {
                
                initialPressureReading = String((Double(initialPressureReading) ?? 0.0) +  (Double(leftPressure.replacingOccurrences(of: " N", with: "")) ?? 0.0))
                leftPressure = "0 N"
                rightPressure = "0 N"
                print(initialPressureReading)
                
            }
        }
        @Published var initialPressureReading = "0.0"
        @Published var counter = 0.01
        @Published var initialTime = 0.0
        @Published var documentData: Codable?
        @Published var leftPressure: String = "0 N"
        @Published var rightPressure: String = "0 N"
        @Published var speed: String = "0 mm/s"
        @Published var distance: String = "0.0 m"
        var distanceBetweenMagnets = 0.5
        @Published var patients: [String] = [] {
            didSet {
                if loadedPatients {
                    let documentRef = db.collection("smartWalker").document("allPatientData")
                    let uploadData = ["patientList": patients]
                    documentRef.setData(uploadData, merge: true) { error in
                        if let error = error {
                            print("Error setting data: \(error.localizedDescription)")
                        } else {
                            print("Data set successfully!")
                        }
                    }
                }
                
            }
        }
        @Published var loadedPatients = false
        @Published var selectedPatient = "John Doe" {
            didSet {
                if loadedPatients {
                    let documentRef = db.collection("smartWalker").document("allPatientData")
                    let uploadData = ["selectedPatient": selectedPatient]
                    documentRef.setData(uploadData, merge: true) { error in
                        if let error = error {
                            print("Error setting data: \(error.localizedDescription)")
                        } else {
                            print("Data set successfully!")
                        }
                    }
                }
                
            }
        }
    
        let db = Firestore.firestore()
        @Published var start = false { //true means started/recording
            didSet {
                if start { //started recording
                    
                    pressureList = []
                    speedList = []
                    distance = "0.0" + " m"
                    counter = 0.01
                    speed = "0.0" + " mm/s"
                    
                } else {
                    if !pressureList.isEmpty {
                        let pressureSum = pressureList.reduce(0, +)
                        let pressureAverage = String(Double(pressureSum) / Double(pressureList.count)) + " N"
                        let speedSum = speedList.reduce(0, +)
                        let speedAverage = String(Double(speedSum) / Double(speedList.count))
                        let finalDistanceTraveled = distance.replacingOccurrences(of: " m", with: "")
                        
                        let currentDate = Timestamp(date: Date())
                        let documentID = currentDate.dateValue().description
                        
                        // Create a reference to the Firestore collection and document with the current date and time
                        let documentRef = db.collection("smartWalker").document("allPatientData").collection(selectedPatient).document(documentID)
                        let uploadData = ["averagePressure": pressureAverage, "averageSpeed": speed, "distanceTraveled": distance]
                        
                        // Set the data in Firestore
                        documentRef.setData(uploadData, merge: true) { error in
                            if let error = error {
                                print("Error setting data: \(error.localizedDescription)")
                            } else {
                                print("Data set successfully!")
                            }
                        }
                    
  
                    }
                    
                }
            }
        }
    
    
        
        var pressureList: [Double] = []
        var speedList: [Double] = []
        var initialDistance = "0.0"
        
    
        private var listener: ListenerRegistration?

        func setupFirebaseListener() {
            let documentReference = db.collection("smartWalker").document("realTimeData")

            listener = documentReference
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self = self else { return }

                    if let error = error {
                        print("Error fetching document: \(error.localizedDescription)")
                        return
                    }

                    guard let document = snapshot else {
                        print("Document does not exist")
                        return
                    }

                    do {
                        let documentData = try document.data(as: UserData.self) // Replace YourDataType with the type of data you expect
                        
                        self.documentData = documentData
                        
                        if let documentData = documentData as? UserData {
                            print(documentData.pressure)
                            print(Double(initialPressureReading))
                            var pressureCalc = documentData.pressure - (Double(initialPressureReading) ?? 0.0)
                            
                            leftPressure = String(format: "%.1f", pressureCalc) + " N"
                            rightPressure = String(format: "%.1f", pressureCalc) + " N"
                            
                            
                            if !start {
                                //not recording, keep storing initial distance values
                                initialDistance = String(documentData.distance)
                            } else {
                                //recording, send values to arrays, display distances relative to initial
                                
                                pressureList.append(pressureCalc)
                                
                                if let initalDistanceFloat = (Double(initialDistance)) {
                                    var distanceConversion = String(format: "%.1f", (documentData.distance - initalDistanceFloat))
                                    self.distance = distanceConversion + " m"
                                    if (documentData.distance - initalDistanceFloat) > 0.0 {
                                        var speedCalc = ((documentData.distance - initalDistanceFloat) / (counter))*1000.0
                                        speed = String(format: "%.1f", speedCalc) + " mm/s"
                                        speedList.append(speedCalc)
                                    } else {
                                        counter = 0.01
                                    }
                                    
                                    
                                }
          
                                
                                
                            }

                        }
                        
                        
                    } catch {
                        print("Error decoding document: \(error.localizedDescription)")
                    }
                    


                }
                
        }
    
    func loadData() {
        let documentReference = db.collection("smartWalker").document("allPatientData")
        documentReference.getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
            }
            else if let document = document, document.exists {
                if let documentData = document.data() {
                    if let patientList = documentData["patientList"] as? [String] {
                        self.patients = patientList
                        self.loadedPatients = true
                        
                    }
                    if let lastPatient = documentData["selectedPatient"] as? String {
                        self.selectedPatient = lastPatient
                    }
                }
            }
        }


    }
    
}

struct UserData: Codable {
    var pressure: Double
    var distance: Double
    var speed: Double
}
