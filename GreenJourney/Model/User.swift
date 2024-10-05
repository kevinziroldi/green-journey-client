//
//  User.swift
//  GreenJourney
//
//  Created by matteo volpari on 05/10/24.
//
import Foundation

class User {
    var id: Int
    var firstName: String
    var lastname: String
    var birthDate: Date
    var gender: String
    var firebaseUID: Int
    var zipCode: Int
    var streetName: String
    var houseNumber: Int
    var city: String
    
    var travels: [Travel]
    var draftTravels: [Travel]
    
    init(id: Int, firstName: String, lastname: String, birthDate: Date, gender: String, firebaseUID: Int, zipCode: Int, streetName: String, houseNumber: Int, city: String) {
        self.id = id
        self.firstName = firstName
        self.lastname = lastname
        self.birthDate = birthDate
        self.gender = gender
        self.firebaseUID = firebaseUID
        self.zipCode = zipCode
        self.streetName = streetName
        self.houseNumber = houseNumber
        self.city = city
        self.travels = []
        self.draftTravels = []
    }
    
}
