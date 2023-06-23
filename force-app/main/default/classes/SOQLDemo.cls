public with sharing class SOQLDemo {
    /**
    1. Method name: increaseProbabilityBasedOnStage
    1. Parameters: String stage
    2. Return type: void
    3. Functionality: The method takes a string argument that indicates a certain stage that is considered 
                      favorable for a company. The probability field for any 
                      opportunity that has this stage should be increased by 10%.
     */
    public static void increaseProbabilityBasedOnStage(String stage) {
        List<Opportunity> opps = [
            SELECT Id, StageName, Probability
            FROM Opportunity
            WHERE StageName = :stage
        ];

        for(Opportunity opp : opps) {
            opp.Probability += 10;
            System.debug(opp);
        }

        update opps;
    }
}