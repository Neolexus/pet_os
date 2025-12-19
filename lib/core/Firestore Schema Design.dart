// Users collection
users/{userId}:
  - uid: string
  - email: string
  - displayName: string
  - photoURL: string
  - isPremium: boolean
  - premiumUntil: timestamp
  - createdAt: timestamp

// Pets collection
pets/{petId}:
  - ownerId: string (reference to users)
  - name: string
  - type: string (dog/cat/etc.)
  - breed: string
  - age: number
  - weight: number
  - chronicConditions: array
  - createdAt: timestamp

// Symptoms collection
symptoms/{symptomId}:
  - petId: string (reference to pets)
  - userId: string (reference to users)
  - description: string
  - mediaUrls: array
  - triageResult: string (Monitor/VetSoon/Emergency)
  - aiAnalysis: map
  - createdAt: timestamp

// Logs collection (polymorphic)
logs/{logId}:
  - type: string (meal/stool/medication/vital)
  - petId: string
  - userId: string
  - data: map (type-specific data)
  - timestamp: timestamp

// Reports collection
reports/{reportId}:
  - petId: string
  - userId: string
  - period: string (last30Days)
  - pdfUrl: string
  - createdAt: timestamp