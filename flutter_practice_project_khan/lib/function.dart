void main() {
  var myC = myClass();

  //myC.myFun("Abir");
  //
  //
  //
  //
  //myC.myFun("Rakib");
  //
  //
  //
  //
  //myC.myFun("Hasib");


  print(myC.add());

  print(myC.addNumber(6, 9));
  print(myC.addNumber(600, 909));

}

class myClass {
  // void myFun() {
  //   print("Md Rakibul");
  // }

  void myFun(String name) {
    print(name);
  }

  int add() {
    int a = 4;
    int b = 5;
    int sum = a + b;
    return sum;
  }

  int addNumber (int number1,int number2){

    int sum=number1+number2;

    return sum;
  }

}
