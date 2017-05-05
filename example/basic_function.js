function greet(sink, msg) {
    sink.log('Greeting: ' + msg);
}

greet(console, 'Hello!');