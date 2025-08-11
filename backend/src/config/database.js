const mongoose = require('mongoose');

const  mongoDBConnect = async () => {
    try {
        const dbUri = env.MONGODB_URI;
        if(!dbUri || dbUri.length === 0){
            throw new Error('MONGODB_URI not defined in environment variables');
        }
        await mongoose.connect(dbUri);
        console.log('Connected to MongoDB');
    } catch (error) {
        console.log(error.message || 'Error connecting to MongoDB');
        throw new Error(error.message || 'Error connecting to MongoDB');
    }
};

module.exports = {
    mongoDBConnect
}