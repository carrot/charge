var chai = require('chai'),
    charge = require('../..');

var should = chai.should();

// this is a great place to initialize chai plugins
// http://chaijs.com/plugins

global.charge = charge;
global.should = should;
