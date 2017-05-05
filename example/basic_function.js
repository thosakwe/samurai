function greet(sink, msg) {
    sink.log('Greeting:');
    sink.log(msg);
}

greet(console, 'Hello!');