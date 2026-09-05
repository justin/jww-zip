![Zip - Zip and unzip files in Swift](https://cloud.githubusercontent.com/assets/889949/12374908/252373d0-bcac-11e5-8ece-6933aeae8222.png)

[![CI](https://github.com/justin/jww-zip/actions/workflows/ci.yml/badge.svg)](https://github.com/justin/jww-zip/actions/workflows/ci.yml) [![SPM supported](https://img.shields.io/badge/SPM-supported-brightgreen.svg?style=flat)](https://swift.org/package-manager)

# Zip

A Swift framework for zipping and unzipping files. Simple and quick to use. Built on top of [minizip-ng](https://github.com/zlib-ng/minizip-ng) 4.2.2.

This is a fork of [marmelroy/Zip](https://github.com/marmelroy/Zip) by Roy Marmelstein, modernized for current Swift and Apple platforms.

## Usage

Import Zip at the top of the Swift file.

```swift
import Zip
```

## Quick functions

The easiest way to use Zip is through quick functions. Both take local file paths as `URL`s, throw if an error is encountered and return a `URL` to the destination if successful.

```swift
do {
    let filePath = Bundle.main.url(forResource: "file", withExtension: "zip")!
    let unzipDirectory = try Zip.quickUnzipFile(filePath) // Unzip
    let zipFilePath = try Zip.quickZipFiles([filePath], fileName: "archive") // Zip
}
catch {
    print("Something went wrong")
}
```

## Advanced Zip

For more advanced usage, Zip has functions that let you set custom destination paths, work with password protected zips and use a progress handling closure. These functions throw if there is an error but don't return.

```swift
do {
    let filePath = Bundle.main.url(forResource: "file", withExtension: "zip")!
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    try Zip.unzipFile(filePath, destination: documentsDirectory, overwrite: true, password: "password", progress: { (progress) -> () in
        print(progress)
    }) // Unzip

    let zipFilePath = documentsDirectory.appendingPathComponent("archive.zip")
    try Zip.zipFiles(paths: [filePath], zipFilePath: zipFilePath, password: "password", progress: { (progress) -> () in
        print(progress)
    }) // Zip
}
catch {
    print("Something went wrong")
}
```

## Custom File Extensions

Zip supports '.zip' and '.cbz' files out of the box. To support additional zip-derivative file extensions:

```swift
Zip.addCustomFileExtension("file-extension-here")
```

## Installation

Zip is distributed as a [Swift Package](https://swift.org/package-manager). Add it to your package's dependencies:

```swift
.package(url: "https://github.com/justin/jww-zip.git", from: "2.1.0")
```

Then add `Zip` to the dependencies of any target that needs it:

```swift
.target(name: "MyTarget", dependencies: ["Zip"])
```

## License

Licensed under the MIT license. Copyright 2015 Roy Marmelstein, 2026 Justin Williams.
