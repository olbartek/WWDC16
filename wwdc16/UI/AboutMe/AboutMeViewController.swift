//
//  AboutMeViewController.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation

class AboutMeViewController: PresentedViewController {
    
    // MARK: Properties
    
    fileprivate struct Constants {
        static let ProfileImageBorderWidth: CGFloat = 2.0
        static let ProfileImageCornerRadius: CGFloat = 125.0
        static let ProfileImageBorderColor = UIColor.white
        static let MapViewBorderWidth: CGFloat = 2.0
        static let MapViewBorderColor = UIColor.white
        static let ProfileImage = UIImage(named: "profile-image")!
        static let MarkerImage = UIImage(named: "map-marker")!
        static let AnnotationIdentifier = "MyLocationAnnotation"
        static let MyLocationLatitude: Double = 50.061389
        static let MyLocationLongitude: Double = 19.938333
        static let DistanceViewAppearingAnimationDuration: TimeInterval = 0.5
        static let DistanceViewAppearingDamping: CGFloat = 0.6
        static let DistanceViewAppearingInitialVelocity: CGFloat = 0.5
        static let DistanceViewAppearingDelay: TimeInterval = 0.0
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceUnitLabel: UILabel!
    @IBOutlet weak var userLocationTextField: UITextField!
    
    @IBOutlet weak var visibleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var distanceViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var distanceViewPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoLabelTrailingConstraint: NSLayoutConstraint!
    
    var mapViewConfigured = false
    var tapGestureRecognizer: UITapGestureRecognizer?
    var currentKeyboardHeight: CGFloat = 0.0
    var speechSynthesizer = AVSpeechSynthesizer()
    var viewHeight = UIScreen.main.bounds.size.height
    
    // MARK: VC's Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .themeBlueColor()
        configureProfileImage()
        configureVisibleViewHeight()
        distanceViewWidthConstraint.constant = view.bounds.size.width
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        distanceViewPositionConstraint.constant = -view.bounds.size.width
        mapViewConfigured = false
        addNotificationObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationObservers()
    }
    
    // MARK: Appearance
    
    func configureProfileImage() {
        profileImageView.layer.cornerRadius = Constants.ProfileImageCornerRadius
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = Constants.ProfileImageBorderWidth
        profileImageView.layer.borderColor = Constants.ProfileImageBorderColor.cgColor
        profileImageView.image = Constants.ProfileImage
    }
    
    func configureVisibleViewHeight() {
        let visibleViewSize = UIScreen.main.bounds
        visibleViewHeightConstraint.constant = visibleViewSize.height
    }
    
    func configureMapView() {
        for annotation in mapView.annotations { mapView.removeAnnotation(annotation) }
        mapView.layer.borderWidth = Constants.MapViewBorderWidth
        mapView.layer.borderColor = Constants.MapViewBorderColor.cgColor
        
        let myLocationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(Constants.MyLocationLatitude), longitude: CLLocationDegrees(Constants.MyLocationLongitude))
        let myLocationAnnotation = MyLocationAnnotation(coordinate: myLocationCoordinate, title: "Cracow, Poland, Europe", subtitle: "")
        let region = MKCoordinateRegionMakeWithDistance(myLocationCoordinate, 1000.0, 1000.0)
        
