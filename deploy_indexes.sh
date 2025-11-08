#!/bin/bash
# Deploy Firestore indexes to Firebase

echo "Deploying Firestore indexes..."
firebase deploy --only firestore:indexes

echo "Done! Indexes are being created in the background."
echo "You can check the status in the Firebase Console under Firestore > Indexes"
