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
    
    private struct Constants {
        static let ProfileImageBorderWidth: CGFloat = 2.0
        static let ProfileImageCornerRadius: CGFloat = 125.0
        static let ProfileImageBorderColor = UIColor.whiteColor()
        static let MapViewBorderWidth: CGFloat = 2.0
        static let MapViewBorderColor = UIColor.whiteColor()
        static let ProfileImage = UIImage(named: "profile-image")!
        static let MarkerImage = UIImage(named: "map-marker")!
        static let AnnotationIdentifier = "MyLocationAnnotation"
        static let MyLocationLatitude: Double = 50.061389
        static let MyLocationLongitude: Double = 19.938333
        static let DistanceViewAppearingAnimationDuration: NSTimeInterval = 0.5
        static let DistanceViewAppearingDamping: CGFloat = 0.6
        static let DistanceViewAppearingInitialVelocity: CGFloat = 0.5
        static let DistanceViewAppearingDelay: NSTimeInterval = 0.0
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
    var viewHeight = UIScreen.mainScreen().bounds.size.height
    
    // MARK: VC's Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .themeBlueColor()
        configureProfileImage()
        configureVisibleViewHeight()
        distanceViewWidthConstraint.constant = view.bounds.size.width
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        distanceViewPositionConstraint.constant = -view.bounds.size.width
        mapViewConfigured = false
        addNotificationObservers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationObservers()
    }
    
    // MARK: Appearance
    
    func configureProfileImage() {
        profileImageView.layer.cornerRadius = Constants.ProfileImageCornerRadius
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = Constants.ProfileImageBorderWidth
        profileImageView.layer.borderColor = Constants.ProfileImageBorderColor.CGColor
        profileImageView.image = Constants.ProfileImage
    }
    
    func configureVisibleViewHeight() {
        let visibleViewSize = UIScreen.mainScreen().bounds
        visibleViewHeightConstraint.constant = visibleViewSize.height
    }
    
    func configureMapView() {
        for annotation in mapView.annotations { mapView.removeAnnotation(annotation) }
        mapView.layer.borderWidth = Constants.MapViewBorderWidth
        mapView.layer.borderColor = Constants.MapViewBorderColor.CGColor
        
        let myLocationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(Constants.MyLocationLatitude), longitude: CLLocationDegrees(Constants.MyLocationLongitude))
        let myLocationAnnotation = MyLocationAnnotation(coordinate: myLocationCoordinate, title: "Cracow, Poland, Europe", subtitle: "")
        let region = MKCoordinateRegionMakeWithDistance(myLocationCoordinate, 1000.0, 1000.0)
        
        mapView.addAnnotation(myLocationAnnotation)
        mapView.setRegion(region, animated: true)
    }
    
    func setDistanceLabelWithDistance(distance: Int) {
        let distanceString = distanceStringAccordingToMetricUnitsFromDistance(distance)
        distanceLabel.text = distanceString.distance
        distanceUnitLabel.text = distanceString.distanceUnit
        distanceViewPositionConstraint.constant = 0.0
        UIView.animateWithDuration(Constants.DistanceViewAppearingAnimationDuration, delay: Constants.DistanceViewAppearingDelay, usingSpringWithDamping: Constants.DistanceViewAppearingDamping, initialSpringVelocity: Constants.DistanceViewAppearingInitialVelocity, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: { (finished) in
                let unitToSpeak = self.systemIsUsingMetricUnits() ? " kilometers" : " miles"
                self.speakText("Wow! That's " + distanceString.distance + unitToSpeak)
                
        })
    }
    
    func animateInfoLabel() {
        infoLabelTrailingConstraint.constant = 8.0
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    // Speech synthesizer
    func speakText(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speakUtterance(speechUtterance)
    }
    
    // MARK: Keyboard
    
    func addNotificationObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeNotificationObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var difference: CGFloat = 0
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        difference = currentKeyboardHeight - frame.size.height
        currentKeyboardHeight = frame.height
        view.frame = CGRectOffset(self.view.frame, 0, difference)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame = CGRectOffset(self.view.frame, 0, currentKeyboardHeight);
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
    
    func didTapOnView(gesture: UITapGestureRecognizer) {
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
        let offset = CGPointZero
        scrollView.setContentOffset(offset, animated: true)
    }
    
    // MARK: Distance calculation
    
    func checkUserLocationAndCalculateDistance() {
        distanceViewPositionConstraint.constant = -view.bounds.size.width
        guard let userLocationText = userLocationTextField.text where userLocationText.characters.count > 0 else {
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
    
    func calculateDistanceToLocation(userLocation: CLLocation) {
        let myLocation = CLLocation(latitude: CLLocationDegrees(Constants.MyLocationLatitude), longitude: CLLocationDegrees(Constants.MyLocationLongitude))
        let distance = myLocation.distanceFromLocation(userLocation)
        setDistanceLabelWithDistance(Int(distance))
    }
    
    func distanceStringAccordingToMetricUnitsFromDistance(fromDistance: Int) -> (distance: String, distanceUnit: String) {
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
    
    private func systemIsUsingMetricUnits() -> Bool {
        let isMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem) as! NSNumber
        return isMetric.boolValue
    }

}

// MARK: MapView delegate

extension AboutMeViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !mapViewConfigured {
            configureMapView()
            mapViewConfigured = true
        }
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        prepareViewsForDisplaying()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        addTapGestureRecognizer()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        removeTapGestureRecognizer()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        checkUserLocationAndCalculateDistance()
        return true
    }
}
