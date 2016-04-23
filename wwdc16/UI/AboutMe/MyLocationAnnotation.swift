//
//  MyLocationAnnotation.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 23.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

import MapKit

class MyLocationAnnotation: NSObject, MKAnnotation {
    
    //MARK: Properties
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    //MARK: Initialization
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
}
