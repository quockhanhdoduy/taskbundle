const express = require('express');
const { notificationsRoutes } = require('./notifications.routes');

const router = express.Router();

// Apply notification routes
router.use('/notifications', notificationsRoutes);

module.exports = router;
