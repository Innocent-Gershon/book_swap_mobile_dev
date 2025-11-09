const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'book-56e13.firebasestorage.app'
});

const db = admin.firestore();
const bucket = admin.storage().bucket();

async function fixImageUrls() {
  const booksSnapshot = await db.collection('books').get();
  
  for (const doc of booksSnapshot.docs) {
    const data = doc.data();
    const imageUrl = data.imageUrl;
    
    if (imageUrl && imageUrl.startsWith('gs://')) {
      console.log(`Fixing book ${doc.id}...`);
      
      // Extract filename from gs:// URL
      const gsPath = imageUrl.replace('gs://book-56e13.firebasestorage.app/', '');
      const file = bucket.file(gsPath);
      
      // Get download URL
      const [url] = await file.getSignedUrl({
        action: 'read',
        expires: '03-01-2500'
      });
      
      // Update Firestore
      await doc.ref.update({ imageUrl: url });
      console.log(`✅ Fixed: ${url}`);
    }
  }
  
  console.log('Done!');
  process.exit(0);
}

fixImageUrls().catch(console.error);
