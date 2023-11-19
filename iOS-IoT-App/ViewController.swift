import UIKit
import CoreMotion
import Charts
import DGCharts
import CommonCrypto

class ViewController: UIViewController {
    
    @IBOutlet var gyroChartView: LineChartView!
    @IBOutlet var accelerometerChartView: LineChartView!
    @IBOutlet var vibrationChartView: LineChartView!
    
    let motionManager = CMMotionManager()
    var gyroDataEntries: [ChartDataEntry] = []
    var accelerometerDataEntries: [ChartDataEntry] = []
    var vibrationDataEntries: [ChartDataEntry] = []
    var gyroDataCount = 0
    var accelerometerDataCount = 0
    
    // Replace with your Azure IoT Hub credentials
    let iotHubEndpoint = "https://IoTHubUoD.azure-devices.net"
    let deviceId = "iPhone"
    //    let sharedAccessKey = "<your_key>"
    var sharedAccessKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Read the secret key from Config.plist
          if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
                     let keys = NSDictionary(contentsOfFile: path) {
                      sharedAccessKey = keys["SharedAccessKey"] as? String
                 }
        
        setupChart(accelerometerChartView, title: "Accelerometer Data")
        setupChart(gyroChartView, title: "Gyroscope Data")
        setupChart(vibrationChartView, title: "Vibration Data")
        
        if motionManager.isGyroAvailable && motionManager.isAccelerometerAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.accelerometerUpdateInterval = 0.1
            
            motionManager.startAccelerometerUpdates(to: .main) { (accelerometerData, error) in
                if let accelerometerData = accelerometerData {
                    let x = accelerometerData.acceleration.x
                    let y = accelerometerData.acceleration.y
                    let z = accelerometerData.acceleration.z
                    
                    self.addAccelerometerEntry(x: x, y: y, z: z)
                    let vibrationLevel = sqrt(x * x + y * y + z * z)
                    self.addVibrationEntry(vibration: vibrationLevel)
                    
                    // Send telemetry to Azure IoT Hub with SAS token
                    let telemetryData = ["accelerometerX": x, "accelerometerY": y, "accelerometerZ": z, "vibration": vibrationLevel]
                    self.sendTelemetryToAzureIoT(data: telemetryData)
                }
            }
            
