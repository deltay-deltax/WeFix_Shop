/**
 * WeFix Shop – Cloud Functions
 *
 * onRequestStatusChanged — Sends push notifications to the shop owner
 * whenever a service request status changes on their document.
 *
 * Triggers:
 *   pending          → New request from customer
 *   payment_done     → Customer has paid
 *   payment_on_delivery → Customer chose pay on delivery
 *
 * FCM token is stored in shop_users/{shopId}.fcmToken by the shop app.
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// ── Firestore Trigger: Service Request Status → Shop Push Notification ────────
exports.onRequestStatusChangedShop = functions.firestore
    .document("shop_users/{shopId}/requests/{requestId}")
    .onWrite(async (change, context) => {
        const { shopId, requestId } = context.params;

        // Document deleted → ignore
        if (!change.after.exists) return null;

        const dataBefore = change.before.data() || {};
        const dataAfter = change.after.data();

        const statusBefore = dataBefore.status;
        const statusAfter = dataAfter.status;
        const amount = dataAfter.amount || "";
        const isHeavyAppliance = dataAfter.isHeavyAppliance === true;
        const visitScheduledAt = dataAfter.visitScheduledAt || "";
        const visitConfirmedByUser = dataAfter.visitConfirmedByUser === true;

        // Only act on actual status changes
        if (statusBefore === statusAfter) return null;

        // Customer name stored on the request document
        const customerName = dataAfter.customerName
            || dataAfter.name
            || dataAfter.yourName
            || "A customer";

        functions.logger.log(
            `Status change: ${statusBefore} → ${statusAfter} | request: ${requestId} | shop: ${shopId}`
        );

        // Map status → notification content for the SHOP OWNER
        let title = null;
        let body = null;

        switch (statusAfter) {
            case "pending":
            case "Pending":
                title = "New Service Request 🔔";
                body = `${customerName} has submitted a new service request. Open the app to review and respond.`;
                break;
            case "in_progress":
                if (isHeavyAppliance) {
                    title = "Home Visit Scheduled 🏠";
                    let timeStr = visitScheduledAt;
                    if (visitScheduledAt && typeof visitScheduledAt.toDate === "function") {
                        const d = visitScheduledAt.toDate();
                        timeStr = `${d.getDate()}/${d.getMonth() + 1}/${d.getFullYear()} ${d.getHours()}:${d.getMinutes().toString().padStart(2, "0")}`;
                    }
                    body = `${customerName} has ${visitConfirmedByUser ? "confirmed" : "requested"} a visit for ${timeStr}.`;
                } else {
                    title = "Service Request in Progress ";
                    body = `${customerName} has accepted the Service. Please Wait until they drop/Courier the product.`;
                }
                break;
            case "in_service":
                if (isHeavyAppliance) {
                    title = "Home Visit Started 🛠️";
                    body = `Home visit in progress. Service has been started for ${customerName}'s appliance.`;
                } else {
                    title = "Start Service";
                    body = `${customerName} has dropped the Product. Please start the repair process.`;
                }
                break;

            case "payment_done":
                title = "Payment Received ✅";
                body = `${customerName} has successfully paid ₹${amount}. Please prepare the device for handover.`;
                break;

            case "payment_on_delivery":
                title = "Pay on Delivery 📦";
                body = `${customerName} has opted for payment on delivery. Collect ₹${amount} when returning the device.`;
                break;

            default:
                // No shop notification for other status transitions
                return null;
        }

        // Fetch the shop's FCM token
        const shopDoc = await admin.firestore().collection("shop_users").doc(shopId).get();
        if (!shopDoc.exists) return null;

        const shopToken = shopDoc.data().fcmToken;
        if (!shopToken) {
            functions.logger.log(`Shop ${shopId} has no fcmToken registered.`);
            return null;
        }

        // Send push notification to the shop owner
        try {
            const response = await admin.messaging().send({
                token: shopToken,
                notification: { title, body },
                android: {
                    priority: "high",
                    notification: {
                        sound: "default",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    },
                },
                apns: {
                    payload: { aps: { sound: "default" } },
                },
                data: { requestId, shopId },
            });
            functions.logger.log(
                `Push sent to shop ${shopId} (${statusAfter}):`, response
            );
        } catch (err) {
            functions.logger.error(
                `Error sending push for request ${requestId}:`, err
            );
        }

        // Save to shop_users/{shopId}/notifications for in-app history
        await admin.firestore()
            .collection("shop_users")
            .doc(shopId)
            .collection("notifications")
            .add({
                title,
                body,
                type: statusAfter === "payment_done" || statusAfter === "payment_on_delivery"
                    ? "success"
                    : "info",
                requestId,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                isRead: false,
            });

        functions.logger.log(`Notification saved → shop_users/${shopId}/notifications`);
        return null;
    });

// ── Firestore Trigger: Chat Message → Notification ────────
exports.onChatMessageReceivedShop = functions.firestore
    .document("chats/{chatId}/messages/{messageId}")
    .onCreate(async (snap, context) => {
        const messageData = snap.data();
        if (!messageData) return null;

        const senderId = messageData.senderId;
        const text = messageData.text || (messageData.imageUrl ? "[Image received]" : "New message");

        // Get the chat document
        const { chatId } = context.params;
        const chatDoc = await admin.firestore().collection("chats").doc(chatId).get();
        if (!chatDoc.exists) return null;

        const chatData = chatDoc.data();
        const participants = chatData.participants || [];

        // Find the recipient(s) (participants EXCLUDING the sender)
        const recipients = participants.filter(uid => uid !== senderId);

        // We only want to notify the shop owner if they are a recipient
        for (const recipientId of recipients) {
            const shopDoc = await admin.firestore().collection("shop_users").doc(recipientId).get();
            if (shopDoc.exists) {
                const shopToken = shopDoc.data().fcmToken;
                if (shopToken) {
                    try {
                        let customerName = "Customer";
                        // try to get sender name from 'users' collection
                        const userDoc = await admin.firestore().collection("users").doc(senderId).get();
                        if (userDoc.exists && userDoc.data().Name) {
                            customerName = userDoc.data().Name;
                        }

                        await admin.messaging().send({
                            token: shopToken,
                            notification: { 
                                title: `New Message from ${customerName}`, 
                                body: text 
                            },
                            android: {
                                priority: "high",
                                notification: {
                                    sound: "default",
                                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                                },
                            },
                            apns: {
                                payload: { aps: { sound: "default" } },
                            },
                            data: { chatId, type: "chat" },
                        });
                        functions.logger.log(`Chat push sent to shop ${recipientId}`);
                    } catch (err) {
                        functions.logger.error(`Error sending chat push to ${recipientId}:`, err);
                    }
                }
            }
        }

        return null;
    });
