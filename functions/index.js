// Import required functions from Firebase Functions v2
const { onRequest } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore"); // Correct Firestore trigger import
const logger = require("firebase-functions/logger");

// Initialize Firebase Admin and Nodemailer
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

// Initialize Firebase Admin
admin.initializeApp();

// Set up email transporter
const transporter = nodemailer.createTransport({
  service: "gmail", 
  auth: {
    user: "izehra70@gmail.com",
    pass: "waitingfor2021",
  },
});

// Send Invitation Email on Firestore document creation
exports.sendInvitationEmail = onDocumentCreated('guests/{guestId}', (snap, context) => {
  const guest = snap.data();
  const mailOptions = {
    from: "izehra70@gmail.com",
    to: guest.email,
    subject: `Invitation to ${guest.eventId}`,
    html: `
      <h1>You're Invited!</h1>
      <p>Event: ${guest.eventId}</p>
      <p>Click below to RSVP:</p>
      <a href="http://localhost:4000/rsvp/${context.params.guestId}/accepted">Accept</a> |
      <a href="http://localhost:4000/rsvp/${context.params.guestId}/declined">Decline</a> |
      <a href="http://localhost:4000/rsvp/${context.params.guestId}/maybe">Maybe</a>
    `,
  };

  return transporter.sendMail(mailOptions);
});

// Update RSVP Status with HTTP request
exports.updateRsvpStatus = onRequest(async (req, res) => {
  const { guestId, status } = req.params;

  // Ensure the status is valid
  const validStatuses = ["accepted", "declined", "maybe"];
  if (!validStatuses.includes(status)) {
    return res.status(400).send("Invalid RSVP status.");
  }

  try {
    // Update RSVP status in Firestore
    await admin.firestore().collection("guests").doc(guestId).update({
      rsvpStatus: status.toUpperCase(),
    });

    // Send response
    res.send("RSVP status updated successfully!");
  } catch (error) {
    console.error("Error updating RSVP status:", error);
    res.status(500).send("Error updating RSVP status.");
  }
});
