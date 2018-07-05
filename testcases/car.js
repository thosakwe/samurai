function Car(make, model, year) {
  this.make = make;
  this.model = model;
  this.year = year;
}

Car.prototype.info = function() {
  return 'Hey!';
};

var car1 = new Car('Eagle', 'Talon TSi', 1993);

console.log(car1.make);
//console.log(car1.info());
// expected output: "Eagle"