            motionManager.startGyroUpdates(to: .main) { (gyroData, error) in
                if let gyroData = gyroData {
                    let x = gyroData.rotationRate.x
                    let y = gyroData.rotationRate.y
                    let z = gyroData.rotationRate.z
                    
                    self.addGyroEntry(x: x, y: y, z: z)
                }
            }
            
        } else {
            print("Gyroscope or accelerometer not available.")
        }
    }
    
    func setupChart(_ chart: LineChartView, title: String) {
        chart.noDataText = "No data available"
        chart.chartDescription.text = title
    }
    
    func addGyroEntry(x: Double, y: Double, z: Double) {
        let entryX = ChartDataEntry(x: Double(gyroDataCount), y: x)
        let entryY = ChartDataEntry(x: Double(gyroDataCount), y: y)
        let entryZ = ChartDataEntry(x: Double(gyroDataCount), y: z)
        
        gyroDataEntries.append(contentsOf: [entryX, entryY, entryZ])
        gyroDataCount += 1
        
        let dataSetGyro = LineChartDataSet(entries: gyroDataEntries, label: "X, Y, Z Data")
        
        dataSetGyro.colors = [NSUIColor.red, NSUIColor.blue, NSUIColor.green]
        dataSetGyro.drawCirclesEnabled = false
        
        let data = LineChartData(dataSet: dataSetGyro)
        gyroChartView.data = data
        
        let legend = gyroChartView.legend
        legend.enabled = true
        legend.textColor = NSUIColor.white
        legend.formSize = 10.0
        legend.form = .circle
        
        gyroChartView.notifyDataSetChanged()
    }
    
    func addAccelerometerEntry(x: Double, y: Double, z: Double) {
        // Adjust values from 0 to -1 to be treated as 0
        let adjustedX = max(0, x)
        let adjustedY = max(0, y)
        let adjustedZ = max(0, z)
        
        let entryX = ChartDataEntry(x: Double(accelerometerDataCount), y: adjustedX)
        let entryY = ChartDataEntry(x: Double(accelerometerDataCount), y: adjustedY)
        let entryZ = ChartDataEntry(x: Double(accelerometerDataCount), y: adjustedZ)
        
        accelerometerDataEntries.append(contentsOf: [entryX, entryY, entryZ])
        accelerometerDataCount += 1
        
        let dataSetAccelerometer = LineChartDataSet(entries: accelerometerDataEntries, label: "X, Y, Z Data")
        
        dataSetAccelerometer.colors = [NSUIColor.red, NSUIColor.blue, NSUIColor.green]
        dataSetAccelerometer.drawCirclesEnabled = false
        
        let data = LineChartData(dataSet: dataSetAccelerometer)
        accelerometerChartView.data = data
        
        let legend = accelerometerChartView.legend
        legend.enabled = true
        legend.textColor = NSUIColor.white
        legend.formSize = 10.0
        legend.form = .circle
        
        accelerometerChartView.notifyDataSetChanged()
    }
    
    func addVibrationEntry(vibration: Double) {
        vibrationDataEntries.append(ChartDataEntry(x: Double(vibrationDataEntries.count), y: vibration))
        
        let dataSetVibration = LineChartDataSet(entries: vibrationDataEntries, label: "Vibration Data")
        
        dataSetVibration.colors = [NSUIColor.purple]
        dataSetVibration.drawCirclesEnabled = false
        
        let data = LineChartData(dataSet: dataSetVibration)
        vibrationChartView.data = data
        
        let legend = vibrationChartView.legend
        legend.enabled = true
        legend.textColor = NSUIColor.white
        legend.formSize = 10.0
        legend.form = .circle
        
        vibrationChartView.notifyDataSetChanged()
    }
    
    func sendTelemetryToAzureIoT(data: [String: Double]) {
        guard let url = URL(string: "\(iotHubEndpoint)/devices/\(deviceId)/messages/events?api-version=2018-06-30") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Generate SAS token and set it in the Authorization header
        if let sasToken = generateSasToken(uri: url, keyName: "service", key: sharedAccessKey ?? "") {
            request.setValue(sasToken, forHTTPHeaderField: "Authorization")
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                request.httpBody = jsonData
                
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        print("Error sending telemetry data: \(error)")
                    } else if let data = data {
                        let responseString = String(data: data, encoding: .utf8)
                        print("Telemetry data sent successfully. Response: \(responseString ?? "")")
                    }
                }
                
                task.resume()
            } catch {
                print("Error converting telemetry data to JSON")
            }
        }
    }
    
    func generateSasToken(uri: URL, keyName: String, key: String) -> String? {
        let expiry = Int(Date().timeIntervalSince1970 + 3600) // Token valid for 1 hour
        let stringToSign = "\(uri.path)\n\(expiry)"
        
        if let signature = signString(stringToSign: stringToSign, key: key) {
            return "SharedAccessSignature sr=\(uri.absoluteString)&sig=\(signature)&se=\(expiry)&skn=\(keyName)"
        }
        
        return nil
    }
    
    func signString(stringToSign: String, key: String) -> String? {
        guard let keyData = key.data(using: .utf8), let stringData = stringToSign.data(using: .utf8) else {
            return nil
        }

        var result = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        keyData.withUnsafeBytes { keyBytes in
            stringData.withUnsafeBytes { stringBytes in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBytes.baseAddress, keyData.count, stringBytes.baseAddress, stringData.count, &result)
            }
        }

        let signature = Data(result)
        let base64Signature = signature.base64EncodedString()

        return base64Signature
    }
}
