public with sharing class OpportunityService {
    
    public Boolean isOpen(Opportunity opportunity) {
        return opportunity.StageName.contains('Closed');
    }
    
    public Decimal calculateAmount(Opportunity firstOpportunity, Opportunity secondOpportunity) {
        return firstOpportunity.Amount + secondOpportunity.Amount;
    }

    public Decimal calculateProbability(Opportunity firstOpportunity, Opportunity secondOpportunity) {
        return (firstOpportunity.Probability + secondOpportunity.Probability) / 2;
    }
    
    public void doubleAmount(Opportunity opportunity) {
        opportunity.Amount *= 2;
    }
    
    public String getOpportunityDetails(Opportunity opportunity) {
        String name = 'The opportunity name is: ' + opportunity.Name;
        String amount = '. The opportunity amount is: ' + opportunity.Amount;
        String stage = '. The opportunity stage is: ' + opportunity.StageName + '.';
        String opportunityValues = name + amount + stage;

        return opportunityValues;
    } 

    public Opportunity softMerge(Opportunity firstOpportunity, Opportunity secondOpportunity) {
        Opportunity returnOpportunity = new Opportunity();
        
        returnOpportunity.AccountId = firstOpportunity.AccountId;
        returnOpportunity.Amount = firstOpportunity.Amount;
        returnOpportunity.CloseDate = firstOpportunity.CloseDate;
        
        returnOpportunity.Name = secondOpportunity.Name;
        returnOpportunity.Probability = secondOpportunity.Probability;
        returnOpportunity.StageName = secondOpportunity.StageName;
        
        return returnOpportunity;
    }
    
    public Opportunity createNewOpportunity() {
        Opportunity opportunity = new Opportunity();
        
        opportunity.Name = 'Default Opportunity';
        opportunity.StageName = 'Prospecting';
        opportunity.CloseDate = System.today().addDays(14);

        return opportunity;
    }

    /**
     * 
     * if(name != null) {
            opportunity.Name = name;
        } else {
            opportunity.Name = 'Default Opportunity';
        }
        if(StageName != null) {
            opportunity.StageName = stageName;
        } else {
            opportunity.StageName = 'Prospecting';
        }
        if(CloseDate != null) {
            opportunity.CloseDate = CloseDate;
        } else {
            opportunity.CloseDate = System.today().addDays(14);
        }
        if(Amount != null) {
            opportunity.Amount = amount;
        } else {
            opportunity.Amount = 250000;
        }
        if(AccountId != null) {
            opportunity.AccountId = accountId;
        } else {
            opportunity.AccountId = '000000000000000000';
        }
     */
    public Opportunity createNewOpportunity(
        String name, 
        String stageName, 
        Date closeDate, 
        Decimal amount, 
        Id accountId
    ) {
        Opportunity opportunity = new Opportunity();

        if(name == null) {
            name = 'Default Opportunity';
        }

        if(stageName == null) {
            stageName = 'Prospecting';
        }

        if(closeDate == null) {
            closeDate = System.today().addDays(14);
        }

        if(amount == null) {
            amount = 250000;
        }

        opportunity.Name = name;
        opportunity.StageName = stageName;
        opportunity.CloseDate = closeDate;
        opportunity.Amount = amount;
        opportunity.AccountId = accountId; 
        
        return opportunity;
    }

    public Opportunity createOpportunityWithAccount(Account account) {
        Opportunity opportunity = new Opportunity();
        
        opportunity.AccountId = account.Id;
        opportunity.Amount = 2500;
        opportunity.CloseDate = System.today().addDays(14);
        opportunity.Name = account.Name + ' Installations';
        opportunity.Probability = 20;
        opportunity.StageName = 'Needs Analysis';
        
        return opportunity;
    }

    public void insertOpportunity(Opportunity opportunity) {
        insert opportunity;
    }
    
}