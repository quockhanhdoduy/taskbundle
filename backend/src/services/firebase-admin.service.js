const admin = require('firebase-admin');
const path = require('path');

class FirebaseAdminService {
  constructor() {
    this.initialized = false;
    this.messaging = null;
  }

  async initialize() {
    try {
      if (this.initialized) {
        return;
      }

      if (!process.env.FIREBASE_SERVICE_ACCOUNT_KEY) {
        console.warn('FIREBASE_SERVICE_ACCOUNT_KEY not found. Firebase Admin will not be initialized.');
        return;
      }

      const serviceAccountPath = path.resolve(process.env.FIREBASE_SERVICE_ACCOUNT_KEY);
      const serviceAccount = require(serviceAccountPath);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: process.env.FIREBASE_PROJECT_ID || 'taskbundle'
      });

      this.messaging = admin.messaging();
      this.initialized = true;

      console.log('Firebase Admin initialized successfully');
    } catch (error) {
      console.error('Failed to initialize Firebase Admin:', error);
      console.error('Make sure FIREBASE_SERVICE_ACCOUNT_KEY points to the correct JSON file');
      throw error;
    }
  }

  async sendToDevice(token, notification) {
    try {
      if (!this.initialized) {
        await this.initialize();
      }

      if (!this.messaging) {
        throw new Error('Firebase Admin not initialized');
      }

      const message = {
        token: token,
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: notification.data || {},
        android: {
          priority: 'high',
          notification: {
            icon: 'ic_notification',
            color: '#2196F3',
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await this.messaging.send(message);
      console.log('Successfully sent message:', response);
      return response;
    } catch (error) {
      console.error('Error sending message:', error);
      throw error;
    }
  }

  async sendToMultipleDevices(tokens, notification) {
    try {
      if (!this.initialized) {
        await this.initialize();
      }

      if (!this.messaging) {
        throw new Error('Firebase Admin not initialized');
      }

      const message = {
        tokens: tokens,
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: notification.data || {},
        android: {
          priority: 'high',
          notification: {
            icon: 'ic_notification',
            color: '#2196F3',
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await this.messaging.sendEachForMulticast(message);
      console.log('Successfully sent messages:', response);
      return response;
    } catch (error) {
      console.error('Error sending messages:', error);
      throw error;
    }
  }

  async sendToTopic(topic, notification) {
    try {
      if (!this.initialized) {
        await this.initialize();
      }

      if (!this.messaging) {
        throw new Error('Firebase Admin not initialized');
      }

      const message = {
        topic: topic,
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: notification.data || {},
        android: {
          priority: 'high',
          notification: {
            icon: 'ic_notification',
            color: '#2196F3',
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await this.messaging.send(message);
      console.log('Successfully sent message to topic:', response);
      return response;
    } catch (error) {
      console.error('Error sending message to topic:', error);
      throw error;
    }
  }

  // Subscribe device to topic
  async subscribeToTopic(tokens, topic) {
    try {
      if (!this.initialized) {
        await this.initialize();
      }

      if (!this.messaging) {
        throw new Error('Firebase Admin not initialized');
      }

      const response = await this.messaging.subscribeToTopic(tokens, topic);
      console.log('Successfully subscribed to topic:', response);
      return response;
    } catch (error) {
      console.error('Error subscribing to topic:', error);
      throw error;
    }
  }

  // Unsubscribe device from topic
  async unsubscribeFromTopic(tokens, topic) {
    try {
      if (!this.initialized) {
        await this.initialize();
      }

      if (!this.messaging) {
        throw new Error('Firebase Admin not initialized');
      }

      const response = await this.messaging.unsubscribeFromTopic(tokens, topic);
      console.log('Successfully unsubscribed from topic:', response);
      return response;
    } catch (error) {
      console.error('Error unsubscribing from topic:', error);
      throw error;
    }
  }
}

module.exports = new FirebaseAdminService();
