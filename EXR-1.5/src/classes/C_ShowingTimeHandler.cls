public with sharing class C_ShowingTimeHandler extends C_ShowingHandler
{
	private Lead lead;
    private List<Showing__c> showings; 
    
    public C_ShowingTimeHandler(Lead lead)
    {
    	this.lead = lead;
    }
    
    /**
      if there are showing event for this property and is the start date 
       time is in the furture then send the showing event detail to customer 
    **/
    public void informTenant()
    {
    	setShowing();
    	
    	if(showing != null)
        {   
          setProperty();
          
          //if this lead emal is not null 
          //then send email notification to customer 
          //and log activity in saleforce
          if (lead.Email != null)      
          {
          	 String[] toAddress = new String[]{lead.Email};
	      	 Messaging.sendEmail(new Messaging.SingleEmailMessage[] { getEmail(toAddress) });
	      	 C_Utility.logActivity(EMAIL_SUBJECT,activityDescription(toAddress[0]), showing.id);
          } 
	      
	      sendSMS(lead);
	  
          lead.Status = C_Constant.CONTACTED;
          lead.Showing__c = showing.id;
          lead.Property__c = showing.Property__c;
        }    
    }
    
    /**
      assign showings list value and if the showing lsit is not equal 
      to null and size is greater and equal to 1
    **/
    private void setShowing()
    {
    	setShowings();
    	
    	if(showings != null && showings.size() >= 1)
    	{
    		showing = showings.get(0);
    	}
    	else 
    	{
    		showing = null;
    	}
    }
    
    /**
     if the lead has property address then check if there  are outcoming event 
     for this property address  
     else if the property is not null then check if there are outcoming evetn for this
     property. otherwise set showings equal null
    **/
    private void setShowings()
    {
    	//if lead property is not empty 
    	if (lead.Property_Address__c != null)
    	{
            //select showing__c object, where the properyty address is equal to the current lead 
            //property address, the showing time is greater than today and showing status is 
            //equal to 'Informing'
           showings = [Select id,Start_Date_Time__c, End_Date_Time__c, Property_Address__c, Type__c, Property__c
                       From Showing__c
                       Where Property_Address__c = :lead.Property_Address__c
                       And Start_Date_Time__c > :datetime.now()
                       And Status__c = :C_Constant.INFORMING
                      ];
          
    	}//if the lead propety lookup is not empty 
    	else if (lead.Property__c != null)
    	{
    	   //select showing__c object, where the properyty  is equal to the current lead 
           //property, the showing time is greater than today  and showing status is 
           //equal to 'Informing'
           showings = [Select id,Start_Date_Time__c, End_Date_Time__c, Property__c,Type__c
                                       From Showing__c s
                                       Where Property__c = :lead.Property__c
                                       And Start_Date_Time__c > :datetime.now()
                                       And Status__c = :C_Constant.INFORMING
                                       ];
    	}
    	else
    	{
    		 showing = null;
    	}
    
    }   
    
    public List<Showing__c> getShowings()
    {
    	return showings;
    }
    
    public Lead getLead()
    {
    	return lead;
    }
    
    @isTest(seeAllData=true) 
    static void getShowingsTesting()
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
        
         Lead testLead1 = new Lead(LastName ='Testing1',
        						  Company = 'Test',
                                  Email = 'Test1@exr.com.au',
                                  MobilePhone ='1111111111',
                                  Status = 'Open',
                                  Create_Date__c = Date.today(),
                                  Property_Address__c = 'Testing Address');
        insert testLead1;
        
        Lead testLead2 = new Lead(LastName ='Testing2',
        						  Company = 'Test',
                                  Email = 'Test2@exr.com.au',
                                  MobilePhone ='2222222222',
                                  Status = 'Open',
                                  Create_Date__c = Date.today(),
                                  Property__c = testProperty.Id);
        insert testLead2;
        
        //create showing object when lead has Property_Address__c
        C_ShowingTimeHandler handler = new C_ShowingTimeHandler(testLead1);
        //test setShowings when there is showing match this lead Propery_Address
        handler.setShowings();
        system.assertEquals('Testing Address', handler.getShowings()[0].Property_Address__c);
        //test setShowing when there is showing match this lead Propery_Address
        handler.setShowing();
        system.assertEquals('Testing Address', handler.getShowing().Property_Address__c);
        //test informTenant when there is showing match this lead Propery_Address
        handler.informTenant();
        system.assertEquals('Contacted', handler.getLead().Status);
        
         //create showing object when lead has Property__c
        handler = new C_ShowingTimeHandler(testLead2);
        //test setShowings when there is showing match this lead Propery__c
        handler.setShowings();
        system.assertEquals(testProperty.Id, handler.getShowings()[0].Property__c);
        //test setShowing when there is showing match this lead Propery__c
        handler.setShowing();
        system.assertEquals(testProperty.Id, handler.getShowing().Property__c);
        //test informTenant when there is showing match this lead Propery__c
        
        Lead testLead3 = new Lead(); 
        
        handler = new C_ShowingTimeHandler(testLead3);
        //test setShowings when there is not showing match this lead 
        handler.setShowings();
        system.assertEquals(null, handler.getShowings());
        //test setShowing when there is not showing match this lead
        handler.setShowing();
        system.assertEquals(null, handler.getShowing());
        //test informTenant when there is not showing match this lead
        handler.informTenant();
        system.assertEquals(null, handler.getLead().Showing__c);
    }
}