import UIKit
import CoreMotion
import Charts
import DGCharts

class ViewController: UIViewController {
    @IBOutlet var chartView: LineChartView!

    let motionManager = CMMotionManager()
    var dataEntries: [ChartDataEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        chartView.noDataText = "No data available"
        chartView.chartDescription.text = "Real-Time Data"

        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1

            motionManager.startGyroUpdates(to: .main) { (data, error) in
                if let gyroData = data {
                    let x = gyroData.rotationRate.x
                    let y = gyroData.rotationRate.y
                    let z = gyroData.rotationRate.z

                    let vibrationLevel = sqrt(x * x + y * y + z * z)

                    self.addEntry(x: x, y: y, z: z, vibration: vibrationLevel)
                }
            }
        } else {
            print("Gyroscope not available.")
        }
    }

    func addEntry(x: Double, y: Double, z: Double, vibration: Double) {
        dataEntries.append(ChartDataEntry(x: Double(dataEntries.count), y: x))
        dataEntries.append(ChartDataEntry(x: Double(dataEntries.count), y: y))
        dataEntries.append(ChartDataEntry(x: Double(dataEntries.count), y: z))
        dataEntries.append(ChartDataEntry(x: Double(dataEntries.count), y: vibration))

        let dataSetX = LineChartDataSet(entries: dataEntries, label: "X, Y, Z, Vibration Data")

        dataSetX.colors = [NSUIColor.red, NSUIColor.blue, NSUIColor.green, NSUIColor.purple]
        dataSetX.drawCirclesEnabled = false

        let data = LineChartData(dataSet: dataSetX)
        chartView.data = data
        chartView.notifyDataSetChanged()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManager.stopGyroUpdates()
    }
}
