//
//  ViewController.swift
//  WeatherApp
//
//  Created by Ange Luvari & Maxime Begarie on 06/05/2019.

import UIKit
import MapKit
import CoreLocation
class ViewController: UIViewController, CLLocationManagerDelegate {

    var myWeather: Weather?
    var apiUrl = "https://api.openweathermap.org/data/2.5/weather?q=Corte&units=metric&appid=b8c0162f208b810fd4c2e82e370a98a4"
    var backgroundColorByTime = [String: Any]()

    let locationManager = CLLocationManager()

    private var mainConstraints: [NSLayoutConstraint] = []
    private var metrics: [String: CGFloat]?
    private var views = [String: Any]()

    private var cityLabel: UILabel = {
        let label = UILabel()

        label.text = "City"
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(40)

        return label
    }()

    private var timeLabel: UILabel = {
        let label = UILabel()

        label.text = "HH:MM"
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(40)

        return label
    }()

    private var temparatureLabel: UILabel = {
        let label = UILabel()

        label.text = "X°"
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(40)

        return label
    }()

    var logoWeather: UIImageView = {
        let img = UIImageView(image: UIImage(named: "Clear"))

        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit

        return img
    }()

    var logoRefreshWeather: UIImageView = {
        let img = UIImageView(image: UIImage(named: "Refresh"))

        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit

        return img
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake feature

        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        timeLabel.text = getCurrDateTime()

        self.view.backgroundColor = getColorByTime()

        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(refreshData(tapGestureRecognizer:))
            )

        logoRefreshWeather.isUserInteractionEnabled = true
        logoRefreshWeather.addGestureRecognizer(tapGestureRecognizer)

        self.views["cityLabel"] = cityLabel
        self.views["logoWeather"] = logoWeather
        self.views["temparatureLabel"] = temparatureLabel
        self.views["timeLabel"] = timeLabel
        self.views["logoRefreshWeather"] = logoRefreshWeather

        self.view.addSubview(cityLabel)
        self.view.addSubview(logoWeather)
        self.view.addSubview(temparatureLabel)
        self.view.addSubview(timeLabel)
        self.view.addSubview(logoRefreshWeather)

