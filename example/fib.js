function fibNaive(n) {
    if (n < 2) {
        return 1;
    } else {
        return fibNaive(n - 2) + fibNaive(n - 1);
    }
}

var n = 2;
var result = fibNaive(n);
console.log()
console.log('fib(' + n + '): ' + result);