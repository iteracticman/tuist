import Foundation
import TSCBasic

/// Extract version from .xccurrentversion file.
public final class CoreDataVersionExtractor {
    /// Extract version from .xccurrentversion file
    /// - Parameter filePath: absolute path to Model.xcdatamodel
    /// - Throws: In case can not find the .xcurrentversion file.
    /// - Returns: Current version of data model.
    public static func version(fromVersionFileAtPath filePath: AbsolutePath) throws -> String {
        do {
            let data = try Data(contentsOf: filePath.appending(component: ".xccurrentversion").url)
            let decoder = PropertyListDecoder()
            let dict = try decoder.decode([String: String].self, from: data)
            guard
                let currentVersionName = dict["_XCCurrentVersionName"],
                let versionNumberString = currentVersionName.split(separator: ".").first
            else {
                throw CoreDataVersionExtractorError.couldNotExtractVersionFrom(filePath)
            }
            return String(versionNumberString)
        } catch {
            throw CoreDataVersionExtractorError.couldNotReadCurrentVersion(filePath)
        }
    }
}

public enum CoreDataVersionExtractorError: FatalError, Equatable {
    /// Thrown when the version could not be extracted from plist
    case couldNotExtractVersionFrom(AbsolutePath)

    /// Thrown when the xccurrentversion can't be read.
    case couldNotReadCurrentVersion(AbsolutePath)

    public var type: ErrorType {
        switch self {
        case .couldNotExtractVersionFrom: return .abort
        case .couldNotReadCurrentVersion: return .abort
        }
    }

    public var description: String {
        switch self {
        case let .couldNotExtractVersionFrom(path):
            return "Couldn't locate current version in .xccurrentversion from path \(path.pathString). Try setting the current version manually or check if the current version is set it in your project."
        case let .couldNotReadCurrentVersion(path):
            return "Couldn't read the xccurrentversion from path \(path.pathString). Try setting the current version manually or check if the current version is set it in your project."
        }
    }
}
