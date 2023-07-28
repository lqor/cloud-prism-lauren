@IsTest
public with sharing class MapsServiceTest {
  @TestSetup
  static void setup() {
  }

  @IsTest
  static void mergeMaps_UnitTest() {
    Map<String, Integer> inputMap1 = new Map<String, Integer>{
      'one' => 1,
      'two' => 2,
      'three' => 3,
      'four' => 4,
      'five' => 5
    };
    Map<String, Integer> inputMap2 = new Map<String, Integer>{
      'six' => 6,
      'seven' => 7,
      'eight' => 8,
      'nine' => 9,
      'one' => 100
    };
    Integer expectedSize = 9;
    Integer expectedValueForKeyOne = 101;

    MapsService mapsService = new MapsService();

    Test.startTest();
    Map<String, Integer> mergedMap = mapsService.mergeMaps(
      inputMap1,
      inputMap2
    );
    Test.stopTest();

    Assert.areEqual(expectedSize, mergedMap.size());
    Assert.areEqual(expectedValueForKeyOne, mergedMap.get('one'));
  }

  @IsTest
  static void intersectKeys_UnitTest() {
    Map<String, Integer> inputMap1 = new Map<String, Integer>{
      'one' => 1,
      'two' => 2,
      'three' => 3,
      'four' => 4,
      'nine' => 90
    };
    Map<String, Integer> inputMap2 = new Map<String, Integer>{
      'six' => 6,
      'seven' => 7,
      'eight' => 8,
      'nine' => 9,
      'one' => 100
    };
    List<String> expectedKeys = new List<String>();
    Set<String> inputMap1Keys = inputMap1.keySet();

    for (String key : inputMap1Keys) {
      if (inputMap2.containsKey(key)) {
        expectedKeys.add(key);
      }
    }

    MapsService mapsService = new MapsService();

    Test.startTest();
    List<String> intersectingKeys = mapsService.intersectKeys(
      inputMap1,
      inputMap2
    );
    Test.stopTest();

    Assert.areEqual(expectedKeys.size(), intersectingKeys.size());
    for (String expectedKey : expectedKeys) {
      Assert.isTrue(intersectingKeys.contains(expectedKey));
    }
  }

  @IsTest
  static void filterByValue_UnitTest() {
    Map<String, Integer> expectedValues = new Map<String, Integer>();
    Map<String, Integer> inputMap = new Map<String, Integer>{
      'ten' => 10,
      'twenty' => 20,
      'thirty' => 30,
      'forty' => 40,
      'fifty' => 50
    };
    Set<String> inputKeys = inputMap.keySet();
    Integer threshold = 30;

    for (String inputKey : inputKeys) {
      if (inputMap.get(inputKey) >= threshold) {
        expectedValues.put(inputKey, inputMap.get(inputKey));
      }
    }

    MapsService mapsService = new MapsService();

    Test.startTest();
    Map<String, Integer> filteredValues = mapsService.filterByValue(
      inputMap,
      threshold
    );
    Test.stopTest();

    Assert.areEqual(expectedValues.size(), filteredValues.size());
    Set<String> expectedKeys = expectedValues.keySet();
    for (String expectedKey : expectedKeys) {
      Assert.areEqual(
        expectedValues.get(expectedKey),
        filteredValues.get(expectedKey)
      );
    }
  }

  @IsTest
  static void getValuesByKey_UnitTest() {
    Map<String, String> inputMap = new Map<String, String>();
    List<String> keys = new List<String>{
      '100',
      '90',
      '80',
      '70',
      '60',
      '50',
      '40',
      '30',
      '20',
      '10'
    };
    List<String> expectedValues = new List<String>();

    inputMap.put('100', 'one hundred');
    inputMap.put('20', 'twenty');
    inputMap.put('30', 'thirty');
    inputMap.put('40', 'forty');
    inputMap.put('50', 'fifty');
    inputMap.put('60', 'sixty');
    inputMap.put('70', 'seventy');
    inputMap.put('80', 'eighty');
    inputMap.put('90', 'ninety');

    for (String key : keys) {
      if (inputMap.containsKey(key)) {
        expectedValues.add(inputMap.get(key));
      }
    }

    MapsService mapsService = new MapsService();

    Test.startTest();
    List<String> values = mapsService.getValuesByKey(inputMap, keys);
    Test.stopTest();

    Assert.areEqual(expectedValues.size(), values.size());
    for (String expectedValue : expectedValues) {
      Assert.isTrue(values.contains(expectedValue));
    }
  }

  @IsTest
  static void findMostCommon_UnitTest() {
    String sentence = 'The method finds the most common word from the map of word counts';
    List<String> words = new List<String>(sentence.split(' '));
    String expectedWord = 'the';

    MapsService mapsService = new MapsService();

    Test.startTest();
    String mostCommonWord = mapsService.findMostCommon(words);
    Test.stopTest();

    Assert.areEqual(expectedWord, mostCommonWord);
  }

  @IsTest
  static void countWords_UnitTest() {
    String sentence = 'The method finds the most common word from the map of word counts';
    List<String> words = new List<String>(sentence.split(' '));
    Map<String, Integer> wordCountExpected = new Map<String, Integer>();

    for (String word : words) {
      if (!wordCountExpected.containsKey(word.toLowerCase())) {
        wordCountExpected.put(word.toLowerCase(), 1);
      } else {
        wordCountExpected.put(
          word.toLowerCase(),
          wordCountExpected.get(word.toLowerCase()) + 1
        );
      }
    }

    MapsService mapsService = new MapsService();

    Test.startTest();
    Map<String, Integer> wordCount = mapsService.countWords(words);
    Test.stopTest();

    Assert.isTrue(wordCountExpected.equals(wordCount));
  }

  @IsTest
  static void findKeyByValue_UnitTest() {
    Map<String, Integer> inputMap = new Map<String, Integer>{
      'ten' => 10,
      'twenty' => 20,
      'thirty' => 30,
      'forty' => 40,
      'fifty' => 50
    };
    Set<String> inputKeys = inputMap.keySet();
    Integer targetValue1 = 20;
    Integer targetValue2 = 99;

    String expectedKeyValue = null;

    for (String inputKey : inputKeys) {
      if (inputMap.get(inputKey) == targetValue1) {
        expectedKeyValue = inputKey;
      }
    }

    MapsService mapsService = new MapsService();

    Test.startTest();
    String keyValueInMap = mapsService.findKeyByValue(inputMap, targetValue1);
    String keyValueNotInMap = mapsService.findKeyByValue(
      inputMap,
      targetValue2
    );
    Test.stopTest();

    Assert.areEqual(expectedKeyValue, keyValueInMap);
    Assert.isNull(keyValueNotInMap);
  }

  @IsTest
  static void removeEntriesByKey_UnitTest() {
    Map<String, Integer> inputMap = new Map<String, Integer>{
      'ten' => 10,
      'twenty' => 20,
      'thirty' => 30,
      'forty' => 40,
      'fifty' => 50
    };
    Map<String, Integer> expectedValues = inputMap.clone();
    Set<String> inputKeys = inputMap.keySet();
    List<String> keysToRemove = new List<String>{ 'twenty', 'forty', 'sixty' };

    for (String key : keysToRemove) {
      if (expectedValues.containsKey(key)) {
        expectedValues.remove(key);
      }
    }

    MapsService mapsService = new MapsService();

    Test.startTest();
    Map<String, Integer> remainingValues = mapsService.removeEntriesByKey(
      inputMap,
      keysToRemove
    );
    Test.stopTest();

    Assert.areEqual(expectedValues.size(), remainingValues.size());
    Set<String> expectedKeys = expectedValues.keySet();
    for (String expectedKey : expectedKeys) {
      Assert.areEqual(
        expectedValues.get(expectedKey),
        remainingValues.get(expectedKey)
      );
    }
  }
}
