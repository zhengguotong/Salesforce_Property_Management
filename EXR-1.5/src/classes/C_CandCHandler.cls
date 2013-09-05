public with sharing class C_CandCHandler  
{
	
	private C_C__c  call;
	
	public C_CandCHandler(C_C__c  call)
	{
		this.call = call;
	}
    
    /**
    	Create new contact and link this contact to to the Property
    **/
    public void createContact()
    {
    	Contact contact = new Contact();
             
         contact.LastName = call.Contact_Name__c;
         contact.MobilePhone = call.Mobile_Phone__c;
         contact.Phone = call.Phone__c;
         contact.Type__c = getContactType();
         Contact.Email = call.Email__c;
        
        
         //set contact property
         Property__c property = [Select Name, Id 
         						From Property__c 
         						Where id = :call.Property__c 
         						Limit 1];
         contact.Property__c  = property.id;
         insert contact;
         
        
        C_C__c currentCall = [Select c.Id, c.Contact__c From  C_C__c  c Where id = :call.id];
        
        currentCall.Contact__c = contact.id;
        update currentCall;
    }
    
    /**
    	determine the type of the contact according 
    	to the call categroy
    **/
    private string getContactType()
    {
    	if(call.Call_Category__c ==  C_Constant.OWNER)
    		return C_Constant.OWNER;
    	else if (call.Call_Category__c == C_Constant.TENANT)
    		return C_Constant.TENANT;
    	else 
    		return C_Constant.OTHER;
    }
    
    /**
       set priority according to the call category
       if the call category is lease and sale, then set 
       priority to high; if the call category is owner 
       then set priority to medium; others set prority to 
       low
    **/
    public void setPriority()
    {
    	   C_C__c currentCall = [Select c.Id, c.Call_Category__c, c.Priority__c From  C_C__c c Where id = :call.id];
          
          //if the call is about lease or sale then this call's priority to high
          if(isLead()){
              currentCall.Priority__c = C_Constant.HIGH;
          }else if (currentCall.Call_Category__c == C_Constant.OWNER){ // if is owner then set priority to medium
              currentCall.Priority__c = C_Constant.MEDIUM;
          }else {
              currentCall.Priority__c = C_Constant.LOW;
          }
          
          update currentCall;
    }
    
    /**
    When the call category is equal to 'Tenant' and 
    Type is equal to 'Repair', then check whether there is 
    open repair case for this property, if there is, then 
    log one activity under this case. Otherwise create new 
    repair case
    **/
    public void callToRepair()
    {
    	if(call.Type__c == C_Constant.REPAIR)
    	{
    	   List<Case> repairs = [Select c.Type, c.Subject, c.Repair_Status__c, 
    	                      c.Property__c, c.Estimate_Cost__c, c.Description 
    	                      From Case c
                              Where c.Type = :C_Constant.REPAIR
                              And c.Property__c = :call.Property__c
                              And c.Repair_Status__c Not In ('Completed', 'Canceled')
                             ];
           //if there is outstanding repair case,
           //log activity on this case                   
           if(repairs.size() > 0)
           {
           	   C_Utility.logActivity(call.Subject__c, call.Description__c,repairs[0].Id);
           	   updateCandC(repairs[0].Id);
           } 
           else
           {
           	  updateCandC(createRepairCase());
           } 
    	}
    }
     
     /** create new repair case for this property**/
     private String  createRepairCase()
     {
     	Case repair = new Case();
     	repair.Subject = call.Subject__c;
     	repair.Type = C_Constant.REPAIR;
        repair.Repair_Status__c = C_Constant.NEWCASE;
        repair.Description = call.Description__c;
     	repair.Property__c = call.Property__c;
     	insert repair;
     	
     	return repair.id;
     }
     
     /**
     When this call type is equal to 
     bond, then check if there is oustanding bond
     for this property then log activity in this case
     **/
     public void callToBond()
     {
     	if (call.Type__c == C_Constant.BOND)
     	{   
     		// get case list which type is equal to bond, property is equal 
     		//to this call property and bond status is not equal to completed
     		List<Case> bonds = [Select c.Type, c.Subject, c.Bond_Status__c, 
	                       c.Property__c, c.Description 
    	                   From Case c
                           Where c.Type = :C_Constant.BOND
                           And c.Property__c = :call.Property__c
                           And c.Repair_Status__c Not In ('Completed')
                           ];
            //when there are outstand bond for this property 
            //tenant log what this call is about under this 
            //case activity history
            if(bonds.size() > 0)
            {
            	 C_Utility.logActivity(call.Subject__c, call.Description__c,bonds[0].Id);
            	 updateCandC(bonds[0].Id);
            }
     	}
     }
     
     public void callToCase()
     {  
     	if(call.Case__c != null)
     	{
     		C_Utility.logActivity(call.Subject__c, call.Description__c,call.Case__c);
     	}
     	else if(isCase() && call.Case__c == null)
     	{
     		String caseId = '';
     		// get case list which type is equal to call type, property is equal 
     		//to this call property and bond status is not equal to completed
     		List<Case> cases = [Select c.Type, c.Subject, c.Bond_Status__c, 
	                       		c.Property__c, c.Description, C.Id
    	                   From Case c
                           Where c.Type = :call.Type__c
                           And c.Property__c = :call.Property__c
                           And c.Status Not In ('Completed')
                           And c.CreatedDate > :DateTime.now().addMonths(-1)
                           ];
            if(cases.size() > 0)
            {
            	C_Utility.logActivity(call.Subject__c, call.Description__c,cases[0].Id);
            	caseId = cases[0].Id;
            }
            else
            {
            	 caseId = createCase();
            }
            
            updateCandC(caseId);
     	}
     }
     
     private String createCase()
     {
     	Case repair = new Case();
     	repair.Subject = call.Subject__c;
     	repair.Type = Call.Type__c;
        repair.Description = call.Description__c;
     	repair.Property__c = call.Property__c;
     	insert repair;
     	
     	return repair.id;
     }
     
     private void  updateCandC(String CaseId)
     {
     	 C_C__c currentCall = [Select c.Id, c.Case__c From C_C__c c Where id = :call.id];
        
	     currentCall.Case__c = caseId;
	     update currentCall;
     }
     
     private Boolean isCase()
     {
     	return call.Type__c == C_Constant.APPLICATION 
     	    || call.Type__c == C_Constant.VACATING
     	    || call.Type__c == C_Constant.PROBLEM;
     }
     
    /**
       create new lead 
    **/
    public void createLead()
    {
    	 Lead lead = new Lead();
             
         lead.LastName = call.Contact_Name__c;
         lead.Company = call.Contact_Name__c;
         lead.MobilePhone= call.Mobile_Phone__c;
         lead.Phone = call.Phone__c;
         lead.Email = call.Email__c;
         lead.Type__c = getLeadType();
         lead.Status = C_Constant.OPEN;
         lead.LeadSource = C_Constant.PHONE;
     
         Property__c property = [Select Name, Id 
         						From Property__c 
         						Where id = :call.Property__c 
         						Limit 1];
         lead.Property__c  = property.id;
     
         insert lead;
        
        
        C_C__c currentCall = [Select c.Id, c.Lead__c From C_C__c c Where id = :call.id];
        
        currentCall.Lead__c = lead.id;
        update currentCall;
    }
    
    /**
    	get lead type according to call category
    **/
    private String getLeadType()
    {
    	if(call.Call_Category__c == C_Constant.RENTING)
    	   return C_Constant.RENTING;
    	else if (call.Call_Category__c == C_Constant.BUYING)
    		return C_Constant.BUYING;
        else if (call.Call_Category__c == C_Constant.MANAGEMENT)
        	return C_Constant.MANAGEMENT;
    	else
    		return C_Constant.SALE;
    }
    
    public void createTask()
    {
    	if(call.Assigned_To__c != null)
    	{
    		C_Utility.createTask(call.Subject__c, call.Description__c,
    							 call.id, call.Assigned_To__c);
    	}
    	
    }
    
    public Boolean isLead()
    { 
    	return call.Call_Category__c == C_Constant.BUYING 
    	     || call.Call_Category__c == C_Constant.SALE 
    	     || call.Call_Category__c == C_Constant.RENTING
    	     || call.Call_Category__c == C_Constant.MANAGEMENT;
    }
    
    @isTest 
    static void isLeadTest()
    {
    	C_C__c  testCall = new c_C__c(Call_Category__c = 'Buying'); 
    	
        C_CandCHandler handler = new C_CandCHandler(testCall);
        system.assertEquals(true, handler.isLead());   
        
        
        testCall.Call_Category__c = 'Sales';
        system.assertEquals(true, handler.isLead());
          
        testCall.Call_Category__c = 'Renting';
        system.assertEquals(true, handler.isLead());
        
        testCall.Call_Category__c = 'Management';
        system.assertEquals(true, handler.isLead());
        
        testCall.Call_Category__c ='Owner';
        system.assertEquals(false, handler.isLead());
    }
    
    @isTest 
    static void getLeadTypeTest()
    {
    	C_C__c  testCall = new c_C__c(Call_Category__c = 'Renting'); 
    	
        C_CandCHandler handler = new C_CandCHandler(testCall);
        system.assertEquals('Renting', handler.getLeadType());   
        
        
        testCall.Call_Category__c = 'Buying';
        system.assertEquals('Buying', handler.getLeadType());
          
       
        testCall.Call_Category__c = 'Management';
        system.assertEquals('Management', handler.getLeadType());
        
        testCall.Call_Category__c ='Sale';
        system.assertEquals('Sales', handler.getLeadType());
    }
    
    @isTest
    static void createLeadTest()
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
        
    	 C_C__c  testCall = new c_C__c(
    	 							   Subject__c = 'Test',
    	 							   Call_Category__c = 'Renting',
    	                               Contact_Name__c = 'Testing',
                                       Mobile_Phone__c = '0488888888',
                                       Phone__c = '93123333',
              						   Email__c = 'dev@exr.com.au',
              						   property__c = testProperty.id
    	                               );
       	insert testCall;
    	//The number of lead before call createLead() method                                    
        integer beforeCount = [Select count() From Lead];
        
        C_CandCHandler handler = new C_CandCHandler(testCall);
        handler.createLead();
        //The number of lead after createLead() method 
        integer afterCount = [Select count() From Lead];
        
        system.assertEquals(1, afterCount - beforeCount); 
    }
    
    @isTest 
    static void setProprityTest()
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
        
    	 C_C__c  testCall = new c_C__c(
    	 							   Subject__c = 'Test',
    	 							   Call_Category__c = 'Renting',
    	                               Contact_Name__c = 'Testing',
                                       Mobile_Phone__c = '0488888888',
                                       Phone__c = '93123333',
              						   Email__c = 'dev@exr.com.au',
              						   property__c = testProperty.id
    	                               );
       	insert testCall;
    	 //Test When call category isLead
    	 C_CandCHandler handler = new C_CandCHandler(testCall);  
    	 handler.setPriority();
    	 
    	 //get call call set the call priority
    	 C_C__c resultCall = [Select c.Id, c.Call_Category__c, c.Priority__c From  C_C__c c Where id = :testCall.id ];
    	 
    	 system.assertEquals('High', resultCall.Priority__c);     
    	 
    	 //Test when call catergory is Owner 
    	 C_C__c  testCall1 = new c_C__c(
    	 							   Subject__c = 'Test1',
    	 							   Call_Category__c = 'Owner', 
    	                               Contact_Name__c = 'Testing',
                                       Mobile_Phone__c = '0488888888',
                                       Phone__c = '93123333',
              						   Email__c = 'dev@exr.com.au',
              						   property__c = testProperty.id
    	                               );
       	insert testCall1;	
       	
       	 C_CandCHandler handler1 = new C_CandCHandler(testCall1);  
    	 handler1.setPriority();
    	 
    	 resultCall = [Select c.Id, c.Call_Category__c, c.Priority__c From  C_C__c c Where id = :testCall1.id ];
       	 system.assertEquals('Medium', resultCall.Priority__c);
       	 
       	 //Test when call catergory is Other 
    	 C_C__c  testCall2 = new c_C__c(
    	 							   Subject__c = 'Test1',
    	 							   Call_Category__c = 'Other', 
    	                               Contact_Name__c = 'Testing',
                                       Mobile_Phone__c = '0488888888',
                                       Phone__c = '93123333',
              						   Email__c = 'dev@exr.com.au',
              						   property__c = testProperty.id
    	                               );
       	insert testCall2;	
       	
       	 C_CandCHandler handler2 = new C_CandCHandler(testCall2);  
    	 handler2.setPriority();
    	 
    	 resultCall = [Select c.Id, c.Call_Category__c, c.Priority__c From  C_C__c c Where id = :testCall2.id ];
       	 system.assertEquals('Low', resultCall.Priority__c);
    }
    
    @isTest 
    static void getContactTypeTest()
    {
    	C_C__c  testCall = new c_C__c(Call_Category__c = 'Owner'); 
    	
        C_CandCHandler handler = new C_CandCHandler(testCall);
        system.assertEquals('Owner', handler.getContactType());   
        
        
        testCall.Call_Category__c = 'Tenant';
        system.assertEquals('Tenant', handler.getContactType());
          
       
        testCall.Call_Category__c = 'Other';
        system.assertEquals('Other', handler.getContactType());
    }
    
    @isTest 
    static void createContactTest()
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
        
    	 C_C__c  testCall = new c_C__c(
    	 							   Subject__c = 'Test',
    	 							   Call_Category__c = 'Owner',
    	                               Contact_Name__c = 'Testing',
                                       Mobile_Phone__c = '0488888888',
                                       Phone__c = '93123333',
              						   Email__c = 'dev@exr.com.au',
              						   property__c = testProperty.id
    	                               );
       	insert testCall;
    	//The number of lead before call createContact() method                                    
        integer beforeCount = [Select count() From Contact];
        
        C_CandCHandler handler = new C_CandCHandler(testCall);
        handler.createContact();
        //The number of lead after createLead() method 
        integer afterCount = [Select count() From Contact];
        
        system.assertEquals(1, afterCount - beforeCount); 
    }
    
    @isTest 
    static void createRepairCaseTest()
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
        
    	 C_C__c  testCall = new c_C__c(
    	 							   Subject__c = 'Test',
    	 							   Call_Category__c = 'Owner',
    	                               Contact_Name__c = 'Testing',
                                       Mobile_Phone__c = '0488888888',
                                       Phone__c = '93123333',
              						   Email__c = 'dev@exr.com.au',
              						   property__c = testProperty.id
    	                               );
       	insert testCall;
       	
       	C_CandCHandler handler = new C_CandCHandler(testCall);
        handler.createRepairCase();
        
        //get case count after invoke the method
        integer caseCount = [Select count() From Case c
                             Where c.Type = :C_Constant.REPAIR
                             And c.Property__c = :testCall.Property__c];
                             
        system.assertEquals(1, caseCount);
    }
    
    @isTest 
    static void createTaskTest()
    {
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
        
    	 C_C__c  testCall = new c_C__c(
    	 							   Subject__c = 'Testing',
    	 							   Call_Category__c = 'Tenant',
    	 							   Type__c = 'Repair',
    	                               Contact_Name__c = 'Testing',
                                       Mobile_Phone__c = '0488888888',
                                       Phone__c = '93123333',
              						   Email__c = 'dev@exr.com.au',
              						   property__c = testProperty.id,
              						   Assigned_To__c = UserInfo.getUserId()
    	                               );
       	insert testCall;
       	
       	C_CandCHandler handler = new C_CandCHandler(testCall);
       	handler.createTask();
       	
       	system.assertEquals(3, [Select count() from Task]); 
    }
    
    @isTest 
    static void callToRepairTest()
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
        
    	 C_C__c  testCall = new c_C__c(
    	 							   Subject__c = 'Testing',
    	 							   Call_Category__c = 'Tenant',
    	 							   Type__c = 'Repair',
    	                               Contact_Name__c = 'Testing',
                                       Mobile_Phone__c = '0488888888',
                                       Phone__c = '93123333',
              						   Email__c = 'dev@exr.com.au',
              						   property__c = testProperty.id
    	                               );
       	insert testCall;
       	
        C_CandCHandler handler = new C_CandCHandler(testCall);
        /**Test when there is not outstand 
        repair case for this property  **/
        handler.callToRepair();
        
        //get case count after invoke the method
        integer caseCount = [Select count() From Case c
                             Where c.Type = :C_Constant.REPAIR
                             And c.Property__c = :testCall.Property__c];
                             
        system.assertEquals(1, caseCount);
        
        /**Test when there is outstanding repair case for this property **/
        handler.callToRepair();
        
        List<Case> repairCases = [Select Id  From Case c
                                 Where c.Type = :C_Constant.REPAIR
                                 And c.Property__c = :testCall.Property__c];
                           
       system.assertEquals(1, repairCases.size());
    } 
    
    @isTest 
    static void callToBondTest()
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
         //create cAndC object which type is equal to bond 
    	 C_C__c  testCall = new c_C__c(
    	 							   Subject__c = 'Testing',
    	 							   Call_Category__c = 'Tenant',
    	 							   Type__c = 'Bond',
    	                               Contact_Name__c = 'Testing',
                                       Mobile_Phone__c = '0488888888',
                                       Phone__c = '93123333',
              						   Email__c = 'dev@exr.com.au',
              						   property__c = testProperty.id
    	                               );
       	insert testCall;
       	//create new case which case type is equal to bond 
       	//and related to testProperty object 
       	Case bond = new Case(Subject = 'Call to bond testing',
       						 Type = C_Constant.BOND,
       	                     Bond_Status__c = C_Constant.NEWCASE,
       	                     Description = 'Call to bond testing',
       	                     Property__c = testProperty.id
       	                     );
        insert bond;
        
        C_CandCHandler handler = new C_CandCHandler(testCall);
        handler.callToBond();
        
        //get number of task count which is related to 
        //this bond case 
        integer taskCount = [Select count() From Task 
        					 Where WhatId = :bond.Id
                            ];
                            
         system.assertEquals(1, taskCount);
    }
    
    @isTest 
    public static void callToCaseTest()
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
        
       	//create new case which case type is equal to bond 
       	//and related to testProperty object 
       	Case testCase = new Case(Subject = 'Call to bond case',
       						 Type = C_Constant.APPLICATION,
                             Status = 'Open',
       	                     Description = 'Call to bond testing',
       	                     Property__c = testProperty.id
       	                     );
        insert testCase;
        
         //create cAndC object which type is equal to bond 
    	 C_C__c  testCall = new c_C__c(
    	 							   Subject__c = 'Testing',
    	 							   Call_Category__c = 'Tenant',
    	 							   Type__c = 'Application',
    	                               Contact_Name__c = 'Testing',
                                       Mobile_Phone__c = '0488888888',
                                       Phone__c = '93123333',
              						   Email__c = 'dev@exr.com.au',
              						   property__c = testProperty.id
    	                               );
       	insert testCall;
       	C_CandCHandler handler = new C_CandCHandler(testCall);
       	
       	handler.createCase();
       	
       	handler.callToCase();
       	
       	testCall.Case__c = testCase.id;
       	update testCall;
       	
       	handler = new C_CandCHandler(testCall);
        handler.callToCase();
        
        testCall.Case__c = null;
        testCall.Type__c = C_Constant.VACATING;
       	update testCall;
       	
       	handler = new C_CandCHandler(testCall);
        handler.callToCase();
    }
}