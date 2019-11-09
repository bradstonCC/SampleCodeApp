//
//  SessionDetailsViewController.swift
//  SampleCodeApp
//
//  Created by Bradston Henry on 11/8/19.
//  Copyright © 2019 Bradston Henry. All rights reserved.
//

import GoogleMaps
import SwiftyJSON
import UIKit

class SessionDetailsViewController: UIViewController, GMSMapViewDelegate {

    let allowedSegues = ["unwindSegueToSampleViewController"]
    var shouldUseGMS = false
    
    var gmsMapView: GMSMapView!
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var loadingView: UIView!
    
    
    // MARK: - Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        SegueClass.toSampleViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDel = UIApplication.shared.delegate as? AppDelegate {
            //Should we use Google Maps to map driver route
            shouldUseGMS = appDel.shouldUseGMS
            //Create Google Map View if can use Google Map Services
            if shouldUseGMS {
                creatGMSMapView()
            }
        }
        
        loadSampleDataFile()
    }
    
    
    // MARK: - Data Parsing
    
    func parseRouteData (routeData: Data) {
        
        var jsonOptional: JSON?
        //Convert data from request to JSON object
        jsonOptional = try? JSON(data: routeData)
        print(jsonOptional)
        
        //Unwrap and ensure JSON is valid and days data exists in JSON object
        guard let json = jsonOptional else {return}
        guard let locations = json["route"].array else {return}
        
        mapLocations = locations
        
        //Hide Loading view for map loading
        loadingView.isHidden = true
        
        if shouldUseGMS {
            createMapViewWithGMS(mapLocations: mapLocations)
        } else{
            //TODO: Add MapKit Version of map
        }
        
    }
    
    func loadSampleDataFile() {
        //Load Sample Data file stored in app file system into app
        if let path = Bundle.main.path(forResource: "SampleRoute", ofType: "json") {
            //Get URL from file path for loading data
            let url = URL(fileURLWithPath: path)
               
            do {
                let urlAsData = try Data(contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe)
                parseRouteData(routeData: urlAsData)
                
                let jsonText = String(decoding: urlAsData, as: UTF8.self)
            } catch {
                print("Error Occurred")
            }
        }
        
    }
    
    
    // MARK: - MapView
    
    var labelPadding: CGFloat = 0
    var mapLoaded = false
    var mapLocations: [JSON] = []
    
    func creatGMSMapView() {
        
        gmsMapView = GMSMapView(frame: mapView.frame, camera: GMSCameraPosition(latitude: 0, longitude: 0, zoom: 5))
        
        mapView.addSubview(gmsMapView)
        
    }
    
    func createMapViewWithGMS(mapLocations: [JSON]) {
        
        //Ensure method cannot run if there are no mapLocations to present
        if mapLocations.isEmpty {
            return
        }
        
        //Holds path for laying map path
        let path = GMSMutablePath()
        //Holds map bounds for camera zoom
        var coordBounds = GMSCoordinateBounds()
        
        //Holds the start and end point for bounding mapView
        var startPosition = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        var endPosition = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        //Iterate over all maplocations for creating polyline on mapView
        for (index, location) in mapLocations.enumerated() {
            //Retrieve lat and lon from data object
            guard let lat = location["latitude"].double, let lon = location["longitude"].double else {continue}
            
            //Convert lat/lon to CLLocationDegress
            guard let latDegrees = CLLocationDegrees(exactly: lat), let lonDegrees = CLLocationDegrees(exactly: lon) else {continue}
            
            //Add lat/Lon coordinates to path (Used for drawing polyline that shows driving route)
            path.add(CLLocationCoordinate2D(latitude: lat, longitude: lon))
            
            //Store the Start and End position of driving route (Used for determining starting viewing bounds on mapView)
            if index == 0 {
                //Store Start position of driving route (Used for determining starting viewing bounds on mapView)
                startPosition = CLLocationCoordinate2D(latitude: latDegrees, longitude: lonDegrees)
            } else if index == (mapLocations.count - 1) {
                //Store End position of driving route (Used for determining starting viewing bounds on mapView)
                endPosition = CLLocationCoordinate2D(latitude: latDegrees, longitude: lonDegrees)
            }
            
            //Current postion
            let currentPosition = CLLocationCoordinate2D(latitude: lat, longitude: lon);
            
            //Add coordinates to the bounds for setting the correct full path autozoom
            coordBounds = coordBounds.includingCoordinate(currentPosition)
        }
        
        //Inset are used to ensure that all items on map are viewable (Map markers,etc).
        //NOTE: Label padding must be added as logo realignment affects the centering of the mapview
        let mapviewInsets = UIEdgeInsets(top: 90, left: 65 - labelPadding, bottom: 60, right: 65)
        
        if !mapLoaded {
            //Set bounds of view on mapView and set the mapView "camera" to position itself correctly
            if let camera = gmsMapView.camera(for: coordBounds, insets: mapviewInsets) {
                gmsMapView.camera = camera
            }
            
        }
        
        //Creating the actually line that shows driver route
        let polyline = GMSPolyline(path: path)
        
        //Set thickness of polyline
        polyline.strokeWidth = 4.0
                
        //Setting polyline color
        let polylineColor: UIColor = .black
        
        //Set thickness of polyline
        polyline.strokeWidth = 4.0
        
        //Styles allows for creating the effect of a dashed line on the mapView
        let stlyes: [GMSStrokeStyle] = [GMSStrokeStyle.solidColor(polylineColor), GMSStrokeStyle.solidColor(.clear)]

        //Length of each segment of the polyline for style
        let lengths: [NSNumber] = [25, 20]
        
        //Add Style to polyline
        if let path = polyline.path {
            polyline.spans = GMSStyleSpans(path, stlyes, lengths, .rhumb)
        }
        
        //Create start and end markers for session driving route
        let startMarker = GMSMarker(position: startPosition)
        startMarker.icon = UIImage(named: "blue-map-pointer")
        startMarker.map = gmsMapView
        
        //Create end marker for session driving route
        let endMarker = GMSMarker(position: endPosition)
        endMarker.icon = UIImage(named: "orange-map-pointer")
        endMarker.map = gmsMapView
        
        polyline.map = gmsMapView
        
        //Set map loaded flag so auto-zoom won't happen on map zoom changes after initial load
        mapLoaded = true
    }
    
    // MARK: - GMS Map View Delegate
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //update mapView when map camerare changes (if mapLocations exist)
        if shouldUseGMS {
            createMapViewWithGMS(mapLocations: mapLocations)
        } else {
            //TODO: Add MapKit Version of map
        }
    }
    
