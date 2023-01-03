/* eslint-disable eol-last */
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.orderFunction = functions.firestore
    .document("orders/{docId}")
    .onCreate((snapshot, context) => {
      return admin.messaging().sendToTopic("orders", {
        notification: {
          title: "New Order Has Been Requested!",
          body: snapshot.data().title,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
        // Set Android priority to "high"
        // android: {
        //   priority: "high",
        // },
        // Add APNS (Apple) config
        // apns: {
        //   payload: {
        //     aps: {
        //       contentAvailable: true,
        //     },
        //   },
        // },
      });
    });

// exports.myFunction = functions.firestore
//     .document("products/{docId}")
//     .onCreate((snapshot, context) => {
//       return admin.messaging().sendToTopic("products", {
//         notification: {
//           title: "New Product Has Been Added!",
//           body: snapshot.data().title,
//           clickAction: "FLUTTER_NOTIFICATION_CLICK",
//         },
//         // Set Android priority to "high"
//         android: {
//           priority: "high",
//         },
//         // Add APNS (Apple) config
//         apns: {
//           payload: {
//             aps: {
//               contentAvailable: true,
//             },
//           },
//         },
//       });
//     });
