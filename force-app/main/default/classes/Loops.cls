public with sharing class Loops {
    
    public void printAllEvenNumbers(Integer n) {
        for(Integer i = 0; i <= n; i += 2) {
            System.debug(i);
        }
    }
    
    public void printNtoMInsensitive(Integer numberOne, Integer numberTwo) {
        Integer smallest = Math.min(numberOne, numberTwo);
        Integer largest = Math.max(numberOne, numberTwo);
        String ascendingNumbers = String.valueOf(smallest);
        
        for(Integer i = smallest + 1; i <= largest; i++) {
            ascendingNumbers += (', ' + i);
        }

        System.debug(ascendingNumbers);
    }
    
    public void printNtoMInsensitiveBackwards(Integer numberOne, Integer numberTwo) {
        Integer smallest = Math.min(numberOne, numberTwo);
        Integer largest = Math.max(numberOne, numberTwo);
        String descendingNumbers = String.valueOf(largest);
        
        for(Integer i = largest - 1; i >= smallest; i--) {
           descendingNumbers += (', ' + i);
        }

        System.debug(descendingNumbers);
    }
    
    public Boolean isPrime(Integer myNumber) {
        Boolean isPrimeNumber = false;
        Integer factor = 0;
        
        for(Integer i = 1; i <= myNumber; i++) {
            if (Math.mod(myNumber, i) == 0) {
                factor++;
            }
        }
        
        if(myNumber > 1 && factor == 2) {
            isPrimeNumber = true;
        }
        
        return isPrimeNumber;
    }
    
    public void printPrimeNumbers(Integer n) {
        for(Integer i = 0; i <= n; i++) {
            if(isPrime(i)) {
                System.debug(i);
            }
        }
    }
    
    public Integer calculateFactorialNumber(Integer n) {
        Integer factorial = 1;
        
        if(n < 0) {
            factorial = 0;
        }
        
        for(Integer i = 2; i <= n; i++) {
            factorial *= i;
        }
        
        return factorial;
    }
    
    public Integer calculateSumAllNumbers(Integer n) {
        Integer sum = 0;
        
        for (Integer i = 1; i <= n; i++) {
            sum += i;
        }
        
        return sum;
    }
    
    public Decimal multiplicationDividedByAddition(Integer n) {
        return Decimal.valueOf(calculateFactorialNumber(n)) / calculateSumAllNumbers(n);
    }
    
    public void printQuadrats(Integer x) {
        String squares = '1';
        
        if(x <= 0) {
            squares = '0';
        }
        
        for(Integer i = 2; i <= x; i++) {
            squares += (', ' + i*i);
        }
        
        System.debug(squares);
    }
    
    public void printMultiplicationTable(Integer myNumber) {
        for(Integer i = 1; i <= 10; i++) {
            System.debug(i + 'x' + myNumber + ' = ' + i * myNumber);
        }
    }

    public void printPositiveEvenNumbers(Integer n) {
        if(Math.mod(n, 2) == 1) {
            n--;
        }
        
        String positiveEvenNumbers = String.valueOf(n);
		
        if(n >= 0) {
            for(Integer i = n-2; i >= 0; i -= 2) {
                positiveEvenNumbers += (', ' + i);
            }
            System.debug(positiveEvenNumbers);        
        }
    }
    
    public void printNegativeOddNumbers(Integer n) {
        String negativeOddNumbers = '-1';
        
        if(n < 0) {
            for(Integer i = -3; i >= n; i -= 2) {
                negativeOddNumbers += (', ' + i);
            }
            System.debug(negativeOddNumbers);
        }
    }
    
    public Integer calculateRange(Integer numberOne, Integer numberTwo) {
        Integer sum = 0;
        Integer smallest = Math.min(numberOne, numberTwo);
        Integer largest = Math.max(numberOne, numberTwo);
        
        if(smallest < largest) {
            for (Integer i = smallest; i <= largest; i++) {
                sum += i;
            }
        }
        
        return sum;
    }
    
    public String reverseString(String word) {
        String reversedWord = '';
        
        for(Integer i = word.length() - 1; i >= 0 ; i--) {
            reversedWord += word.split('').get(i);
        }
        
        return reversedWord;
    }
    
    public Boolean isPalindrome(String word) {
        return (word.equalsIgnoreCase(reverseString(word)));
    }
    
    public Integer findLetter(String word, String letter) {
        Integer index = -1;
        
        if(word.isAlpha() && letter.isAlpha()) {
            for(Integer i = 0; i < word.length(); i++) {
                if(word.split('').get(i) == letter.toLowerCase()) {
                    index = i;
                    break;
                }            
            }
        }
        
        return index;
    }
    
    public void displayFibonacci(Integer n) {
        String sequence = '0 1';
        Integer currentNumber = 0;
        Integer previousNumber = 0;
        Integer lastNumber = 1;    
        
        if(n > 0) {
            for(Integer i = 2; i <= n; i ++) {
                currentNumber = previousNumber + lastNumber;
                sequence += (' ' + currentNumber);
                previousNumber = lastNumber;
                lastNumber = currentNumber;
            }
        } else {
            sequence = '0';
        }
        
        System.debug(sequence);
    }
    
}