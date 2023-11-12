import UIKit
import CoreMotion
import Charts
import DGCharts

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

     override func viewDidLoad() {
         super.viewDidLoad()

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

     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         motionManager.stopGyroUpdates()
         motionManager.stopAccelerometerUpdates()
     }
 }
