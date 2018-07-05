function Car(make, model, year) {
  this.make = make;
  this.model = model;
  this.year = year;
}

Car.prototype.info = function() {
  return 'You are driving a ' + this.year + ' ' + this.make + ' ' + this.model + '.';
};

var car1 = new Car('Eagle', 'Talon TSi', 1993);

console.log(car1.make);
// expected output: "Eagle"

console.log(car1.info());
// expected output: "You are driving a 1993 Eagle Talon TSi."