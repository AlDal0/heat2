/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// Take the text parameter passed to this HTTP endpoint and insert it into
// Firestore under the path /messages/:documentId/original
exports.webhook = onRequest(async (req, res) => {
    // Grab the text parameter.
    const webhookId = req.body.id;
    const webhookBody = JSON.stringify(req.body);

    console.log(`:Message with ID: ${webhookId} added. Here is the body: ${webhookBody}`);

    // Push the new message into Firestore using the Firebase Admin SDK.
    // const writeResult = await getFirestore()
    //     .collection("messages")
    //     .add({original: original});
    // Send back a message that we've successfully written the message
    res.statusCode(200);
    //res.json({result: `Message with ID: ${webhookId} added. Here is the body: ${webhookBody}`});
  });

  