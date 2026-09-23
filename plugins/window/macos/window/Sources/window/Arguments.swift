import Foundation

struct ArgumentError: Error {
    let key: String
}

struct Arguments {
    private let values: [String: Any]

    init(_ values: [String: Any]) {
        self.values = values
    }

    func bool(_ key: String) throws -> Bool {
        guard let value = values[key] as? Bool else {
            throw ArgumentError(key: key)
        }
        return value
    }

    func double(_ key: String) throws -> Double {
        guard let value = values[key] as? NSNumber else {
            throw ArgumentError(key: key)
        }
        return value.doubleValue
    }

    func string(_ key: String) throws -> String {
        guard let value = values[key] as? String else {
            throw ArgumentError(key: key)
        }
        return value
    }

    func optionalDouble(_ key: String) throws -> Double? {
        guard let raw = values[key], !(raw is NSNull) else {
            return nil
        }
        guard let value = raw as? NSNumber else {
            throw ArgumentError(key: key)
        }
        return value.doubleValue
    }

    func optionalString(_ key: String) throws -> String? {
        guard let raw = values[key], !(raw is NSNull) else {
            return nil
        }
        guard let value = raw as? String else {
            throw ArgumentError(key: key)
        }
        return value
    }

    func optionalInt(_ key: String) throws -> Int? {
        guard let raw = values[key], !(raw is NSNull) else {
            return nil
        }
        guard let value = raw as? NSNumber else {
            throw ArgumentError(key: key)
        }
        return value.intValue
    }
}
