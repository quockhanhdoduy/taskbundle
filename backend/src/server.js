const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { env } = require('./utils');

const { authRoutes } = require('./modules/auth/auth.routes');
const { usersRoutes } = require('./modules/users/users.routes');
const { boardsRoutes } = require('./modules/boards/boards.routes');
const { listsRoutes } = require('./modules/lists/lists.routes');
const { cardsRoutes } = require('./modules/cards/cards.routes');
const { commentsRoutes } = require('./modules/comments/comments.routes');
const { activitiesRoutes } = require('./modules/activities/activities.routes');
const notificationRoutes = require('./modules/notifications');
const { mongoDBConnect } = require('./config/database');
const schedulerService = require('./services/scheduler.service');


const app = express();

app.use(cors());
app.use(helmet());
app.use(morgan('common'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use(authRoutes);
app.use(usersRoutes);
app.use(boardsRoutes);
app.use(listsRoutes);
app.use(cardsRoutes);
app.use(commentsRoutes);
app.use(activitiesRoutes);
app.use(notificationRoutes);

app.get('/', (req, res) => {
    res.status(200).json({
        message: 'Hello World'
    });
});

const PORT = env.PORT || 3000;

const startServer = async () => {
    try {
        await mongoDBConnect();
        app.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}`);
            console.log('http://localhost:3000');

            schedulerService.start();
        });
    } catch (error) {
        console.error('Failed to start server:', error.message);
        process.exit(1);
    }
};

startServer();
