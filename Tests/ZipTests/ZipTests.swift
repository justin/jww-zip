import Foundation
import Testing
@testable import Zip

/// Tests to validate zipping and unzipping behavior.
///
/// The suite is serialized because the custom file extension tests mutate the
/// shared state on `Zip`, which would race under Swift Testing's default
/// parallel execution.
@Suite(.serialized)
final class ZipTests {
    /// URLs to remove when the test instance is torn down.
    private var cleanupURLs: [URL] = []

    deinit {
        let fileManager = FileManager.default
        for url in cleanupURLs {
            try? fileManager.removeItem(at: url)
        }
    }

    /// Registers a URL for removal when the test finishes.
    private func removeAtTeardown(_ url: URL) {
        cleanupURLs.append(url)
    }

    private func url(forResource resource: String, withExtension ext: String? = nil) -> URL? {
        return Bundle.module.url(forResource: resource, withExtension: ext)
    }

    /// Creates a unique temporary directory that is removed at teardown.
    private func autoRemovingSandbox() throws -> URL {
        let sandbox = FileManager.default.temporaryDirectory
            .appendingPathComponent("ZipTests_" + UUID().uuidString, isDirectory: true)
        // We can always create it. UUID should be unique.
        try FileManager.default.createDirectory(at: sandbox, withIntermediateDirectories: true, attributes: nil)
        removeAtTeardown(sandbox)
        return sandbox
    }

    @Test("Quick unzip returns an existing destination")
    func quickUnzip() throws {
        let filePath = try #require(url(forResource: "bb8", withExtension: "zip"))
        let destinationURL = try Zip.quickUnzipFile(filePath)
        removeAtTeardown(destinationURL)
        #expect(FileManager.default.fileExists(atPath: destinationURL.path))
    }

