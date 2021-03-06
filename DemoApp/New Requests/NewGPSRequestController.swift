//
//  NewGPSRequestController.swift
//  SwiftLocation
//
//  Created by dan on 23/04/2019.
//  Copyright © 2019 SwiftLocation. All rights reserved.
//

import UIKit
import CoreLocation

public class NewGPSRequestController: UIViewController {
    
    @IBOutlet public var timeoutButton: UIButton!
    @IBOutlet public var accuracyButton: UIButton!
    @IBOutlet public var modeButton: UIButton!
    @IBOutlet public var distanceFilter: UITextField!
    @IBOutlet public var activityButton: UIButton!

    private var timeout: Timeout.Mode? = nil {
        didSet {
            reload()
        }
    }
    
    private var accuracy: LocationManager.Accuracy = .city {
        didSet {
            reload()
        }
    }
    
    private var mode: LocationRequest.Subscription = .oneShot {
        didSet {
            reload()
        }
    }
    
    private var activityType: CLActivityType = .other {
        didSet {
            reload()
        }
    }
    
    public static func create() -> UINavigationController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewGPSRequestController") as! NewGPSRequestController
        return UINavigationController(rootViewController: vc)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didPressCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createRequest))

        self.timeout = .delayed(10)
        self.accuracy = .city
        self.mode = .oneShot
        reload()
    }
    
    @objc func didPressCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction public func setMode() {
        let options: [SelectionItem<LocationRequest.Subscription>] = LocationRequest.Subscription.all.map {
            return SelectionItem(title: $0.description, value: $0)
        }
        self.showPicker(title: "Select a Subscription mode", msg: nil, options: options, onSelect: { item in
            self.mode = item.value!
        })
    }
    
    @IBAction public func setAccuracy() {
        let options: [SelectionItem<LocationManager.Accuracy>] = LocationManager.Accuracy.all.map {
            return SelectionItem(title: $0.description, value: $0)
        }
        self.showPicker(title: "Select an Accuracy Level", msg: nil, options: options, onSelect: { item in
            self.accuracy = item.value!
        })
    }
    
    @IBAction public func setActivityType() {
        var options: [SelectionItem<CLActivityType>] = [
            SelectionItem(title: "other", value: CLActivityType.other),
            SelectionItem(title: "automotiveNavigation", value: CLActivityType.automotiveNavigation),
            SelectionItem(title: "fitness", value: CLActivityType.fitness),
            SelectionItem(title: "otherNavigation", value: CLActivityType.otherNavigation),
        ]
        
        if #available(iOS 12.0, *) {
            options.append(SelectionItem(title: "airborne", value: CLActivityType.airborne))
        }

        self.showPicker(title: "Select an Activity", msg: nil, options: options, onSelect: { item in
            self.activityType = item.value!
        })
    }
    
    @IBAction public func setTimeout() {
        let options: [SelectionItem<Timeout.Mode>] = [
            .init(title: "Absolute 5s", value: .absolute(5)),
            .init(title: "Absolute 10s", value: .absolute(10)),
            .init(title: "Absolute 20s", value: .absolute(20)),
            .init(title: "Delayed 5s", value: .delayed(5)),
            .init(title: "Delayed 10s", value: .delayed(10)),
            .init(title: "Delayed 20s", value: .delayed(20)),
            .init(title: "No Timeout", value: nil),
        ]
        self.showPicker(title: "Select a Timeout", msg: nil, options: options, onSelect: { item in
            self.timeout = item.value
        })
    }
    
    private func reload() {
        timeoutButton.setTitle(timeout?.description ?? "not set", for: .normal)
        accuracyButton.setTitle(accuracy.description, for: .normal)
        modeButton.setTitle(mode.description, for: .normal)
        activityButton.setTitle(activityType.description, for: .normal)
    }
    
    @objc public func createRequest() {
        LocationManager.shared.locateFromGPS(self.mode,
                                             accuracy: self.accuracy,
                                             distance: CLLocationDistance(distanceFilter.text ?? "-1"),
                                             activity: self.activityType,
                                             timeout: self.timeout,
                                             result: nil)
        self.dismiss(animated: true, completion: nil)
    }
}

extension CLActivityType: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .other:
            return "other"
        case .automotiveNavigation:
            return "automotiveNavigation"
        case .fitness:
            return "fitness"
        case .otherNavigation:
            return "otherNavigation"
        case .airborne:
            return "airborne"
        @unknown default:
            return ""
        }
    }
    
}
