//
//  UseCase.swift
//  Domain
//
//  Created by iq3AddLi on 2019/11/21.
//

/// Use case in controller
///
/// UseCase is the domain layer entrance.
/// Accept orders from Presentation layer. Accepting and handing over the processing to the appropriate Repository is the role of the UseCase. Do not depend on the Infrastructure layer. This is because the dependence on external libraries cannot be cut out well. 
/// ### Repletion
/// This is the protocol that lets jazzy generate documentation. It has no functional meaning.
protocol UseCase {}
