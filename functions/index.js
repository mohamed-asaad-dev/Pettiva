const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK (if not already initialized)
if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Callable Cloud Function to create a new Firebase user and set custom claims.
 * Expects data: { email: string, password: string, userType: 'client' | 'fleet' }
 */
exports.createUserWithClaims = functions.https.onCall(async (data, context) => {
  // Optional: Add authentication/authorization checks if only certain users
  // (e.g., an admin) should be able to create users through this endpoint.
  // if (!context.auth) {
  //   throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
  // }
  // if (!context.auth.token.admin) { // Example: check for an existing admin claim
  //   throw new functions.https.HttpsError('permission-denied', 'You do not have permission to create users.');
  // }


  // 1. Verify the request data
  const email = data.email;
  const password = data.password;
  const userType = data.userType;

  if (!email || !password || !userType) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing email, password, or userType.'
    );
  }

  if (userType !== 'client' && userType !== 'fleet') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      "Invalid userType. Must be 'client' or 'fleet'."
    );
  }

  try {
    // 2. Create the user in Firebase Authentication
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: `${userType.charAt(0).toUpperCase() + userType.slice(1)} User`, // Optional: set a display name
    });
    const userUid = userRecord.uid;
    console.log(`User created: ${userUid} with email ${email}`);

    // 3. Set custom claims for the new user
    const customClaims = { userType: userType };
    await admin.auth().setCustomUserClaims(userUid, customClaims);
    console.log(`Custom claims set for user ${userUid}:`, customClaims);

    // 4. Return success to the client
    return { success: true, uid: userUid, message: "User created and claims set successfully." };

  } catch (error) {
    console.error("Error during user creation or claim setting:", error);

    // Handle specific Firebase Auth errors
    if (error.code === 'auth/email-already-exists') {
      throw new functions.https.HttpsError(
        'already-exists',
        'The email address is already in use by another account.'
      );
    }
    if (error.code === 'auth/invalid-password') {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'The password provided is invalid (should be at least 6 characters).'
        );
    }
    // Generic error handling
    throw new functions.https.HttpsError(
      'internal',
      'An unexpected error occurred during user creation.',
      error.message
    );
  }
});

