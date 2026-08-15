import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

admin.initializeApp();

const db = admin.firestore();

/* ============================================================
   TYPES
============================================================ */

interface CreateStaffPayload {
  name: string;
  email: string;
  phone?: string;
}

/* ============================================================
   CREATE STAFF ACCOUNT
============================================================ */

export const createStaffAccount = functions.https.onCall(
  async (
    data: CreateStaffPayload,
    context
  ): Promise<{
    success: boolean;
    uid?: string;
    invitationLink?: string;
    error?: string;
  }> => {
    // ----------------------------------------------------------
    // 1. Make sure the caller is logged in
    // ----------------------------------------------------------

    if (!context.auth) {
      return {
        success: false,
        error: 'Unauthenticated',
      };
    }

    // ----------------------------------------------------------
    // 2. Check that the caller is an ADMIN
    // ----------------------------------------------------------

    const callerDoc = await db
      .collection('users')
      .doc(context.auth.uid)
      .get();

    if (!callerDoc.exists || callerDoc.data()?.role !== 'admin') {
      return {
        success: false,
        error: 'Forbidden',
      };
    }

    // ----------------------------------------------------------
    // 3. Validate input
    // ----------------------------------------------------------

    const name = data.name?.trim();
    const email = data.email?.trim().toLowerCase();
    const phone = data.phone?.trim() ?? '';

    if (!name || !email) {
      return {
        success: false,
        error: 'Missing required fields',
      };
    }

    try {
      // --------------------------------------------------------
      // 4. Check if email already exists in Firebase Auth
      // --------------------------------------------------------

      const existingUser = await admin
        .auth()
        .getUserByEmail(email)
        .catch(() => null);

      if (existingUser) {
        return {
          success: false,
          error: 'Email already in use',
        };
      }

      // --------------------------------------------------------
      // 5. Create Firebase Authentication account
      //
      // No password is assigned here.
      // The staff member will create their password through
      // the password-reset/setup link.
      // --------------------------------------------------------

      const userRecord = await admin.auth().createUser({
        email: email,
        displayName: name,
        emailVerified: false,
      });

      // --------------------------------------------------------
      // 6. Create staff Firestore profile
      // --------------------------------------------------------

      await db.collection('users').doc(userRecord.uid).set({
        uid: userRecord.uid,
        name: name,
        email: email,
        role: 'staff',
        phone: phone,
        isActive: true,
        status: 'pending',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // --------------------------------------------------------
      // 7. Generate password setup / reset link
      //
      // Firebase Admin can GENERATE the link,
      // but it cannot directly send the email.
      // --------------------------------------------------------

      const invitationLink = await admin
        .auth()
        .generatePasswordResetLink(email);

      // --------------------------------------------------------
      // 8. Return the invitation link
      // --------------------------------------------------------

      return {
        success: true,
        uid: userRecord.uid,
        invitationLink: invitationLink,
      };
    } catch (error) {
      functions.logger.error(
        'Error creating staff account',
        error
      );

      return {
        success: false,
        error: 'Failed to create staff account',
      };
    }
  }
);

/* ============================================================
   DISABLE STAFF ACCOUNT
============================================================ */

export const disableStaffAccount = functions.https.onCall(
  async (
    data: { uid: string },
    context
  ): Promise<{
    success: boolean;
    error?: string;
  }> => {
    // ----------------------------------------------------------
    // 1. Authentication check
    // ----------------------------------------------------------

    if (!context.auth) {
      return {
        success: false,
        error: 'Unauthenticated',
      };
    }

    // ----------------------------------------------------------
    // 2. Admin check
    // ----------------------------------------------------------

    const callerDoc = await db
      .collection('users')
      .doc(context.auth.uid)
      .get();

    if (!callerDoc.exists || callerDoc.data()?.role !== 'admin') {
      return {
        success: false,
        error: 'Forbidden',
      };
    }

    // ----------------------------------------------------------
    // 3. Validate UID
    // ----------------------------------------------------------

    if (!data.uid) {
      return {
        success: false,
        error: 'Missing staff UID',
      };
    }

    try {
      // Disable Firebase Authentication account
      await admin.auth().updateUser(data.uid, {
        disabled: true,
      });

      // Disable Firestore staff profile
      await db.collection('users').doc(data.uid).update({
        isActive: false,
        status: 'inactive',
      });

      return {
        success: true,
      };
    } catch (error) {
      functions.logger.error(
        'Error disabling staff account',
        error
      );

      return {
        success: false,
        error: 'Failed to disable staff account',
      };
    }
  }
);

/* ============================================================
   ENABLE STAFF ACCOUNT
============================================================ */

export const enableStaffAccount = functions.https.onCall(
  async (
    data: { uid: string },
    context
  ): Promise<{
    success: boolean;
    error?: string;
  }> => {
    // ----------------------------------------------------------
    // 1. Authentication check
    // ----------------------------------------------------------

    if (!context.auth) {
      return {
        success: false,
        error: 'Unauthenticated',
      };
    }

    // ----------------------------------------------------------
    // 2. Admin check
    // ----------------------------------------------------------

    const callerDoc = await db
      .collection('users')
      .doc(context.auth.uid)
      .get();

    if (!callerDoc.exists || callerDoc.data()?.role !== 'admin') {
      return {
        success: false,
        error: 'Forbidden',
      };
    }

    // ----------------------------------------------------------
    // 3. Validate UID
    // ----------------------------------------------------------

    if (!data.uid) {
      return {
        success: false,
        error: 'Missing staff UID',
      };
    }

    try {
      // Enable Firebase Authentication account
      await admin.auth().updateUser(data.uid, {
        disabled: false,
      });

      // Enable Firestore staff profile
      await db.collection('users').doc(data.uid).update({
        isActive: true,
        status: 'active',
      });

      return {
        success: true,
      };
    } catch (error) {
      functions.logger.error(
        'Error enabling staff account',
        error
      );

      return {
        success: false,
        error: 'Failed to enable staff account',
      };
    }
  }
);

/* ============================================================
   DELETE STAFF ACCOUNT
============================================================ */

export const deleteStaffAccount = functions.https.onCall(
  async (
    data: { uid: string },
    context
  ): Promise<{
    success: boolean;
    error?: string;
  }> => {
    // ----------------------------------------------------------
    // 1. Authentication check
    // ----------------------------------------------------------

    if (!context.auth) {
      return {
        success: false,
        error: 'Unauthenticated',
      };
    }

    // ----------------------------------------------------------
    // 2. Admin check
    // ----------------------------------------------------------

    const callerDoc = await db
      .collection('users')
      .doc(context.auth.uid)
      .get();

    if (!callerDoc.exists || callerDoc.data()?.role !== 'admin') {
      return {
        success: false,
        error: 'Forbidden',
      };
    }

    // ----------------------------------------------------------
    // 3. Prevent admin from deleting themselves
    // ----------------------------------------------------------

    if (data.uid === context.auth.uid) {
      return {
        success: false,
        error: 'Cannot delete your own account',
      };
    }

    // ----------------------------------------------------------
    // 4. Validate UID
    // ----------------------------------------------------------

    if (!data.uid) {
      return {
        success: false,
        error: 'Missing staff UID',
      };
    }

    try {
      // Delete Firebase Authentication account
      await admin.auth().deleteUser(data.uid);

      // Delete Firestore staff profile
      await db.collection('users').doc(data.uid).delete();

      return {
        success: true,
      };
    } catch (error) {
      functions.logger.error(
        'Error deleting staff account',
        error
      );

      return {
        success: false,
        error: 'Failed to delete staff account',
      };
    }
  }
);