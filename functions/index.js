/* eslint-disable eol-last */
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.productFunction = functions.firestore
    .document("products/{docId}")
    .onCreate((snapshot, context) => {
      const payload = {
        notification: {
          title: "New Product Has Been Uploaded!",
          body: snapshot.data().title,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      };
      return admin.messaging().sendToTopic("products", payload)
          .then((response) => {
            console.log("Successfully sent message:", response);
          }).catch((error) => {
            console.log("Error sending message:", error);
          });
    });

exports.orderCreateFunction = functions.firestore
    .document("orders/{docId}")
    .onCreate((snapshot, context) => {
      console.log("----------------start function--------------------");
      const doc = snapshot.data();
      console.log(doc);
      // admin.firestore().collection("users")
      //     .doc(doc.productOwnerId).get().then((querySnapshot) => {
      //       const productOwnerData = querySnapshot.data();
      //       if (productOwnerData.status !== "admin") {
      //         const payload = {
      //           notification: {
      //             title: "Your Product Has Been Requested!",
      //             // body: contentMessage,
      //             clickAction: "FLUTTER_NOTIFICATION_CLICK",
      //             // badge: '1',
      //             sound: "default",
      //           },
      //         };
      //         admin.messaging()
      //             .sendToDevice(productOwnerData.tokens, payload)
      //             .then((response) => {
      //               console.log("Successfully sent message:", response);
      //             }).catch((error) => {
      //               console.log("Error sending message:", error);
      //             });
      //       }
      //     });
      const payload = {
        notification: {
          title: "New Order Has Been Requested!",
          body: snapshot.data().title,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      };
      return admin.messaging().sendToTopic("orders", payload)
          .then((response) => {
            console.log("Successfully sent message:", response);
          }).catch((error) => {
            console.log("Error sending message:", error);
          });
    });

exports.orderUpdateFunction = functions.firestore
    .document("orders/{docId}")
    .onUpdate((snapshot, context) => {
      console.log("----------------start function--------------------");
      const doc = snapshot.after.data();
      console.log(doc);
      const creatorId = doc.creatorId;
      const productOwnerId = doc.productOwnerId;
      return admin.firestore().collection("users")
          .doc(creatorId).get().then((OrderCreatorQuerySnapshot) => {
            console.log("------------------------------------");
            console.log(OrderCreatorQuerySnapshot.data());
            const OrderCreatorData = OrderCreatorQuerySnapshot.data();
            admin.firestore().collection("users")
                .doc(productOwnerId).get()
                .then((productOwenerQuerySnapshot) => {
                  const productOwnerData = productOwenerQuerySnapshot.data();
                  const payload = {
                    notification: {
                      title: "Your Product Availability Has Been Updated!",
                      // body: contentMessage,
                      clickAction: "FLUTTER_NOTIFICATION_CLICK",
                      // badge: '1',
                      sound: "default",
                    },
                  };
                  admin.messaging()
                      .sendToDevice(productOwnerData.tokens, payload)
                      .then((response) => {
                        console.log("Successfully sent message to product owner:", response);
                      }).catch((error) => {
                        console.log("Error sending message:", error);
                      });
                });
            const payload = {
              notification: {
                title: "Your Order Status Has Been Updated!",
                // body: contentMessage,
                clickAction: "FLUTTER_NOTIFICATION_CLICK",
                // badge: '1',
                sound: "default",
              },
            };
            admin.messaging()
                .sendToDevice(OrderCreatorData.tokens, payload)
                .then((response) => {
                  console.log("Successfully sent message to order requestor:", response);
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
    });

exports.deletionCreateFunction = functions.firestore
    .document("delete/{docId}")
    .onCreate((snapshot, context) => {
      console.log("----------------start function--------------------");
      const doc = snapshot.data();
      console.log(doc);
      const payload = {
        notification: {
          title: "User Account Deletion Has Been Requested!",
          body: snapshot.data().requesterName,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      };
      return admin.messaging().sendToTopic("delete", payload)
          .then((response) => {
            console.log("Successfully sent message:", response);
          }).catch((error) => {
            console.log("Error sending message:", error);
          });
    });