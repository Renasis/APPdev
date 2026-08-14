import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

admin.initializeApp();

const db = admin.firestore();

interface CreateStaffPayload {
  name: string;
  email: string;
  role: 'staff';
  phone?: string;
}

export const createStaffAccount = functions.https.onCall(
  async (data: CreateStaffPayload, context): Promise<{ success: boolean; uid?: string; error?: string }> => {
    if (!context.auth) {
      return { success: false, error: 'Unauthenticated' };
    }

    const callerDoc = await db.collection('users').doc(context.auth.uid).get();
    if (!callerDoc.exists || callerDoc.data()?.role !== 'admin') {
      return { success: false, error: 'Forbidden' };
    }

    const { name, email, role, phone } = data;

    if (!name || !email || !role) {
      return { success: false, error: 'Missing required fields' };
    }

    try {
      const existingUser = await admin.auth().getUserByEmail(email).catch(() => null);
      if (existingUser) {
        return { success: false, error: 'Email already in use' };
      }

      const tempPassword = generateTemporaryPassword();
      const userRecord = await admin.auth().createUser({
        email,
        password: tempPassword,
        displayName: name,
      });

      await db.collection('users').doc(userRecord.uid).set({
        name,
        email,
        role,
        phone: phone ?? '',
        isActive: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      await admin.auth().sendPasswordResetEmail(email);

      return { success: true, uid: userRecord.uid };
    } catch (error) {
      functions.logger.error('Error creating staff account', error);
      return { success: false, error: 'Failed to create staff account' };
    }
  }
);

function generateTemporaryPassword(): string {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%';
  let password = '';
  for (let i = 0; i < 20; i++) {
    password += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return password;
}

export const disableStaffAccount = functions.https.onCall(
  async (data: { uid: string }, context): Promise<{ success: boolean; error?: string }> => {
    if (!context.auth) {
      return { success: false, error: 'Unauthenticated' };
    }

    const callerDoc = await db.collection('users').doc(context.auth.uid).get();
    if (!callerDoc.exists || callerDoc.data()?.role !== 'admin') {
      return { success: false, error: 'Forbidden' };
    }

    try {
      await admin.auth().updateUser(data.uid, { disabled: true });
      await db.collection('users').doc(data.uid).update({ isActive: false });
      return { success: true };
    } catch (error) {
      functions.logger.error('Error disabling staff account', error);
      return { success: false, error: 'Failed to disable staff account' };
    }
  }
);

export const enableStaffAccount = functions.https.onCall(
  async (data: { uid: string }, context): Promise<{ success: boolean; error?: string }> => {
    if (!context.auth) {
      return { success: false, error: 'Unauthenticated' };
    }

    const callerDoc = await db.collection('users').doc(context.auth.uid).get();
    if (!callerDoc.exists || callerDoc.data()?.role !== 'admin') {
      return { success: false, error: 'Forbidden' };
    }

    try {
      await admin.auth().updateUser(data.uid, { disabled: false });
      await db.collection('users').doc(data.uid).update({ isActive: true });
      return { success: true };
    } catch (error) {
      functions.logger.error('Error enabling staff account', error);
      return { success: false, error: 'Failed to enable staff account' };
    }
  }
);

export const deleteStaffAccount = functions.https.onCall(
  async (data: { uid: string }, context): Promise<{ success: boolean; error?: string }> => {
    if (!context.auth) {
      return { success: false, error: 'Unauthenticated' };
    }

    const callerDoc = await db.collection('users').doc(context.auth.uid).get();
    if (!callerDoc.exists || callerDoc.data()?.role !== 'admin') {
      return { success: false, error: 'Forbidden' };
    }

    if (data.uid === context.auth.uid) {
      return { success: false, error: 'Cannot delete your own account' };
    }

    try {
      await admin.auth().deleteUser(data.uid);
      await db.collection('users').doc(data.uid).delete();
      return { success: true };
    } catch (error) {
      functions.logger.error('Error deleting staff account', error);
      return { success: false, error: 'Failed to delete staff account' };
    }
  }
);
