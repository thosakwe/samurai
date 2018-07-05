function div(x) {
  if (isFinite(1000 / x)) {
    return 'Number is NOT Infinity.';
  }
  return "Number is Infinity!";
}

print(div(0));
// expected output: "Number is Infinity!""

print(div(1));
// expected output: "Number is NOT Infinity."