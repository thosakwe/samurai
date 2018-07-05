function fibonacciFake(num) {
  if (num <= 1) return 1;

  return fibonacci(num - 1) + fibonacci(num - 2);
}

function fibonacci(num) {
  return (num <= 1) ? 1 : (fibonacci(num - 1) + fibonacci(num - 2));
}

print(fibonacci(13));