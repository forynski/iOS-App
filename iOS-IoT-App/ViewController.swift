import UIKit
import CoreMotion
import Charts
import DGCharts

class ViewController: UIViewController {
    @IBOutlet var chartView: LineChartView!
    
    // Motion manager and dataEntries for real-time data capture
    let motionManager = CMMotionManager()
    var dataEntriesX: [ChartDataEntry] = []
    var dataEntriesY: [ChartDataEntry] = []
    var dataEntriesZ: [ChartDataEntry] = []
    var dataEntriesVibration: [ChartDataEntry] = []  // New array for vibration data

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up chart properties
        chartView.noDataText = "No data available"
        chartView.chartDescription.text = "Real-Time Data"  // Update chart description for real-time data

        // Comment out the sample data loading
        /*
        let sampleData: [ChartDataEntry] = [
            ChartDataEntry(x: 0.0, y: 0.5),
            ChartDataEntry(x: 1.0, y: 0.7),
            ChartDataEntry(x: 2.0, y: 0.3),
            ChartDataEntry(x: 3.0, y: 0.9),
            // Add more data points as needed
        ]
        
        let dataSet = LineChartDataSet(entries: sampleData, label: "Sample Data")
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
        */

        // Real-time data capture
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1  // Update interval in seconds

            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                if let accelerometerData = data {
                    let x = accelerometerData.acceleration.x
                    let y = accelerometerData.acceleration.y
                    let z = accelerometerData.acceleration.z
                    
                    // Calculate vibration level (hypothetical formula, adjust as needed)
                    let vibrationLevel = sqrt(x * x + y * y + z * z)

                    // Update the chart with new data
                    self.addEntry(x: x, y: y, z: z, vibration: vibrationLevel)
                }
            }
        } else {
            print("Accelerometer not available.")
        }
    }

    // Function to add real-time data capture to the chart
    func addEntry(x: Double, y: Double, z: Double, vibration: Double) {
        dataEntriesX.append(ChartDataEntry(x: Double(dataEntriesX.count), y: x))
        dataEntriesY.append(ChartDataEntry(x: Double(dataEntriesY.count), y: y))
        dataEntriesZ.append(ChartDataEntry(x: Double(dataEntriesZ.count), y: z))
        dataEntriesVibration.append(ChartDataEntry(x: Double(dataEntriesVibration.count), y: vibration))  // Add vibration data
        
        let dataSetX = LineChartDataSet(entries: dataEntriesX, label: "X-Axis Data")
        let dataSetY = LineChartDataSet(entries: dataEntriesY, label: "Y-Axis Data")
        let dataSetZ = LineChartDataSet(entries: dataEntriesZ, label: "Z-Axis Data")
        let dataSetVibration = LineChartDataSet(entries: dataEntriesVibration, label: "Vibration Level")  // Add vibration data set
        
        // Set colors for each dataset
        dataSetX.colors = [NSUIColor.red]  // Set color for X-Axis Data
        dataSetY.colors = [NSUIColor.blue]  // Set color for Y-Axis Data
        dataSetZ.colors = [NSUIColor.green]  // Set color for Z-Axis Data
        dataSetVibration.colors = [NSUIColor.purple]  // Set color for Vibration Level
        
        // Set drawCirclesEnabled to false to hide dots on the chart
        dataSetX.drawCirclesEnabled = false
        dataSetY.drawCirclesEnabled = false
        dataSetZ.drawCirclesEnabled = false
        dataSetVibration.drawCirclesEnabled = false
        
        let data = LineChartData(dataSets: [dataSetX, dataSetY, dataSetZ, dataSetVibration])  // Include vibration data set
        chartView.data = data
        chartView.notifyDataSetChanged()
    }

    // Be sure to stop the accelerometer updates when they're no longer needed
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManager.stopAccelerometerUpdates()
    }
}
