//
//  ViewController.swift
//  MemoryGameAR
//
//  Created by Leah Joy Ylaya on 1/19/21.
//

import UIKit
import RealityKit
import Combine

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var arView: ARView!
    var headerView = UIView()
    var timerLabel = UIView()
    var numOfMatchedItemLabel = UILabel()
    var numOfMatchedItem = 0
    
    // temporary container of 2 recenlty tapped cards
    var tappedCards: [Entity] = []
    var matchedCards: [Entity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        arView.addGestureRecognizer(tap)
        addCards()
    }
    
    func addCards() {
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2,0.2])
        arView.scene.addAnchor(anchor)
        
        var cards: [Entity] = []
        
        for _ in 1...16 {
            let box = MeshResource.generateBox(width: 0.08, height: 0.004, depth: 0.08)
            let metalMaterial =  SimpleMaterial(color: .systemPink, isMetallic: true)
            let model = ModelEntity(mesh: box, materials: [metalMaterial])
            
            model.generateCollisionShapes(recursive: true)
            cards.append(model)
        }
        
        for(index, card) in cards.enumerated() {
            let x = Float(index % 4) - 1.5
            let z = Float(index / 4) - 1.5
            
            card.position = [x*0.2, 0,z*0.2]
            anchor.addChild(card)
        }
        
        let boxSize: Float = 0.8
        let occlusionMesh = MeshResource.generateBox(size: boxSize)
        
        let occlusionBox = ModelEntity(mesh: occlusionMesh, materials: [OcclusionMaterial()])
        
        occlusionBox.position.y = -boxSize/2
        anchor.addChild(occlusionBox)
        
        loadModel(anchor: anchor, cards: cards)
        
    }
    
    func loadModel(anchor: AnchorEntity, cards: [Entity]) {
        var cancellable: AnyCancellable? = nil
        cancellable = ModelEntity.loadAsync(named: "01")
            .append(ModelEntity.loadAsync(named: "02"))
            .append(ModelEntity.loadAsync(named: "03"))
            .append(ModelEntity.loadAsync(named: "04"))
            .append(ModelEntity.loadAsync(named: "05"))
            .append(ModelEntity.loadAsync(named: "06"))
            .append(ModelEntity.loadAsync(named: "07"))
            .append(ModelEntity.loadAsync(named: "08"))
            .collect()
            .sink(receiveCompletion: { err in
                cancellable?.cancel()
            }, receiveValue: { entities in
                var objs: [Entity] = []
                for entity in entities {
                    let name = entity.children.first?.name ?? ""
                    entity.setScale(self.scaleItem(itemName: name), relativeTo: anchor)
                    entity.generateCollisionShapes(recursive: true)
                    for _ in 1...2 {
                        objs.append(entity.clone(recursive: true))
                    }
                }
                
                objs.shuffle()
        
                for(index, obj) in objs.enumerated() {
                    let name = obj.children.first?.name ?? ""
                    cards[index].addChild(obj)
                    cards[index].transform.rotation = simd_quatf(angle: .pi, axis: [1,0,0])
                    cards[index].name = name
                }
                cancellable?.cancel()
            })
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer){
        sender.isEnabled = false
        let tapLocation = sender.location(in: arView)
        if let card = arView.entity(at: tapLocation) {
            let cards = matchedCards.filter { $0 == card }
            if cards.count != 0 {
                sender.isEnabled = true
                return
            }
            let tappedCard = tappedCards.filter{ $0 == card }
            if tappedCard.count != 0 {
                sender.isEnabled = true
                return
            }
            tappedCards.append(card)
            if card.transform.rotation.angle == .pi {
                openCard(card) {
                    self.validateTappedCards(sender)
                }
            }
        }
    }
    
    func validateTappedCards(_ sender: UITapGestureRecognizer) {
        if tappedCards.count < 2 {
            sender.isEnabled = true
            return
        }
        
        let firstCardName = tappedCards.first?.name ?? ""
        let secondCardName = tappedCards.last?.name ?? ""
        
        if firstCardName == secondCardName {
            matchedCards.append(contentsOf: tappedCards)
            sender.isEnabled = true
        } else {
            for card in tappedCards {
                closeCard(card) {
                    sender.isEnabled = true
                }
            }
        }
        if tappedCards.count == 2 {
            tappedCards.removeAll()
        }
    }
    
    func openCard(_ card: Entity, completionHandler: @escaping() -> ()) {
        var flipDownTransform = card.transform
        flipDownTransform.rotation = simd_quatf(angle: 0, axis: [1,0,0])
        card.move(to: flipDownTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completionHandler()
        }
    }
    
    func closeCard(_ card: Entity, completionHandler: @escaping() -> ()) {
        var flipUpTransform = card.transform
        flipUpTransform.rotation = simd_quatf(angle: .pi, axis: [1,0,0])
        card.move(to: flipUpTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completionHandler()
        }
        
    }
    
    func scaleItem(itemName: String ) -> SIMD3<Float> {
        switch itemName {
        case "_01":
            return SIMD3<Float>(0.002, 0.002, 0.002)
        case "_02":
            return SIMD3<Float>(0.001, 0.001, 0.001)
        case "_03":
            return SIMD3<Float>(0.009, 0.009, 0.009)
        case "_04":
            return SIMD3<Float>(0.004, 0.004, 0.004)
        case "_05":
            return SIMD3<Float>(0.005, 0.005, 0.005)
        case "_06":
            return SIMD3<Float>(0.004, 0.004, 0.004)
        case "_07":
            return SIMD3<Float>(0.0009, 0.0009, 0.0009)
        case "_08":
            return SIMD3<Float>(0.002, 0.002, 0.002)
        default:
            return SIMD3<Float>(0.005, 0.005, 0.005)
        }
    }
}
