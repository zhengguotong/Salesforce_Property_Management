trigger T_AI_Lead on Lead (after insert) 
{
	for(Lead lead: Trigger.new)  
    {
       
        Lead currentLead = [Select id, Email,Create_Date__c,Property_Address__c, Property__c, MobilePhone
                            From Lead 
                            Where id = :lead.id];
         //update create date                   
        currentLead.Create_Date__c = datetime.now(); 
        
         // not informed by email before
        if(currentLead.Status == C_Constant.OPEN)
        {   
        	C_ShowingTimeHandler handler = new C_ShowingTimeHandler(currentLead);
        	handler.informTenant();
        }
         update currentLead;                  
  }
}