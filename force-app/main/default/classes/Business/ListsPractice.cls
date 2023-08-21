public with sharing class ListsPractice {
 
    // Simple lists Exercises
    //--------------------------------------------------------------------------

    public Integer getRandomNumberInRange(Integer n, Integer m) {
        return n + (Integer)(Math.random() * ((m - n) + 1));
    }

    public List<String> getAllColors() {
        List<String> allColors = new List<String>();

        allColors.add('red');
        allColors.add('orange');
        allColors.add('yellow');
        allColors.add('green');
        allColors.add('blue');
        allColors.add('indigo');
        allColors.add('violet'); 

        return allColors;
    } 

    public String getRandomStringFromList(List<String> words) {
        return words.get(getRandomNumberInRange(0, words.size() - 1));
    }

    public List<String> mergeTwoStringListsAndSort(List<String> wordsOne, List<String> wordsTwo) {
        wordsOne.addAll(wordsTwo);
        wordsOne.sort();

        return wordsOne;
    }

    public List<String> getFirstNCharacters(String inputString, Integer n) {
        String returnString = inputString.left(n);
        
        return returnString.split('');
    }

    public List<Integer> getListWithFiveRandomNumbers() {
        List<Integer> numbers = new List<Integer>();

        numbers.add(getRandomNumberInRange(0, 100));
        numbers.add(getRandomNumberInRange(0, 100));
        numbers.add(getRandomNumberInRange(0, 100));
        numbers.add(getRandomNumberInRange(0, 100));
        numbers.add(getRandomNumberInRange(0, 100));

        return numbers;
    }

    public Boolean isListSizeInRange(List<Integer> numbers, Integer n, Integer m) {
        Integer smallest = Math.min(n, m);
        Integer largest = Math.max(n, m);

        return numbers.size() >= smallest && numbers.size() <= largest;
    }
    
    // Lists & For Each Loops Exercises
    //--------------------------------------------------------------------------

    public Integer sumList(List<Integer> numbers) {
        Integer sum = 0;

        for(Integer num : numbers) {
            sum += num;
        }

        return sum;
    }

    public Integer getSmallest(List<Integer> numbers) {
        //integerList.sort();
        //return integerList.get(0);

        Integer smallest = numbers.get(0);
    
        for(Integer num : numbers) {
            if(num < smallest) {
                smallest = num;
            }
        }

        return smallest;
    }

    public String concatenateList(List<String> words) { 
        String concatenatedWord = '';

        for(String word : words) {
            concatenatedWord += word;
        }

        return concatenatedWord;
    }
    
    public List<String> reverseWordsAndOrder(List<String> words) {
        Loops loops = new Loops();
        List<String> reversedWords = new List<String>();
        List<String> reversedOrderWords = new List<String>();
        String reversedWord = '';

        for(Integer i = words.size() - 1; i >= 0; i--){
            reversedOrderWords.add(words.get(i));
        }

        for(String word : reversedOrderWords){
            reversedWords.add(loops.reverseString(word));
        }

        return reversedWords;
    }

    public List<Integer> createNIntegers(Integer n) {
        List<Integer> numbers = new List<Integer>();

        for(Integer i = 0; i < n; i++) {
            numbers.add(getRandomNumberInRange(0, 100));
        }

        return numbers;
    }

}