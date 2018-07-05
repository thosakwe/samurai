function fibonacci(num) {
  return (num <= 1) ? 1 : (fibonacci(num - 1) + fibonacci(num - 2));
}

print(fibonacci(13));