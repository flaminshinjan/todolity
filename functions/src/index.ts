import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

admin.initializeApp();

// Define the interface for the expected data
interface TaskNotificationData {
  taskId: string;
  taskTitle: string;
  completedBy: string;
  sharedWith: string[];
  type: string;
}

export const sendTaskNotification = onCall<TaskNotificationData>(async (request) => {
  // Check authentication
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const { taskId, taskTitle, completedBy, sharedWith, type } = request.data;

  try {
    // Get user details
    const completedByUser = await admin.firestore()
      .collection("users")
      .doc(completedBy)
      .get();

    const completedByEmail = completedByUser.data()?.email || "A user";

    // Get FCM tokens for all shared users except the completer
    const userTokensPromises = sharedWith
      .filter((userId: string) => userId !== completedBy)
      .map(async (userId: string) => {
        const userDoc = await admin.firestore()
          .collection("users")
          .doc(userId)
          .get();
        return userDoc.data()?.fcmTokens || [];
      });

    const userTokensArrays = await Promise.all(userTokensPromises);
    const tokens = userTokensArrays.flat();

    if (tokens.length === 0) {
      return { success: false, message: "No tokens to send to" };
    }

    const message: admin.messaging.MulticastMessage = {
      tokens: tokens,
      notification: {
        title: "Task Completed",
        body: `${completedByEmail} has completed the task: ${taskTitle}`,
      },
      data: {
        taskId: taskId,
        type: type,
      },
    };

    // Send notifications to all tokens
    const response = await admin.messaging().sendEachForMulticast(message);

    console.log("Notification sent:", {
      success: true,
      successCount: response.successCount,
      failureCount: response.failureCount,
    });

    return {
      success: true,
      successCount: response.successCount,
      failureCount: response.failureCount,
    };
  } catch (error) {
    console.error("Error sending notification:", error);
    throw new HttpsError(
      "internal",
      "Error sending notification"
    );
  }
});