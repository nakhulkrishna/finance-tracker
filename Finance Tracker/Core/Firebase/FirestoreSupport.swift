import Foundation
import FirebaseFirestore

enum FirestorePaths {
    static func userDocument(_ userID: String, in firestore: Firestore = Firestore.firestore()) -> DocumentReference {
        firestore.collection("users").document(userID)
    }

    static func profileDocument(for userID: String, in firestore: Firestore = Firestore.firestore()) -> DocumentReference {
        userDocument(userID, in: firestore).collection("profile").document("main")
    }

    static func billingDocument(for userID: String, in firestore: Firestore = Firestore.firestore()) -> DocumentReference {
        userDocument(userID, in: firestore).collection("billing").document("main")
    }

    static func homeDocument(for userID: String, in firestore: Firestore = Firestore.firestore()) -> DocumentReference {
        userDocument(userID, in: firestore).collection("finance").document("home")
    }

    static func investmentsDocument(for userID: String, in firestore: Firestore = Firestore.firestore()) -> DocumentReference {
        userDocument(userID, in: firestore).collection("finance").document("investments")
    }

    static func walletDocument(for userID: String, in firestore: Firestore = Firestore.firestore()) -> DocumentReference {
        userDocument(userID, in: firestore).collection("finance").document("wallet")
    }

    static func homeOperationsCollection(for userID: String, in firestore: Firestore = Firestore.firestore()) -> CollectionReference {
        homeDocument(for: userID, in: firestore).collection("operations")
    }

    static func investmentRecordsCollection(for userID: String, in firestore: Firestore = Firestore.firestore()) -> CollectionReference {
        investmentsDocument(for: userID, in: firestore).collection("records")
    }

    static func walletRecordsCollection(for userID: String, in firestore: Firestore = Firestore.firestore()) -> CollectionReference {
        walletDocument(for: userID, in: firestore).collection("records")
    }
}

enum FirestoreDocumentCodec {
    static func dictionary<T: Encodable>(from value: T, encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        let data = try encoder.encode(value)
        let object = try JSONSerialization.jsonObject(with: data)

        guard let dictionary = object as? [String: Any] else {
            throw FirestoreCodingError.invalidTopLevelObject
        }

        return dictionary
    }

    static func decode<T: Decodable>(
        _ type: T.Type,
        from dictionary: [String: Any],
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        return try decoder.decode(type, from: data)
    }

    enum FirestoreCodingError: Error {
        case invalidTopLevelObject
    }
}

extension DocumentReference {
    func getDocumentAsync() async throws -> DocumentSnapshot {
        try await withCheckedThrowingContinuation { continuation in
            getDocument { snapshot, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let snapshot {
                    continuation.resume(returning: snapshot)
                } else {
                    continuation.resume(throwing: FirestoreAsyncBridgeError.missingSnapshot)
                }
            }
        }
    }

    func setDataAsync(_ documentData: [String: Any], merge: Bool = false) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            setData(documentData, merge: merge) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}

extension Query {
    func getDocumentsAsync() async throws -> QuerySnapshot {
        try await withCheckedThrowingContinuation { continuation in
            getDocuments { snapshot, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let snapshot {
                    continuation.resume(returning: snapshot)
                } else {
                    continuation.resume(throwing: FirestoreAsyncBridgeError.missingSnapshot)
                }
            }
        }
    }
}

extension WriteBatch {
    func commitAsync() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            commit { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}

private enum FirestoreAsyncBridgeError: Error {
    case missingSnapshot
}
