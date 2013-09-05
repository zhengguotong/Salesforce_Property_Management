public with sharing class C_ShowingEventHandler extends C_ShowingHandler 
{
	private List<Lead> leads;
	private List<Lead> tempLeads;
	
    
    public C_ShowingEventHandler(Showing__c showing)
    {
        super(showing); 
    }
    
    /**
        create a showing Event on the calendar
    **/
    public void createShowingEvent()
    {
        Event event = new Event();
        event.Subject = showing.Name;
        event.StartDateTime = showing.Start_Date_Time__c;
        event.EndDateTime =showing.End_Date_Time__c;
        event.WhatId = showing.id;
        insert event;
        
        property.H_Inspection_Time__c = showing.Start_Date_Time__c.format('E dd/MM/yyyy hh:mm a');
   	 	update property;
    }
    
    public void createCallList()
    {
    	if(showing.Status__c == C_Constant.CALL)
    	getLeads();
    	
    	 if(leads.size() >= 1)
    	 {
    	 	for(Lead lead: leads)
    	 	{
    	 		lead.Showing__c = showing.id;
    	 		lead.Property__c = showing.Property__c;
    	 	}
    	 }
    	 update leads;
    }
    
   /**
       if there are leads who wants to attend this showing event
       then send an email to inform them about the showing time 
   **/
   public void informShowingTime()
   {
        getLeads();
                          
        if(leads.size() >= 1)
        {   
            List<Messaging.SingleEmailMessage> massEmails = new List<Messaging.SingleEmailMessage>();
            List<Lead> massSMS = new List<Lead>();
            
            for(Lead lead : leads)  
            {
                  String[] toAddresses =  new String[] {lead.Email};  
                  //if this lead has email address then inform show time 
                  //by email and log the email detail in the salesfore 
                  if(lead.Email != null)
                  {
                  	massEmails.add(getEmail(toAddresses));
                    C_Utility.logActivity(EMAIL_SUBJECT,activityDescription(lead.Email),showing.id);
                  }
                   
                  //if this lead mobile phone number is not empty
                  //then inform this lead by SMS and log sms detail
                  //in the showing activity history
                  if (lead.MobilePhone != null)
                  {
                  	massSMS.add(lead);
                  	C_Utility.logActivity(SMS_SUBJECT,activityDescription(lead.MobilePhone),showing.id);
                  }
                  
                  lead.Status = C_Constant.CONTACTED;
        		  lead.Showing__c = showing.id;
				  lead.Property__c = showing.Property__c;
           }
           
	       if(massEmails.size() > 0)
	       {
	    	   C_Email.sendMassEmail(massEmails);  
	    	   //C_Utility.logActivities(EMAIL_SUBJECT, activityDescription(lead.Email), objects)
	       }
	       
	       if(massSMS.size() > 0)
	       {
	       	 C_SMS.sentBulkSMS(leads, getSmsBody()); 
	       }
	         
	       update leads;
	      
        }
    }
    
    
    private void getLeads()
    {
    	DateTime lastMonth = DateTime.now().addMonths(-3); 
        //select lead from database where the create date is from last week
        //email filed is not empty, property address is not empty
        //not informed by email before about this property inspection 
        //and the the property address is equal to the showing property address 
        leads = [Select Property_Address__c, Id, Email, Name, MobilePhone,Property__c 
        					  From Lead  
                              Where Create_Date__c > :lastMonth 
                              And Status = :C_Constant.OPEN
                              And Type__c = :getShowingType()
                              And Property_Address__c != ''
                              And Property_Address__c = :showing.Property_Address__c 
                           ];
                           
        //add lead which propery is equal to showing property                 
        for(Lead lead: [Select Property_Address__c, Id, Email, Name, MobilePhone,Property__c
        					  From Lead  
                              Where Create_Date__c > :lastMonth 
                              And Status = :C_Constant.OPEN
                              And Type__c = :getShowingType()
                              And Property__c != null
                              And Property__c = :showing.Property__c ])
       {
       	    if(leads.size() > 0)
       	    {
       	    	 if(!isAdded(lead))
       	    	 {
       	    	 	leads.add(lead);
       	    	 }
       	    } 
       	    else 
       	    {
       	    	leads.add(lead);
       	    }
       		
       }
       //add leads which has similar requirement 
       //to this showing property feature
       addTempLeads();
    }
    
    /**
    add similar requirement lead to 
    to the lead list
    **/
    private void addTempLeads()
    {
    	//the lead create date should be not later than 
    	//three month from now
    	DateTime createDate = DateTime.now().addMonths(-3);  
    	
        //get the temp lead which create date shoule not older than 3 months
        //Status is equal to open , similar location,same lead type, same 
        //number of bedroom, bathroom and pakring space 
    	tempLeads = [Select l.Property_Address__c, 
										  l.Id, 
										  l.Email, 
										  l.Name, 
										  l.MobilePhone,
    	                           		  l.Property__c,
    	                           		  l.Type__c
        					       From Lead l
                          		   Where Create_Date__c > :createDate 
                                   And Status = :C_Constant.OPEN
                                   And Location__c Includes (:property.Location__c)
                                   And Type__c = :getShowingType()
                                   And Bedroom__c IN ('' , :property.Bedroom__c)
                                   And Bathroom__c IN ('', :property.Bathroom__c)
                                   And Parking__c IN('', :property.Parking__c)
                                  ];
        for(Lead lead: tempLeads)
        {
        	if(!isAdded(lead))
        	{
        		leads.add(lead);
        	}
        }               
    }
    
    /**
    Covernt showing type wording to showing 
    time wording, thus they can match
    **/
    private String getShowingType()
    {
    	if (showing.Type__c == C_Constant.SHOWING_SAlES)
    	   return C_Constant.BUYING;
        else if(showing.Type__c == C_Constant.SHOWING_RENTALS)
           return C_Constant.RENTING;
        else 
        	return showing.Type__c;
    }
    
    /**
    Check if this lead already added to lead list 
    **/
    private Boolean isAdded(Lead lead)
    {
    	for(Lead currentLead: leads)
    	{
    		if(currentLead.Email == lead.Email || currentLead.MobilePhone == lead.MobilePhone)
    		{
    			return true;
    		}
    	}
    	return false;
    }
    
    private List<Lead> getLeadList()
    {
    	return leads;
    }
    
    
    @isTest(seeAllData=true) 
    static void creatEventTest()
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
        testShowing.Property_Address__c ='Testing Address';
        insert testShowing;
        
        C_ShowingEventHandler handler = new C_ShowingEventHandler(testShowing);
        
         Lead testLead1 = new Lead(LastName ='Testing1',
        						   Company = 'Test',
                                   Email = 'Test1@exr.com.au',
                                   MobilePhone ='1111111111',
                                   Status = 'Open',
                                   Create_Date__c = DateTime.now(),
                                   Property_Address__c = 'Testing Address');
        insert testLead1;
        
        Lead testLead2 = new Lead(LastName ='Testing2',
        						  Company = 'Test',
                                  Email = 'Test2@exr.com.au',
                                  MobilePhone ='2222222222',
                                  Status = 'Open',
                                  Create_Date__c = DateTime.now(),
                                  Property__c = testProperty.Id);
        insert testLead2;
        
        Lead testLead3 = new Lead(LastName ='Testing3',
        						  Company = 'Test',
                                  Email = 'Test@exr.com.au',
                                  MobilePhone ='2222222222',
                                  Status = 'Open',
                                  Create_Date__c = DateTime.now(),
                                  Property__c = testProperty.Id);
        insert testLead3;
        
        /**
        Test createShowingEvent
        **/
        //the number of event before insert new event
        integer beforeCount = [Select count() From Event];
        handler.createShowingEvent();
        //the number of event after invok createShowingEvent
        integer afterCount = [Select count() From Event];
        system.assertEquals(1, afterCount - beforeCount);
        
        
        handler.addTempLeads();
        handler.informShowingTime();
        handler.getLeads();
        
        system.assertEquals(0, handler.getLeadList().size());
        
        system.assertEquals(false, handler.isAdded(testLead3));     
        
        /**
        Test createCallList 
        **/
        testShowing.Status__c = C_Constant.CALL;
        update testShowing;
        
        handler = new C_ShowingEventHandler(testShowing);
        handler.createCallList();
    }
}