        getDataFromApi()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }

        self.apiUrl = changeApiUrl(locValue)

        self.refreshDataAndUI()
    }

    func changeApiUrl(_ locValue: CLLocationCoordinate2D) -> String {
        return "https://api.openweathermap.org/data/2.5/weather?lat=\(locValue.latitude)&lon=\(locValue.longitude)&appid=b8c0162f208b810fd4c2e82e370a98a4"
    }

    func changeApiUrl(_ city: String) -> String {
       return "https://api.openweathermap.org/data/2.5/weather?q=\(city.replacingOccurrences(of: " ", with: "%20"))&units=metric&appid=b8c0162f208b810fd4c2e82e370a98a4"
    }

    @objc func refreshData(tapGestureRecognizer: UITapGestureRecognizer) {
        refreshDataAndUI()
    }

    func refreshDataAndUI() {
        getDataFromApi()

        timeLabel.text = getCurrDateTime()

        self.view.backgroundColor = getColorByTime()
    }

    func getDataFromApi() {
        let data: NSData = try! NSData(contentsOf: URL(string: apiUrl)!) 
        do {
            let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as! [String: Any]

            guard let weather = json["weather"] as? [[String: Any]] else {
                print(json["weather"] as Any)
                return
            }

            guard let temp = json["main"] as? [String: NSNumber] else {
                print(json["main"] as Any)
                return
            }

            guard let name = json["name"] as? String else {
                print(json["name"] as Any)
                return
            }

            myWeather = Weather(city: name, temperature: temp["temp"]!, imgName: weather[0]["main"] as! String)
            temparatureLabel.text = (myWeather?.temperature.stringValue)! + "°"
            logoWeather.image = getImageByName(name: myWeather?.imgName)
            cityLabel.text = myWeather?.city
        } catch let error as NSError {
            print(error)
        }
    }

    func genreateConstraintsVerticalOrientation() {

        let cityConstraintHorizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-leftMargin-[cityLabel]-rightMargin-|",
            metrics: self.metrics,
            views: self.views)
        self.mainConstraints += cityConstraintHorizontal

        let iconWeatherConstraintHorizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-iconWeatherHorizontalMargin-[logoWeather]-iconWeatherHorizontalMargin-|",
            metrics: self.metrics,
            views: self.views)
        self.mainConstraints += iconWeatherConstraintHorizontal

        let temperatureConstraintHorizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-leftMargin-[temparatureLabel]-rightMargin-|",
            metrics: self.metrics,
            views: self.views)
        self.mainConstraints += temperatureConstraintHorizontal

        let timeConstraintHorizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-leftMargin-[timeLabel]-rightMargin-|",
            metrics: self.metrics,
            views: self.views)
        self.mainConstraints += timeConstraintHorizontal

        let iconRefreshConstraintHorizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-iconRefreshHorizontalMargin-[logoRefreshWeather]-iconRefreshHorizontalMargin-|",
            metrics: self.metrics,
            views: self.views)
        self.mainConstraints += iconRefreshConstraintHorizontal

        let constraintsVertical = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-topMargin-[cityLabel]-[logoWeather]-[temparatureLabel]-[timeLabel]",
            metrics: self.metrics,
            views: self.views)
        self.mainConstraints += constraintsVertical

        let refreshConstraintsVertical = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[timeLabel]-topMargin-[logoRefreshWeather]|",
            metrics: self.metrics,
            views: self.views)
        self.mainConstraints += refreshConstraintsVertical

        NSLayoutConstraint.activate(self.mainConstraints)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        if !self.mainConstraints.isEmpty {
            NSLayoutConstraint.deactivate(self.mainConstraints)
            self.mainConstraints.removeAll()
        }

        let newInsets = view.safeAreaInsets
        let leftMargin = newInsets.left > 0 ? newInsets.left : Metrics.padding
        let rightMargin = newInsets.right > 0 ? newInsets.right : Metrics.padding
        let topMargin = newInsets.top > 0 ? newInsets.top : Metrics.padding
        let bottomMargin = newInsets.bottom > 0 ? newInsets.bottom : Metrics.padding
        let halfHeigh = self.view.frame.height / 2
        let iconWeatherHorizontalMargin = (self.view.frame.width / 4).rounded()
        let iconRefreshHorizontalMargin = (self.view.frame.width / 3).rounded() + rightMargin + (rightMargin * 0.5)

        self.metrics = [
            "horizontalPadding": Metrics.padding,
            "topMargin": topMargin,
            "bottomMargin": bottomMargin,
            "leftMargin": leftMargin,
            "rightMargin": rightMargin,
            "halfHeigh": halfHeigh,
            "iconWeatherHorizontalMargin": iconWeatherHorizontalMargin,
            "iconRefreshHorizontalMargin": iconRefreshHorizontalMargin
        ]
        self.genreateConstraintsVerticalOrientation()
    }

    private enum Metrics {
        static let padding: CGFloat = 30.0
    }

    func getColorByTime() -> UIColor {
        let time = getCurrDateTime()
        let hour = Int(time.components(separatedBy: ":")[0])!

        let sideralGrey = UIColor(rgb: 0xa5adb0)
        let galaxyBlue = UIColor(rgb: 0x00344c)
        let leafGreen = UIColor(rgb: 0x3A5F0B)
        let lemonYellow = UIColor(rgb: 0xfff44f)
        let mecanicalOrange = UIColor(rgb: 0xFFA500)

        var color = sideralGrey

        switch hour {
        case 23, 0...5:
            color = sideralGrey
        case 5...9:
            color = galaxyBlue
        case 9...15:
            color = leafGreen
        case 15...19:
            color = lemonYellow
        case 19...23:
            color = mecanicalOrange
        default:
            color = sideralGrey
        }

        return color

    }

    func getCurrDateTime() -> String {
        let time = DateFormatter()

        time.dateFormat = "HH:mm:ss"

        return time.string(from: Date())
    }

    func getImageByName(name: String?) -> UIImage {
        return UIImage(named: name ?? "Clear")!
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        refreshDataAndUI()
    }

}
