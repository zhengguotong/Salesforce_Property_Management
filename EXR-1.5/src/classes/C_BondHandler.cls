public class C_BondHandler extends C_CaseHandler
{   
	public static final String EVENT_SUBJECT = ' Bond Inspection';
	
	public C_BondHandler(Case repair)
	{
		super(repair);
	}
	
	public void handleBond()
	{
		handleInspection();
		completedBond();
	}
	
	/**
	When this bond case, bond status equal to inspection 
	and inspection time is not null then create a bond 
	inspection event if there is not existing found under 
	this case. Otherwise update existing event's startdatetime 
	and enddatetime
	**/
	private void handleInspection()
	{
		if (repair.Bond_Status__c == C_Constant.INSPECTION
		   && repair.Inspection_Time__c != null)
		{
			if(getEvents() == null || getEvents().size() == 0)
			{
				createEvent(C_Utility.NVL(repair.H_Property_Address__c) + EVENT_SUBJECT);
			}
			else 
			{
				updateEvent(getEvents()[0]);
			}
		}
	}
	
	/**
	When this case's bond statuc is equal to completed 
	and inspection is null then update this property's 
	last inspection time
	**/
	private void completedBond()
	{
		if(repair.Bond_Status__c == C_Constant.COMPLETED
		&& repair.Inspection_Time__c != null)
		{
			upateLastInspectionTime();
		}
	}
	
	@isTest 
    public static void handleInspectionTest()
    {
    	Case testCase = new Case();
		testCase.Type =  C_Constant.BOND;
		testCase.Bond_Status__c = C_Constant.INSPECTION;
		testCase.Inspection_Time__c = Datetime.now();
		insert testCase;
		//Test when there is not event related to this case 
		C_BondHandler handler = new C_BondHandler(testCase);
	    handler.handleInspection();
		system.assertEquals(1, handler.getEvents().size());
		
		//update inspection time and test whether the 
		//event related to this case is updated
		DateTime now = Datetime.now().addDays(2);
		testCase.Inspection_Time__c = now;
		update testCase;
		
		handler.handleInspection();
		
		List<Event> event = [Select Id, StartDateTime From event Where WhatId = :testCase.id];
		
		system.assertEquals(1, handler.getEvents().size());
		system.assertEquals(now,event[0].StartDateTime);
		
		handler.handleInspection();
    }
    
    @isTest 
    public static void completedBondTest()
    {
		Case testCase = new Case();
	    testCase.Type = C_Constant.BOND;
		testCase.Bond_Status__c = C_Constant.COMPLETED;
		testCase.Inspection_Time__c = Datetime.now();
		insert testCase;
		
		C_BondHandler handler = new C_BondHandler(testCase);
		handler.completedBond();

        handler.handleBond();
      }
}