    @Test("Quick unzip throws for a non-existing path")
    func quickUnzipNonExistingPath() {
        let filePath = URL(fileURLWithPath: "/some/path/to/nowhere/bb9.zip")
        #expect(throws: (any Error).self) {
            try Zip.quickUnzipFile(filePath)
        }
    }

    @Test("Quick unzip throws for a non-zip file")
    func quickUnzipNonZipPath() throws {
        let filePath = try #require(url(forResource: "3crBXeO", withExtension: "gif"))
        #expect(throws: (any Error).self) {
            try Zip.quickUnzipFile(filePath)
        }
    }

    @Test("Quick unzip reports progress")
    func quickUnzipProgress() throws {
        let filePath = try #require(url(forResource: "bb8", withExtension: "zip"))
        let destinationURL = try Zip.quickUnzipFile(filePath, progress: { progress in
            #expect(!progress.isNaN)
        })
        removeAtTeardown(destinationURL)
    }

    @Test("Quick unzip throws for a remote URL")
    func quickUnzipOnlineURL() {
        let filePath = URL(string: "http://www.google.com/google.zip")!
        #expect(throws: (any Error).self) {
            try Zip.quickUnzipFile(filePath)
        }
    }

    @Test("Unzip writes to a custom destination")
    func unzip() throws {
        let filePath = try #require(url(forResource: "bb8", withExtension: "zip"))
        let destinationPath = try autoRemovingSandbox()

        try Zip.unzipFile(filePath, destination: destinationPath, overwrite: true, password: "password", progress: nil)

        #expect(FileManager.default.fileExists(atPath: destinationPath.path))
    }

    @Test("Unzip supports implicit progress composition")
    func implicitProgressUnzip() throws {
        let progress = Progress(totalUnitCount: 1)

        let filePath = try #require(url(forResource: "bb8", withExtension: "zip"))
        let destinationPath = try autoRemovingSandbox()

        progress.becomeCurrent(withPendingUnitCount: 1)
        try Zip.unzipFile(filePath, destination: destinationPath, overwrite: true, password: "password", progress: nil)
        progress.resignCurrent()

        #expect(progress.totalUnitCount == progress.completedUnitCount)
    }

    @Test("Zip supports implicit progress composition")
    func implicitProgressZip() throws {
        let progress = Progress(totalUnitCount: 1)

        let imageURL1 = try #require(url(forResource: "3crBXeO", withExtension: "gif"))
        let imageURL2 = try #require(url(forResource: "kYkLkPf", withExtension: "gif"))
        let sandboxFolder = try autoRemovingSandbox()
        let zipFilePath = sandboxFolder.appendingPathComponent("archive.zip")

        progress.becomeCurrent(withPendingUnitCount: 1)
        try Zip.zipFiles(paths: [imageURL1, imageURL2], zipFilePath: zipFilePath, password: nil, progress: nil)
        progress.resignCurrent()

        #expect(progress.totalUnitCount == progress.completedUnitCount)
    }

    @Test("Quick zip creates an archive")
    func quickZip() throws {
        let imageURL1 = try #require(url(forResource: "3crBXeO", withExtension: "gif"))
        let imageURL2 = try #require(url(forResource: "kYkLkPf", withExtension: "gif"))
        let destinationURL = try Zip.quickZipFiles([imageURL1, imageURL2], fileName: "archive")
        removeAtTeardown(destinationURL)
        #expect(FileManager.default.fileExists(atPath: destinationURL.path))
    }

    @Test("Quick zip archives a folder")
    func quickZipFolder() throws {
        let fileManager = FileManager.default
        let imageURL1 = try #require(url(forResource: "3crBXeO", withExtension: "gif"))
        let imageURL2 = try #require(url(forResource: "kYkLkPf", withExtension: "gif"))
        let folderURL = try autoRemovingSandbox()
        let targetImageURL1 = folderURL.appendingPathComponent("3crBXeO.gif")
        let targetImageURL2 = folderURL.appendingPathComponent("kYkLkPf.gif")
        try fileManager.copyItem(at: imageURL1, to: targetImageURL1)
        try fileManager.copyItem(at: imageURL2, to: targetImageURL2)
        let destinationURL = try Zip.quickZipFiles([folderURL], fileName: "directory")
        removeAtTeardown(destinationURL)
        #expect(fileManager.fileExists(atPath: destinationURL.path))
    }

    @Test("Zip writes to a custom destination")
    func zip() throws {
        let imageURL1 = try #require(url(forResource: "3crBXeO", withExtension: "gif"))
        let imageURL2 = try #require(url(forResource: "kYkLkPf", withExtension: "gif"))
        let sandboxFolder = try autoRemovingSandbox()
        let zipFilePath = sandboxFolder.appendingPathComponent("archive.zip")
        try Zip.zipFiles(paths: [imageURL1, imageURL2], zipFilePath: zipFilePath, password: nil, progress: nil)
        #expect(FileManager.default.fileExists(atPath: zipFilePath.path))
    }

    @Test("Password-protected archives round-trip")
    func zipUnzipPassword() throws {
        let imageURL1 = try #require(url(forResource: "3crBXeO", withExtension: "gif"))
        let imageURL2 = try #require(url(forResource: "kYkLkPf", withExtension: "gif"))
        let zipFilePath = try autoRemovingSandbox().appendingPathComponent("archive.zip")
        try Zip.zipFiles(paths: [imageURL1, imageURL2], zipFilePath: zipFilePath, password: "password", progress: nil)
        let fileManager = FileManager.default
        #expect(fileManager.fileExists(atPath: zipFilePath.path))
        let directoryName = zipFilePath.lastPathComponent.replacingOccurrences(of: ".\(zipFilePath.pathExtension)", with: "")
        let destinationUrl = try autoRemovingSandbox().appendingPathComponent(directoryName, isDirectory: true)
        try Zip.unzipFile(zipFilePath, destination: destinationUrl, overwrite: true, password: "password", progress: nil)
        #expect(fileManager.fileExists(atPath: destinationUrl.path))
    }

    @Test("Unzip preserves unsupported permissions as the default")
    func unzipWithUnsupportedPermissions() throws {
        let permissionsURL = try #require(url(forResource: "unsupported_permissions", withExtension: "zip"))
        let unzipDestination = try Zip.quickUnzipFile(permissionsURL)
        removeAtTeardown(unzipDestination)
        let permission644 = unzipDestination.appendingPathComponent("unsupported_permission").appendingPathExtension("txt")
        let foundPermissions = try FileManager.default.attributesOfItem(atPath: permission644.path)[.posixPermissions] as? Int
        #if os(Linux)
        let expectedPermissions = 0o664
        #else
        let expectedPermissions = 0o644
        #endif
        #expect(foundPermissions != nil)
        #expect(foundPermissions == expectedPermissions,
                "\(foundPermissions.map { String($0, radix: 8) } ?? "nil") is not equal to \(String(expectedPermissions, radix: 8))")
    }

    @Test("Unzip preserves file permissions")
    func unzipPermissions() throws {
        let permissionsURL = try #require(url(forResource: "permissions", withExtension: "zip"))
        let unzipDestination = try Zip.quickUnzipFile(permissionsURL)
        removeAtTeardown(unzipDestination)
        let fileManager = FileManager.default
        let permission777 = unzipDestination.appendingPathComponent("permission_777").appendingPathExtension("txt")
        let permission600 = unzipDestination.appendingPathComponent("permission_600").appendingPathExtension("txt")
        let permission604 = unzipDestination.appendingPathComponent("permission_604").appendingPathExtension("txt")

        let attributes777 = try fileManager.attributesOfItem(atPath: permission777.path)
        let attributes600 = try fileManager.attributesOfItem(atPath: permission600.path)
        let attributes604 = try fileManager.attributesOfItem(atPath: permission604.path)
        #expect(attributes777[.posixPermissions] as? Int == 0o777)
        #expect(attributes600[.posixPermissions] as? Int == 0o600)
        #expect(attributes604[.posixPermissions] as? Int == 0o604)
    }

    // Tests that https://github.com/marmelroy/Zip/issues/245 does not occur anymore.
    @Test("Unzip protects against path traversal")
    func unzipProtectsAgainstPathTraversal() throws {
        let filePath = try #require(url(forResource: "pathTraversal", withExtension: "zip"))
        let destinationPath = try autoRemovingSandbox()

        #expect(throws: (any Error).self) {
            try Zip.unzipFile(filePath, destination: destinationPath, overwrite: true, password: "password", progress: nil)
        }

        let fileManager = FileManager.default
        #expect(!fileManager.fileExists(atPath: destinationPath.appendingPathComponent("../naughtyFile.txt").path))
    }

    @Test("Quick unzip restores nested directories")
    func quickUnzipSubDir() throws {
        let bookURL = try #require(url(forResource: "bb8", withExtension: "zip"))
        let unzipDestination = try Zip.quickUnzipFile(bookURL)
        removeAtTeardown(unzipDestination)
        let fileManager = FileManager.default
        let subDir = unzipDestination.appendingPathComponent("subDir")
        let imageURL = subDir.appendingPathComponent("r2W9yu9").appendingPathExtension("gif")

        #expect(fileManager.fileExists(atPath: unzipDestination.path))
        #expect(fileManager.fileExists(atPath: subDir.path))
        #expect(fileManager.fileExists(atPath: imageURL.path))
    }

    @Test("A known extension is valid")
    func fileExtensionIsNotInvalidForValidUrl() {
        let fileUrl = URL(string: "file.cbz")
        let result = Zip.fileExtensionIsInvalid(fileUrl?.pathExtension)
        #expect(!result)
    }

    @Test("An unknown extension is invalid")
    func fileExtensionIsInvalidForInvalidUrl() {
        let fileUrl = URL(string: "file.xyz")
        let result = Zip.fileExtensionIsInvalid(fileUrl?.pathExtension)
        #expect(result)
    }

    @Test("A custom extension becomes valid once added")
    func addedCustomFileExtensionIsValid() {
        let fileExtension = "cstm"
        Zip.addCustomFileExtension(fileExtension)
        let result = Zip.isValidFileExtension(fileExtension)
        #expect(result)
        Zip.removeCustomFileExtension(fileExtension)
    }

    @Test("A custom extension becomes invalid once removed")
    func removedCustomFileExtensionIsInvalid() {
        let fileExtension = "cstm"
        Zip.addCustomFileExtension(fileExtension)
        Zip.removeCustomFileExtension(fileExtension)
        let result = Zip.isValidFileExtension(fileExtension)
        #expect(!result)
    }

    @Test("The default extensions are valid")
    func defaultFileExtensionsIsValid() {
        #expect(Zip.isValidFileExtension("zip"))
        #expect(Zip.isValidFileExtension("cbz"))
    }

    @Test("The default extensions cannot be removed")
    func defaultFileExtensionsIsNotRemoved() {
        Zip.removeCustomFileExtension("zip")
        Zip.removeCustomFileExtension("cbz")
        #expect(Zip.isValidFileExtension("zip"))
        #expect(Zip.isValidFileExtension("cbz"))
    }
}
