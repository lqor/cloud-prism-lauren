public class Loops {
    /**
    Write a method that prints a String 10 times
    */
    
    /**
    Write a method that prints all numbers from 1 to 100
    */

    /**
    Write a method that prints all numbers from 1 to n
    1, 2, ..., n
    */


    /*
        Write a method that prints all numbers from n to m
    */

    /**
    Write a method that prints all odd numbers until n
    1, 3, 5, 7, 9, ...
    */
    public void printOddNumbersUntilN(Integer n) {
        for(Integer i = 1; i < n; i = i + 2) {
            System.debug(i);
        }
    }


    /**
    Write a method that prints out each letter of a word on a new line. 
    'Igor'
    I 
    g 
    o 
    r
    */
    public void printLetters(String word) {
        for(Integer i = 0; i < word.length(); i++) {
            System.debug(word.split('').get(i));
        }
    }

    /**
    Write a method that counts all numbers in a string.
    countNumbers('ABC DEF') -> 0
    countNumbers('BAC19DEF') -> 2
    */

}