//    -(void) createMapView: (NSArray*) mapLocations{
//
//        GMSMutablePath *path = [GMSMutablePath path];
//
//        //Holds the start and end point for bounding mapView
//        CLLocationCoordinate2D startPosition = CLLocationCoordinate2DMake(0,0);
//        CLLocationCoordinate2D endPosition = CLLocationCoordinate2DMake(0,0);
//
//        //Iterate over all maplocations for creating polyline on mapView
//        for(int i=0; i<mapLocations.count; i++){
//            //Retrieve lat and lon from data object
//            double lat = [mapLocations[i][@"lat"] doubleValue];
//            double lon = [mapLocations[i][@"lon"] doubleValue];
//
//            //Convert lat/lon to CLLocationDegress
//            CLLocationDegrees latDegrees = lat;
//            CLLocationDegrees lonDegrees = lon;
//
//            //Add lat/Lon coordinates to path (Used for drawing polyline that shows driving route)
//            [path addCoordinate:CLLocationCoordinate2DMake(lat, lon)];
//
//            //Store the Start and End position of driving route (Used for determining starting viewing bounds on mapView)
//            if(i==0){
//                //Create start and end markers for session driving route
//                GMSMarker* startMarker = [[GMSMarker alloc] init];
//                startMarker.icon = [UIImage imageNamed:@"blue-map-pointer"];
//                startMarker.position = CLLocationCoordinate2DMake(latDegrees, lonDegrees);
//                startMarker.map = _MapView;
//                //Store Start position of driving route (Used for determining starting viewing bounds on mapView)
//                startPosition = CLLocationCoordinate2DMake(latDegrees, lonDegrees);
//            }
//            else if(i == (mapLocations.count-1)){
//                //Create start and end markers for session driving route
//                GMSMarker* endMarker = [[GMSMarker alloc] init];
//                endMarker.icon = [UIImage imageNamed:@"orange-map-pointer"];
//                endMarker.position = CLLocationCoordinate2DMake(latDegrees, lonDegrees);
//                endMarker.map = _MapView;
//                //Store End position of driving route (Used for determining starting viewing bounds on mapView)
//                endPosition = CLLocationCoordinate2DMake(latDegrees, lonDegrees);
//            }
//
//        }
//
//        //Inset are used to ensure that all items on map are viewable (Map markers,etc).
//        //NOTE: Label padding must be added as logo realignment affects the centering of the mapview
//        UIEdgeInsets mapviewInsets = UIEdgeInsetsMake(40, 15-labelPadding, 10, 15);
//
//        //Set bounds of view on mapView and set the mapView "camera" to position itseft correctly
//        GMSCoordinateBounds* coordBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:startPosition coordinate:endPosition];
//        GMSCameraPosition *camera = [_MapView cameraForBounds:coordBounds insets:mapviewInsets];
//        [_MapView setCamera:camera];
//
//        //Creating the actually line that shows driver route
//        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
//        //Setting polyline color
//        UIColor* polyLineColor = [UIColor colorWithRed:0 green:0.15 blue:0.33 alpha:1];
//        //Set thickness of polyline
//        polyline.strokeWidth = 4.0f;
//
//        //Styles allows for creating the effect of a dashed line on the mapView
//        NSArray *styles = @[[GMSStrokeStyle solidColor:polyLineColor],
//                            [GMSStrokeStyle solidColor:[UIColor clearColor]]];
//        //Length of each segment of the polyline for style
//        NSArray *lengths = @[@25, @20];
//
//        //Add Style to polyline
//        polyline.spans = GMSStyleSpans(polyline.path, styles, lengths, kGMSLengthRhumb);
//
//        //Add polyline (driving route) to mapView
//        polyline.map = _MapView;
//
//
//    }
    
    
    // MARK: - Segues
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Check if current called segue is allowed with this VC
        return SegueClass.isSegueAllowed(allowedSegues: allowedSegues, segueID: identifier)
    }

}
