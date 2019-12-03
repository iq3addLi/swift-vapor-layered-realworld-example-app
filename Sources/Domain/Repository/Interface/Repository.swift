//
//  Repository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/11/21.
//

/// Repository protocol
///
/// Repository is the exit of the Domain layer.
/// The repository hides the concrete implementation. Defines the inputs and outputs necessary to complete the process. This allows you to switch to a completely different implementation while maintaining API compatibility. 
/// Repository input and output types must not depend on a particular library. Use Swift base types and Domain models.
/// Repository must not depend on Infrastructure layer. Repository implementations can depend.
/// ### Repletion
/// This is the protocol that lets jazzy generate documentation. It has no functional meaning.
protocol Repository {}
