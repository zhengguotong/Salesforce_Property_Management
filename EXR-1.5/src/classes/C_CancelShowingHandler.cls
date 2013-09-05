public with sharing class C_CancelShowingHandler extends C_ShowingUpdateHandler 
{
	public final String SUBJECT = 'Inform Customer about Cancelling Showing Event';
	
	public C_CancelShowingHandler(Showing__c showing)
    {
    	super(showing);
    }
		
	/**
     get cancel showing event email body 
    **/
    protected override String getEmailBody()  
    {
    	String htmlBody = '<html>Dear Customers,<br><br>' 
                       	+ 'Since our agents have busy schedule ,'   + '<br>'
		                + propertyAddress 
		                + '<br> open inspection is cancelled.<br>'
		                + 'Sorry for any incovenience.<br><br>'
		                + 'If you are interest in our other properties.<br>'
		                + 'Please refer to www.exr.com.au for more details.'
		                + '<br><br>Excelsior Realty Pty Ltd'
		                + '<br>Tel: 02-9281 6777'
		                + '</html>';
        return htmlBody;
   } 
   
   protected override String getSmsBody()
   {
   	  String smsBody= ''; 
   	  SmsBody +=  'Dear Customer, ' 
   	            + 'Since our agents have busy schedule ,'   
                + propertyAddress
		        + ' open inspection is cancelled. ' 
		        + ' Sorry for any incovenience. ' 
		        + ' If you are interest in our other properties '
		        + ' please refer to www.exr.com.au for more details.  '
		        + ' Excelsior Realty Pty Ltd '
		        + ' Tel: 02-9281 6777 ';
   	  
   	  return smsBody;
   }
   
   /**
     delete event on saleforce
   **/
   protected override void updateEvent() 
   {
   	   if(event.size() > 0)
   	   {	
   	   		delete event[0]; 
   	   }   
   }
   	
	protected  override void logActivity()
	{
		C_Utility.logActivity(SUBJECT, getDescription(), showing.Id);
	}
	
	/**
	get task description 
	**/
	protected override String getDescription()
	{
		String description = '';
		description += 'Subject: ' +subject
		            +  '\n\nTo Address:'; 
		            
		for(Lead lead: leads)
		{
			description +=lead.Name + ', \t';
	    }
	    
	    description += '\nDear Customer, \n\n' 
                    + 'Since our agents have busy schedule ,\n ' 
                    +  propertyAddress
                    + '\nopen inspection is cancelled.\n' 
                    + 'Sorry for any incovenience.\n' 
                    + 'If you are interest in our other properties\n'
                    + 'Please refer to www.exr.com.au for more details.\n\n'
                    + 'Excelsior Realty Pty Ltd'
                    + 'Tel: 02-9281 6777';
        return description; 
	}
	
	@isTest(seeAllData=true) 
	static void C_CancelShowingHandlerTest()
	{
		 //create new property object 
   		 Property__c testProperty = new Property__c(Location__c = 'Western Suburb',
   		 										    BedRoom__c = '5',
   		 										    Bathroom__c= '5',
   		 										    Parking__c = '3',
                                                    Weekly_Rentals__c = 900,
                                                    Furniture__c = 'Unfurinished',
                                                    Sale_Price__c = 2000000.00,
                                                    Unit_Number__c = '98',
                                                    Building_Name__c = 'Testing Building Name',
                                                    Street_Number__c = '98',
                                                    Suburn__c = 'Testing Suburn',
                                                    State__c = 'Test State',
                                                    Post_Code__c = '5168');
        insert testProperty;
        
        //create new showing object 
        Showing__c testShowing = new Showing__c();
        testShowing.Start_Date_Time__c = DateTime.now().addDays(1);
        testShowing.End_Date_Time__c = DateTime.now().addDays(2);
        testShowing.Name = 'Testing';
        testShowing.Property__c = testProperty.id;
        testShowing.Status__c ='Informing';
        insert testShowing;
        
        //create related leads 
        Lead testLead = new Lead(LastName = 'Testing',
        						Company = 'Testing', 
        						MobilePhone = '0405795363',
        						Email = 'dev@exr.com.au',
        						Showing__c = testShowing.Id
        						);
        insert testLead;
        
         Lead testLead1 = new Lead(LastName = 'Testing1',
        						Company = 'Testing1', 
        						MobilePhone = '0405795363',
        						Email = 'dev@exr.com.au',
        						Showing__c = testShowing.Id
        						);
        insert testLead1;
        
         Lead testLead2 = new Lead(LastName = 'Testing2',
        						Company = 'Testing2', 
        						MobilePhone = '0405795363',
        						Email = 'dev@exr.com.au',
        						Showing__c = testShowing.Id
        						);
        insert testLead2;
        
        C_CancelShowingHandler handler = new C_CancelShowingHandler(testShowing);
        
        //test getEmailBody
        system.assertEquals(true, handler.getEmailBody().contains('98 Testing Building Name 98 Testing Suburn Test State 5168'));
        //test getSMSbody 
        system.assertEquals(true, handler.getSMSBody().contains('98 Testing Building Name 98 Testing Suburn Test State 5168'));
        
        /*test updateEvent */
        //before delete the related event count 
        integer eventCount = [Select count() From Event  
         					   Where WhatId = :testShowing.id]; 				   
        system.assertEquals(1, eventCount);
        
        //delete the event 						 
        handler.updateEvent();
        
        //after delete the related event count 
        eventCount = [Select count() From Event  
         					   Where WhatId = :testShowing.id]; 	
        system.assertEquals(0,eventCount);
        
         /*Test logActivity*/
         handler.logActivity();
         
         /*Test getDescription*/
         system.assertEquals(true, handler.getDescription().contains('98 Testing Building Name 98 Testing Suburn Test State 5168'));
	}
}