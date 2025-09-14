const dueDateChecker = require('./due-date-checker.service');

class SchedulerService {
  constructor() {
    this.intervals = [];
  }

  start() {
    console.log('Starting notification scheduler...');

    const dueDateInterval = setInterval(() => {
      dueDateChecker.runAllChecks();
    }, 6 * 60 * 60 * 1000);

    this.intervals.push(dueDateInterval);

    dueDateChecker.runAllChecks();

    console.log('Notification scheduler started');
  }

  stop() {
    this.intervals.forEach(interval => clearInterval(interval));
    this.intervals = [];
    console.log('Notification scheduler stopped');
  }
}

module.exports = new SchedulerService();



