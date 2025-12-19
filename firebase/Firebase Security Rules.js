rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Users can only access their own pets
    match /pets/{petId} {
      allow read, write: if request.auth != null && 
        resource.data.ownerId == request.auth.uid;
    }

    // Users can only access symptoms for their pets
    match /symptoms/{symptomId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }

    // Similar rules for logs, reports, etc.
    match /logs/{logId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }

    match /reports/{reportId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}