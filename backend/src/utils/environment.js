const dotenv = require('dotenv');

dotenv.config();

const env = (() => {
    try {
        const environment = process.env.environment ?? '';
        console.log(`environment/${environment}.env`);
        dotenv.config({ path: `environment/${environment}.env` });
        return process.env;
    } catch (error) {
        console.error('Error loading environment variables', error);
        throw error;
    }
})();

module.exports = { env };