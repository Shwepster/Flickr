
import Foundation

final class BackgroundUploadManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate, @unchecked Sendable {
    static let shared = BackgroundUploadManager()
    private var backgroundSession: URLSession!
    private let backgroundSessionIdentifier = "com.example.watchapp.upload"
    
    override init() {
        super.init()
        let config = URLSessionConfiguration.background(withIdentifier: backgroundSessionIdentifier)
        config.isDiscretionary = false            // Complete ASAP
        config.sessionSendsLaunchEvents = true    // Relaunch app when tasks finish
        config.waitsForConnectivity = true        // Wait for network availability
        
        backgroundSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    func startFirstBackgroundUpload(fileURL: URL, endpoint: String) {
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        
        let uploadTask = backgroundSession.uploadTask(with: request, fromFile: fileURL)
        uploadTask.resume()
    }
    
    func startNextBackgroundRequest() {
        print("Starting next request after successful upload.")
        // Add logic for subsequent uploads
    }
    
    // MARK: - URLSessionDelegate
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            print("All background events completed.")
            // Handle system wake-ups or clean-up
        }
    }
    
    // MARK: - URLSessionTaskDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Task failed: \(error.localizedDescription)")
            // Add retry logic if necessary
        } else {
            print("Task completed successfully.")
            startNextBackgroundRequest()
        }
    }
}
