// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access Cloud Firestore.
const admin = require('firebase-admin');
admin.initializeApp();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
exports.sendPushNotification = functions.firestore.document('/Orders/{orderId}').onCreate((snap, context) => {
  var values = snap.data();

  var payload = {
    notification: {
      title: 'An Order Has Been Placed',
      body: 'Order Number: '+values.orderId+'\n By: '+values.contactName +'\n At :'+values.orderPlaced,
      sound: 'dedfault',
      image: values.imageUrl
      }    
  }   

  //Create an options object that contains the time to live for the notification and the priority
  const options = {
  priority: "high",
  timeToLive: 60 * 60 * 24
  };
    //   compare UID with the current UID
  return admin.messaging().sendToTopic(values.storeId, payload,options);
});

exports.sendNotificationOnCancellation = functions.firestore.document('/Orders/{orderId}').onUpdate((change, context) => {
      // Get an object representing the document
      // e.g. {'name': 'Marie', 'age': 66}
      const newValue = change.after.data();
      var payload = {
        notification: {
          title: 'An Order Has Been Cancelled',
          body: 'Order Number: '+newValue.orderId+' Has Been Cancelled By the customer at'+newValue.cancelledTime,
          sound: 'dedfault',
          image: newValue.imageUrl
          }    
      } 
        //Create an options object that contains the time to live for the notification and the priority
        const options = {
          priority: "high",
          timeToLive: 60 * 60 * 24
          };
      // perform desired operations ...
      if(newValue.statusCode==4){
        // meaning the order has been cancelled
        if(newValue.cancelledBy=='customer'){
          // send a push notification to the store
          return admin.messaging().sendToTopic(newValue.storeId, payload,options);
        }
      }
});
// export const getData = functions.https.onCall((data, context) => {
//     // verify Firebase Auth ID token
//     if (!context.auth) {
//       return { message: 'Authentication Required!', code: 401 };
//     }
  
//     // do your things..
//     const uid = context.auth.uid;
//     const query = data.query;
  
//     return { message: 'Some Data', code: 400 };
//   });