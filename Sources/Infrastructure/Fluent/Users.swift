//
//  File.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/09/12.
//

public final class Users{
    public var id: Int
    public var username: String
    public var email: String
    public var bio: String
    public var image: String
    public var favorites: [Int]
    public var following: [Int]
    public var hash: String // hashed password 
    public var salt: String
    
    public init(id: Int, username: String, email: String, bio: String = "", image: String = "", favorites: [Int] = [], following: [Int] = [], hash: String = "hash", salt: String = "salt"){
        self.id = id
        self.username = username
        self.email = email
        self.bio = bio
        self.image = image
        self.favorites = favorites
        self.following = following
        self.hash = hash
        self.salt = salt
    }
}


//username: {type: String, lowercase: true, unique: true, required: [true, "can't be blank"], match: [/^[a-zA-Z0-9]+$/, 'is invalid'], index: true},
//email: {type: String, lowercase: true, unique: true, required: [true, "can't be blank"], match: [/\S+@\S+\.\S+/, 'is invalid'], index: true},
//bio: String,
//image: String,
//favorites: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Article' }],
//following: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
//hash: String,
//salt: String
