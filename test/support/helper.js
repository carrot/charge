var chai = require('chai'),
    chai_http = require('chai-http'),
    path = require('path'),
    charge = require('../..');

var should = chai.should();

chai.use(chai_http);

global.chai = chai;
global.charge = charge;
global.should = should;
global.path = path;
global.base_path = path.join(__dirname, '../fixtures')
