// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

// Task #1 - Anonymous Window
//---------------------------------------------------------------
Loops loops = new Loops();
loops.printAllEvenNumbers(10);//2 | 4 | 6 | 8 | 10

Loops loops = new Loops();
loops.printNtoMInsensitive(1, 3);//1, 2, 3
loops.printNtoMInsensitive(3, 1);//1, 2, 3
loops.printNtoMInsensitive(5, 2);//2, 3, 4, 5
loops.printNtoMInsensitive(0, 5);//0, 1, 2, 3, 4, 5
loops.printNtoMInsensitive(5, 0);//0, 1, 2, 3, 4, 5
loops.printNtoMInsensitive(5, 5);//5

Loops loops = new Loops();
loops.printNtoMInsensitiveBackwards(1, 3);//3, 2, 1
loops.printNtoMInsensitiveBackwards(3, 1);//3, 2, 1
loops.printNtoMInsensitiveBackwards(5, 2);//5, 4, 3, 2
loops.printNtoMInsensitiveBackwards(0, 5);//5, 4, 3, 2, 1, 0
loops.printNtoMInsensitiveBackwards(5, 0);//5, 4, 3, 2, 1, 0
loops.printNtoMInsensitiveBackwards(5, 5);//5

Loops loops = new Loops();
System.debug('0 is a prime number: ' + loops.isPrime(0));//false
System.debug('1 is a prime number: ' + loops.isPrime(1));//false
System.debug('15 is a prime number: ' + loops.isPrime(15));//false
System.debug('6 is a prime number: ' + loops.isPrime(6));//false
System.debug('-25 is a prime number: ' + loops.isPrime(-25));//false

System.debug('2 is a prime number: ' + loops.isPrime(2));//true
System.debug('3 is a prime number: ' + loops.isPrime(3));//true
System.debug('7 is a prime number: ' + loops.isPrime(7));//true
System.debug('111 is a prime number: ' + loops.isPrime(111));//false
System.debug('113 is a prime number: ' + loops.isPrime(113));//true

Loops loops = new Loops();
loops.printPrimeNumbers(97);
loops.printPrimeNumbers(10);
loops.printPrimeNumbers(-97);

Loops loops = new Loops();
System.debug('Factorial number of -5 is ' + loops.calculateFactorialNumber(-5));//0
System.debug('Factorial number of 0 is ' + loops.calculateFactorialNumber(0));//1
System.debug('Factorial number of 1 is ' + loops.calculateFactorialNumber(1));//1
System.debug('Factorial number of 2 is ' + loops.calculateFactorialNumber(2));//2
System.debug('Factorial number of 3 is ' + loops.calculateFactorialNumber(3));//6
System.debug('Factorial number of -5 is ' + loops.calculateFactorialNumber(5));//120

Loops loops = new Loops();
Integer factorial = loops.calculateFactorialNumber(10);
Integer sum = loops.calculateSumAllNumbers(10);
System.debug('Factorial number of 10 is ' + factorial);//3628800
System.debug('Sum number of 10 is ' + sum);//55
System.debug(factorial / sum);//65978

Loops loops = new Loops();
System.debug(loops.multiplicationDividedByAddition(10));//65978.18
System.debug(loops.multiplicationDividedByAddition(4));//2.4

Loops loops = new Loops();
loops.printQuadrats(5);//1, 4, 9, 16, 25
loops.printQuadrats(1);//1
loops.printQuadrats(-10);//0
loops.printQuadrats(0);//0

Loops loops = new Loops();
loops.printMultiplicationTable(5);
loops.printMultiplicationTable(0);
loops.printMultiplicationTable(-5);

Loops loops = new Loops();
loops.printPositiveEvenNumbers(10);//10, 8, 6, 4, 2, 0
loops.printPositiveEvenNumbers(0);//0
loops.printPositiveEvenNumbers(-10);
loops.printPositiveEvenNumbers(1);
loops.printPositiveEvenNumbers(4);//4, 2, 0
loops.printPositiveEvenNumbers(11);//10, 8, 6, 4, 2, 0

Loops loops = new Loops();
loops.printNegativeOddNumbers(-10);//-1, -3, -5, -7, -9
loops.printNegativeOddNumbers(-13);//-1, -3, -5, -7, -9, -11, -13
loops.printNegativeOddNumbers(0);
loops.printNegativeOddNumbers(10);

Loops loops = new Loops();
System.debug(loops.calculateRange(1, 10));//55
System.debug(loops.calculateRange(10, 1));//55
System.debug(loops.calculateRange(1, 2));//55
System.debug(loops.calculateRange(0, 0));//0
System.debug(loops.calculateRange(-2, 2));//0
System.debug(loops.calculateRange(5, 5));//0

Loops loops = new Loops();
System.debug(loops.reverseString('Test'));//tseT
System.debug(loops.reverseString('Igor'));//rogI

Loops loops = new Loops();
System.debug(loops.isPalindrome('racecar'));//true
System.debug(loops.isPalindrome('Racecar'));//true
System.debug(loops.isPalindrome('racer'));//false

Loops loops = new Loops();
System.debug(loops.findLetter('Test', 't'));//0
System.debug(loops.findLetter('Test', 'T'));//0
System.debug(loops.findLetter('Test', 'Te'));//-1
System.debug(loops.findLetter('Igor', 'r'));//3
System.debug(loops.findLetter('Test', '1'));//0

Loops loops = new Loops();
loops.displayFibonacci(0);//0
loops.displayFibonacci(1);//0 1
loops.displayFibonacci(2);//0 1 1
loops.displayFibonacci(3);//0 1 1 2
loops.displayFibonacci(4);//0 1 1 2 3
loops.displayFibonacci(6);//0 1 1 2 3 5 8
loops.displayFibonacci(10);//0 1 1 2 3 5 8 13 21 34 55
loops.displayFibonacci(14);//0 1 1 2 3 5 8 13 21 34 55 89 144 233 377