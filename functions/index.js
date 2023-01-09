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
      });
    });

exports.orderUpdateFunction = functions.firestore
    .document("orders/{docId}")
    .onUpdate((snapshot, context) => {
      console.log("----------------start function--------------------");
      const doc = snapshot.after.data();
      console.log(doc);
      const creatorId = doc.creatorId;
      return admin.firestore().collection("users")
          .doc(creatorId).get().then((querySnapshot) => {
            console.log("------------------------------------");
            console.log(querySnapshot.data());
            const payload = {
              notification: {
                title: "Your Order Has Been Updated!",
                // body: contentMessage,
                clickAction: "FLUTTER_NOTIFICATION_CLICK",
                // badge: '1',
                sound: "default",
              },
            };
            admin.messaging()
                .sendToDevice(querySnapshot.data().tokens, payload)
                .then((response) => {
                  console.log("Successfully sent message:", response);
                }).catch((error) => {
                  console.log("Error sending message:", error);
                });
          });
      // return null;
    });


exports.chatFunction = functions.firestore
    .document("chatRooms/{docId}/messages/{message}")
    .onCreate((snapshot, context) => {
      console.log("----------------start function--------------------");
      const doc = snapshot.data();
      console.log(doc);
      const senderId = doc.sentBy;
      console.log(senderId);
      const toId = doc.toId;
      return admin.firestore().collection("users")
          .doc(toId).get().then((querySnapshot) => {
            console.log("------------------------------------");
            console.log(querySnapshot.data());
            const receiverData = querySnapshot.data();
            if (receiverData.chattingWith !== senderId) {
              admin.firestore().collection("users")
                  .doc(senderId).get().then((querySnapshot2) => {
                    const senderData = querySnapshot2.data();
                    const payload = {
                      notification: {
                        title: "New message from "+senderData.firstName,
                        body: doc.message,
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        // badge: '1',
                        sound: "default",
                      },
                    };
                    admin.messaging()
                        .sendToDevice(receiverData.tokens, payload)
                        .then((response) => {
                          console.log("Successfully sent message:", response);
                        }).catch((error) => {
                          console.log("Error sending message:", error);
                        });
                  });
            }
          });
      // return null;
    });