import Foundation
import UIKit
import CoreLocation
import ImageIO

class MediaRepository {

    // YOUR GitHub username and repo name — change these!
    private let githubOwner = "MrAlphaF"
    private let githubRepo = "minestagram-photos"

    // Fetch image list from GitHub Contents API, download each one, cache to Documents
    func fetchAndCacheImages() async -> [URL] {
        let apiURL = URL(string: "https://api.github.com/repos/\(githubOwner)/\(githubRepo)/contents")!
        let fileManager = FileManager.default
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        // If already cached, return cached files immediately (offline support)
        let cached = cachedImageURLs()
        if !cached.isEmpty { return cached }

        do {
            let (data, _) = try await URLSession.shared.data(from: apiURL)
            let contents = try JSONDecoder().decode([GHContent].self, from: data)
            let imageFiles = contents.filter { ($0.name ?? "").hasSuffix(".jpg") || ($0.name ?? "").hasSuffix(".png") }

            var result: [URL] = []
            for file in imageFiles {
                guard let name = file.name,
                      let downloadURLString = file.downloadURL,
                      let downloadURL = URL(string: downloadURLString) else { continue }

                let destURL = docs.appendingPathComponent(name)

                if !fileManager.fileExists(atPath: destURL.path) {
                    let (imageData, _) = try await URLSession.shared.data(from: downloadURL)
                    try imageData.write(to: destURL)
                }
                result.append(destURL)
            }
            return result
        } catch {
            print("GitHub fetch failed: \(error) — falling back to bundle")
            return cacheImagesToDocumentsIfNeeded()
        }
    }

    // Returns already-cached images from Documents (used for offline)
    func cachedImageURLs() -> [URL] {
        let fileManager = FileManager.default
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return (try? fileManager.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil))?
            .filter { $0.pathExtension == "jpg" || $0.pathExtension == "png" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent } ?? []
    }

    // Fallback: copy from app bundle (used if GitHub fetch fails or during development)
    @discardableResult
    func cacheImagesToDocumentsIfNeeded() -> [URL] {
        var urls: [URL] = []
        let fileManager = FileManager.default
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        for i in 1...39 {
            let fileName = "PolijaTatri-\(i).jpg"
            let destURL = docs.appendingPathComponent(fileName)

            if !fileManager.fileExists(atPath: destURL.path) {
                if let bundleURL = Bundle.main.url(forResource: "PolijaTatri-\(i)", withExtension: "jpg") {
                    try? fileManager.copyItem(at: bundleURL, to: destURL)
                }
            }
            if fileManager.fileExists(atPath: destURL.path) {
                urls.append(destURL)
            }
        }
        return urls
    }

    func getPhotoLocations() -> [PhotoLocation] {
        let urls = cachedImageURLs().isEmpty ? cacheImagesToDocumentsIfNeeded() : cachedImageURLs()
        var locations = [PhotoLocation]()
        for url in urls {
            if let coordinates = getGpsCoordinates(fromURL: url) {
                locations.append(PhotoLocation(name: url.lastPathComponent, coordinate: coordinates))
            }
        }
        return locations
    }
}

// MARK: - Metadata Extraction
extension MediaRepository {
    func readMetadata(fromURL url: URL?) -> NSDictionary? {
        guard let url = url else { return nil }
        if let source = CGImageSourceCreateWithURL(url as CFURL, nil),
           let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) {
            return metadata as NSDictionary
        }
        return nil
    }

    func getGpsCoordinates(fromURL url: URL?) -> CLLocationCoordinate2D? {
        guard let exif = readMetadata(fromURL: url),
              let gpsDic = exif.value(forKey: "{GPS}") as? NSDictionary else { return nil }

        func dmsToDecimal(_ dmsArray: NSArray) -> Double? {
            guard dmsArray.count >= 3,
                  let deg = (dmsArray[0] as? NSNumber)?.doubleValue,
                  let min = (dmsArray[1] as? NSNumber)?.doubleValue,
                  let sec = (dmsArray[2] as? NSNumber)?.doubleValue else { return nil }
            return deg + (min / 60.0) + (sec / 3600.0)
        }

        var lat: Double?
        var lon: Double?

        if let latArray = gpsDic.value(forKey: "Latitude") as? NSArray {
            lat = dmsToDecimal(latArray)
        } else if let latDirect = gpsDic.value(forKey: "Latitude") as? Double {
            lat = latDirect
        }

        if let lonArray = gpsDic.value(forKey: "Longitude") as? NSArray {
            lon = dmsToDecimal(lonArray)
        } else if let lonDirect = gpsDic.value(forKey: "Longitude") as? Double {
            lon = lonDirect
        }

        guard var latitude = lat, var longitude = lon else { return nil }

        if let latRef = gpsDic.value(forKey: "LatitudeRef") as? String, latRef == "S" { latitude = -latitude }
        if let lonRef = gpsDic.value(forKey: "LongitudeRef") as? String, lonRef == "W" { longitude = -longitude }

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func getExif(fromURL url: URL?) -> Exif? {
        if let exif = readMetadata(fromURL: url) {
            var returnObject = Exif()
            if let exifDic = exif.value(forKey: "{Exif}") as? NSDictionary {
                returnObject.dateTaken = exifDic.value(forKey: "DateTimeOriginal") as? String
            }
            return returnObject
        }
        return nil
    }
}
