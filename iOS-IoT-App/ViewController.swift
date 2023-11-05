import UIKit
import CoreMotion
import Charts
import DGCharts

class ViewController: UIViewController {
    @IBOutlet var chartView: LineChartView!
    
    // Comment out the motion manager and dataEntries for real-time data capture
    // let motionManager = CMMotionManager()
    // var dataEntries: [ChartDataEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up chart properties
        chartView.noDataText = "No data available"
        chartView.chartDescription.text = "Sample Data"  // Chart description

        // Load sample data into the chart
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

        // Comment out the real-time data capture
        /*
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1  // Update interval in seconds

            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                if let accelerometerData = data {
                    let x = accelerometerData.acceleration.x
                    let y = accelerometerData.acceleration.y
                    let z = accelerometerData.acceleration.z

                    // Update the chart with new data
                    self.addEntry(x: x)
                }
            }
        } else {
            print("Accelerometer not available.")
        }
        */
    }

    // Comment out the addEntry function for real-time data capture
    /*
    // Function to add a data entry to the chart
    func addEntry(x: Double) {
        dataEntries.append(ChartDataEntry(x: Double(dataEntries.count), y: x))
        let dataSet = LineChartDataSet(entries: dataEntries, label: "X-Axis Data")
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
        chartView.notifyDataSetChanged()
    }
    */

    // Comment out the viewWillDisappear function for real-time data capture
    /*
    // Be sure to stop the accelerometer updates when they're no longer needed
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManager.stopAccelerometerUpdates()
    }
    */
}