        mapView.addAnnotation(myLocationAnnotation)
        mapView.setRegion(region, animated: true)
    }
    
    func setDistanceLabelWithDistance(_ distance: Int) {
        let distanceString = distanceStringAccordingToMetricUnitsFromDistance(distance)
        distanceLabel.text = distanceString.distance
        distanceUnitLabel.text = distanceString.distanceUnit
        distanceViewPositionConstraint.constant = 0.0
        UIView.animate(withDuration: Constants.DistanceViewAppearingAnimationDuration, delay: Constants.DistanceViewAppearingDelay, usingSpringWithDamping: Constants.DistanceViewAppearingDamping, initialSpringVelocity: Constants.DistanceViewAppearingInitialVelocity, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
            }, completion: { (finished) in
                let unitToSpeak = self.systemIsUsingMetricUnits() ? " kilometers" : " miles"
                self.speakText("Wow! That's " + distanceString.distance + unitToSpeak)
                
        })
    }
    
    func animateInfoLabel() {
        infoLabelTrailingConstraint.constant = 8.0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    // Speech synthesizer
    func speakText(_ text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(speechUtterance)
    }
    
    // MARK: Keyboard
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        var difference: CGFloat = 0
        let frame = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        difference = currentKeyboardHeight - frame.size.height
        currentKeyboardHeight = frame.height
        view.frame = self.view.frame.offsetBy(dx: 0, dy: difference)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        view.frame = self.view.frame.offsetBy(dx: 0, dy: currentKeyboardHeight);
        currentKeyboardHeight = 0
    }
    
    // MARK: Gesture Recognizers
    
    func addTapGestureRecognizer() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnView(_:)))
        view.addGestureRecognizer(tapGestureRecognizer!)
    }
    
    func removeTapGestureRecognizer() {
        if let tapGestureRecognizer = tapGestureRecognizer {
            view.removeGestureRecognizer(tapGestureRecognizer)
            self.tapGestureRecognizer = nil
        }
    }
    
    func didTapOnView(_ gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: Actions
    
    @IBAction func didPressCloseButton() {
        dismissViewControllerWithoutAnimation()
    }
    
    @IBAction func didPressDownArrowButton() {
        let offset = CGPoint(x: 0, y: visibleViewHeightConstraint.constant)
        scrollView.setContentOffset(offset, animated: true)
    }
    
    @IBAction func didPressUpArrowButton() {
        let offset = CGPoint.zero
        scrollView.setContentOffset(offset, animated: true)
    }
    
    // MARK: Distance calculation
    
    func checkUserLocationAndCalculateDistance() {
        distanceViewPositionConstraint.constant = -view.bounds.size.width
        guard let userLocationText = userLocationTextField.text , userLocationText.characters.count > 0 else {
            return
        }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(userLocationText, completionHandler: { [weak self] (placemarks, error) -> Void in
            guard let weakSelf = self else { return }
            if let placemarksArr = placemarks {
                if let firstPlacemark = placemarksArr.first {
                    guard let userLocation = firstPlacemark.location else { return }
                    weakSelf.calculateDistanceToLocation(userLocation)
                }
                
                
            }
        })
    }
    
    func calculateDistanceToLocation(_ userLocation: CLLocation) {
        let myLocation = CLLocation(latitude: CLLocationDegrees(Constants.MyLocationLatitude), longitude: CLLocationDegrees(Constants.MyLocationLongitude))
        let distance = myLocation.distance(from: userLocation)
        setDistanceLabelWithDistance(Int(distance))
    }
    
    func distanceStringAccordingToMetricUnitsFromDistance(_ fromDistance: Int) -> (distance: String, distanceUnit: String) {
        let dist: String
        let distUnit: String
        let kilometers = fromDistance / 1000
        
        if systemIsUsingMetricUnits() {
            dist = "\(kilometers)"
            distUnit = "km"
        } else {
            dist = "\(Int(Double(kilometers) * 0.62137))"
            distUnit = "miles"
        }
        return (dist, distUnit)
    }
    
    fileprivate func systemIsUsingMetricUnits() -> Bool {
        let isMetric = (Locale.current as NSLocale).object(forKey: NSLocale.Key.usesMetricSystem) as! NSNumber
        return isMetric.boolValue
    }

}

// MARK: MapView delegate

extension AboutMeViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let myLocationAnnotation = annotation as? MyLocationAnnotation {
            let annotationView = MKAnnotationView(annotation: myLocationAnnotation, reuseIdentifier: Constants.AnnotationIdentifier)
            annotationView.image = Constants.MarkerImage
            return annotationView
        }
        return nil
    }
}

// MARK: ScrollView delegate

extension AboutMeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !mapViewConfigured {
            configureMapView()
            mapViewConfigured = true
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        prepareViewsForDisplaying()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        prepareViewsForDisplaying()
    }
    
    func prepareViewsForDisplaying() {
        let pageIndex = Int(scrollView.contentOffset.y) / Int(viewHeight)
        if pageIndex == 0 {
            infoLabelTrailingConstraint.constant = -viewHeight
            let myLocationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(Constants.MyLocationLatitude), longitude: CLLocationDegrees(Constants.MyLocationLongitude))
            let region = MKCoordinateRegionMakeWithDistance(myLocationCoordinate, 1000000.0, 1000000.0)
            mapView.setRegion(region, animated: true)
        } else {
            configureMapView()
            animateInfoLabel()
        }
    }
}

extension AboutMeViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addTapGestureRecognizer()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        removeTapGestureRecognizer()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        checkUserLocationAndCalculateDistance()
        return true
    }
}
