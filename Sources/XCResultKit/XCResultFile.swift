//
//  XCResultFile.swift
//  
//
//  Created by David House on 7/6/19.
//

import Foundation

public class XCResultFile {
    
    let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public func getInvocationRecord() -> ActionsInvocationRecord? {
        
        guard let data = xcrun(["xcresulttool", "get", "--path", url.path, "--format", "json"]) else {
            return nil
        }
        
        do {
            guard let rootJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
                logError("Expecting top level dictionary but didn't find one")
                return nil
            }
            
            let invocation = ActionsInvocationRecord(rootJSON)
            return invocation
        } catch {
            logError("Error deserializing JSON: \(error)")
            return nil
        }
    }
    
    public func getTestPlanRunSummaries(id: String) -> ActionTestPlanRunSummaries? {
        
        guard let data = xcrun(["xcresulttool", "get", "--path", url.path, "--id", id, "--format", "json"]) else {
            return nil
        }
        
        do {
            guard let rootJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
                logError("Expecting top level dictionary but didn't find one")
                return nil
            }
            
            let runSummaries = ActionTestPlanRunSummaries(rootJSON)
            return runSummaries
        } catch {
            logError("Error deserializing JSON: \(error)")
            return nil
        }
    }

    public func getLogs(id: String) -> ActivityLogSection? {
        guard let data = xcrun(["xcresulttool", "get", "--path", url.path, "--id", id, "--format", "json"]) else {
            return nil
        }

        do {
            guard let rootJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
                logError("Expecting top level dictionary but didn't find one")
                return nil
            }

            return ActivityLogSection(rootJSON)
        } catch {
            logError("Error deserializing JSON: \(error)")
            return nil
        }
    }
    
    public func getActionTestSummary(id: String) -> ActionTestSummary? {
        
        guard let data = xcrun(["xcresulttool", "get", "--path", url.path, "--id", id, "--format", "json"]) else {
            return nil
        }
        
        do {
            guard let rootJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
                logError("Expecting top level dictionary but didn't find one")
                return nil
            }
            
            let summary = ActionTestSummary(rootJSON)
            return summary
        } catch {
            logError("Error deserializing JSON: \(error)")
            return nil
        }
    }
    
    public func getPayload(id: String) -> Data? {
        
        guard let data = xcrun(["xcresulttool", "get", "--path", url.path, "--id", id]) else {
            return nil
        }
        return data
    }
    
    public func exportPayload(id: String) -> URL? {
        
        let tempPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(id)
        _ = xcrun(["xcresulttool", "export", "--type", "file", "--path", url.path, "--id", id, "--output-path", tempPath.path])
        return tempPath
    }
    
    public func getCodeCoverage() -> CodeCoverage? {
        
        guard let data = xcrun(["xccov", "view", "--report", "--json", url.path]) else {
            return nil
        }

        do {
            let decoded = try JSONDecoder().decode(CodeCoverage.self, from: data)
            return decoded
        } catch {
            logError("Error deserializing JSON: \(error)")
            return nil
        }
    }
    
    private func xcrun(_ arguments: [String]) -> Data? {
        autoreleasepool {
            let task = Process()
            task.launchPath = "/usr/bin/xcrun"
            task.arguments = arguments
            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.launch()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()

            task.waitUntilExit()

            let taskSucceeded = task.terminationStatus == EXIT_SUCCESS
            return taskSucceeded ? data : nil
        }
    }
}
