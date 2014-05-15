### Charge Foreman Example

This example uses the popular [Foreman](https://github.com/ddollar/foreman) project  to manage processes, including [Charge](http://github.com/carrot/charge). Foreman is a ruby-based project but it boasts a handful of [ports](https://github.com/ddollar/foreman#ports) if ruby isn't your thing.

Foreman is an extremely popular project and can be seen as an integral part of many services including [Heroku](https://devcenter.heroku.com/articles/procfile).


To get started with this example, assure you have Foreman installed and  assure that you have Charge installed globally.

```
$ npm install charge -g
$ gem install foreman
```

To get started with this example, `cd` into this folder and run:

```
$ foreman start
```

The processes are managed by the `Procfile` in this directory.

Open up `localhost:1112` in your browser to see the server running!

To learn more about Foreman, follow [Foreman's Getting Started Guide](http://blog.daviddollar.org/2011/05/06/introducing-foreman.html).
