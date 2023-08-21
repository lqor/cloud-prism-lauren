public with sharing class MapsService {
    
    public Map<String, Integer> mergeMaps(Map<String, Integer> map1, Map<String, Integer> map2) {
        Map<String, Integer> mergedMap = map1.clone();
        Set<String> map1Keys = map1.keySet();
        Set<String> map2Keys = map2.keySet();
        Integer mergedValue = 0;
        
        for(String key : map1Keys) {
            if(map2.containsKey(key)) {
                mergedValue = map1.get(key) + map2.get(key);
                mergedMap.put(key, mergedValue);
            } 
        }
        
        for(String key : map2Keys) {
            if(!map1.containsKey(key)) {
                mergedMap.put(key, map2.get(key));
            } 
        }
        
        return mergedMap;
    }
    
    public List<String> intersectKeys(Map<String, Integer> map1, Map<String, Integer> map2) {
        List<String> intersectingKeys = new List<String>();
        Set<String> map1Keys = map1.keySet();
        
        for(String key : map1Keys) {
            if(map2.containsKey(key)) {
                intersectingKeys.add(key);
            } 
        }

        return intersectingKeys;
    }

    public Map<String, Integer> filterByValue(Map<String, Integer> inputMap, integer threshold) {
        Map<String, Integer> filteredValues = new Map<String, Integer>();
        Set<String> inputKeys = inputMap.keySet();
        
        for(String key : inputKeys) {
            if(inputMap.get(key) >= threshold) {
                filteredValues.put(key, inputMap.get(key));
            } 
        }

        return filteredValues;        
    }

    public List<String> getValuesByKey(Map<String, String> inputMap, List<String> keys) {
        List<String> values = new List<String>();
        
        for(String key : keys) {
            if(inputMap.containsKey(key)) {
                values.add(inputMap.get(key));
            } 
        }

        return values;
    }

    public String findMostCommon(List<String> words) {
        Map<String, Integer> wordFrequency = countWords(words);
        Set<String> wordFrequencyKeys = wordFrequency.keySet();
        String mostCommonWord;
        Integer frequency = 0;

        for(String wordFrequencyKey : wordFrequencyKeys) {
            if(wordFrequency.get(wordFrequencyKey) > frequency) {
                frequency = wordFrequency.get(wordFrequencyKey);
                mostCommonWord = wordFrequencyKey;
            }
        }

        return mostCommonWord;
    }

    public Map<String, Integer> countWords(List<String> words) {
        Map<String, Integer> wordCount = new Map<String, Integer>();

        for(String word : words) {
            if(!wordCount.containsKey(word.toLowerCase())) {
                wordCount.put(word.toLowerCase(), 1);
                System.debug(word);
            } else {
                wordCount.put(word.toLowerCase(), wordCount.get(word.toLowerCase()) + 1);
            }
        }

        return wordCount;
    }
    
    public String findKeyByValue(Map<String, Integer> inputMap, Integer targetValue) {
        Set<String> inputKeys = inputMap.keySet();
        String keyValue = null;

        for(String inputKey : inputKeys) {
            if(inputMap.get(inputKey) == targetValue) {
                keyValue = inputKey;
            } 
        }

        return keyValue;
    }

    public Map<String, Integer> removeEntriesByKey(Map<String, Integer> inputMap, List<String> keysToRemove) {
        Set<String> inputKeys = inputMap.keySet();

        for(String key : keysToRemove) {
            if(inputMap.containsKey(key)) {
                inputMap.remove(key);
            }
        }

        return inputMap;
    }
}