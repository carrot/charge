### Charge Customize Middleware Example

In this example, we'll replace charge's logger of choice [morgan](https://github.com/expressjs/morgan) with [connect's built-in logger](http://www.senchalabs.org/connect/logger.html).

While this is a trivial example, it's meant to show you that since charge simply returns an array of middleware, you can swap in and out whatever middleware your heart desires.

To see the project (particularly the logger) in action, you'll have to assure that you have connect installed, and then you can run the server.

```
$ cd examples/customize_middlware
$ npm install
$ npm start
```

Then open up `localhost:1111` in your browser to get those logs logging.
