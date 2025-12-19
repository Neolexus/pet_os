const functions = require('firebase-functions');
const admin = require('firebase-admin');
const PDFDocument = require('pdfkit');
const { Storage } = require('@google-cloud/storage');

admin.initializeApp();
const storage = new Storage();

exports.generatePetHealthReport = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
  }

  const { petId, period } = data;
  const userId = context.auth.uid;

  try {
    // Fetch pet data
    const petDoc = await admin.firestore().doc(`pets/${petId}`).get();
    if (!petDoc.exists || petDoc.data().ownerId !== userId) {
      throw new functions.https.HttpsError('not-found', 'Pet not found');
    }

    // Fetch logs for the period
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const logsSnapshot = await admin.firestore()
      .collection('logs')
      .where('petId', '==', petId)
      .where('timestamp', '>=', thirtyDaysAgo)
      .orderBy('timestamp', 'desc')
      .get();

    // Generate PDF
    const doc = new PDFDocument();
    const pdfBuffer = await new Promise((resolve) => {
      const buffers = [];
      doc.on('data', buffers.push.bind(buffers));
      doc.on('end', () => resolve(Buffer.concat(buffers)));
      
      // PDF content generation
      doc.fontSize(20).text('Pet Health Report', { align: 'center' });
      doc.moveDown();
      doc.fontSize(12).text(`Pet: ${petDoc.data().name}`);
      doc.text(`Period: Last 30 Days`);
      doc.moveDown();
      
      // Add logs data
      logsSnapshot.forEach(logDoc => {
        const log = logDoc.data();
        doc.text(`${log.timestamp.toDate().toLocaleDateString()}: ${log.type}`);
      });
      
      doc.end();
    });

    // Upload to Firebase Storage
    const bucket = storage.bucket('your-app.appspot.com');
    const fileName = `reports/${userId}/${petId}_${Date.now()}.pdf`;
    const file = bucket.file(fileName);
    
    await file.save(pdfBuffer, {
      metadata: { contentType: 'application/pdf' },
    });

    // Generate signed URL
    const [url] = await file.getSignedUrl({
      action: 'read',
      expires: Date.now() + 1000 * 60 * 60 * 24 * 7, // 7 days
    });

    // Save report metadata to Firestore
    await admin.firestore().collection('reports').add({
      userId,
      petId,
      period: 'last30Days',
      pdfUrl: url,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, pdfUrl: url };
  } catch (error) {
    console.error('Error generating report:', error);
    throw new functions.https.HttpsError('internal', 'Failed to generate report');
  }
});