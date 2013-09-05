public with sharing class C_Utility  
{
	 /**
        substitute a value when a null value is encountered
     **/
     public static String NVL(String str)
     {
     	if(str == null)
     	  return '';
     	else 
     	  return str;
     }
     
     /**
     Get Tenant related Property
     **/
     public static List<Property__c> getProperty(Tenant__c tenant)
     {
     	List<Property__c> properties = [Select Unit_Number__c,
     										   Building_Name__c,
     										   Street_Number__c,
     										   Suburn__c,
     										   State__c,
     										   Post_Code__c
     	                              From Property__c
     	                              Where Id = :tenant.Property__c];
        
        return properties;
     }
     
     /**
     Get proeprty Full address
     **/
     public static String propertyAddress(List<Property__c> properties)
     {
     	String propertyAddress = '';
     	//if the properties is not null
        if(properties.size() >= 1)
        {
        	propertyAddress += NVL(properties[0].Unit_Number__c)
        	                + ' ' + NVL(properties[0].Building_Name__c)
        	                + ' ' + NVL(properties[0].Street_Number__c)
        	                + ' ' + NVL(properties[0].Suburn__c)
        	                + ' ' + NVL(properties[0].State__c)
        	                + ' ' + NVL(properties[0].Post_Code__c);
        }
        
        return propertyAddress;
     }
     
      /**
     Get proeprty Full address
     **/
     public static String propertyAddress(Property__c property)
     {
    	return  NVL(property.Unit_Number__c)
                + ' ' + NVL(property.Building_Name__c)
                + ' ' + NVL(property.Street_Number__c)
                + ' ' + NVL(property.Suburn__c)
                + ' ' + NVL(property.State__c)
                + ' ' + NVL(property.Post_Code__c);
     }
     
     /**
     Log Activity History 
     **/
     public static void logActivity(String subject, String description, String id)
     {
     	Task task = new Task();
        task.OwnerId = UserInfo.getUserId();
        task.Subject = subject;
        task.Description = description;   
        task.WhatId = id;
        task.Status = C_Constant.COMPLETED; 
        
        insert task;
     }
     
     public static Task getTask(String subject, String description, String id)
     {
     	Task task = new Task();
     	task.OwnerId = UserInfo.getUserId();
        task.Subject = subject;
        task.Description = description;  
        task.WhatId = id;
        task.Status = C_Constant.COMPLETED;
        
        return task;
     }
     
     public static void createTask(String Subject, String Description, String whatId, String ownerId)
     {
     	Task task = new Task();
     	task.OwnerId = ownerId;
        task.Subject = subject;
        task.Description = description;  
        task.WhatId = whatId;
        task.Status = C_Constant.NOT_STARTED;
        
        insert task; 
     }
     
     public static void logActivities(String subject, String description, List<SObject> objects)
     {
     	List<Task> tasks = new List<Task>(); 
     	
     	for(SObject obj : objects)
     	{
     		tasks.add(getTask(subject, description,obj.id));
     	}
     	
     	insert tasks;
     }
     
    public static  Messaging.EmailFileAttachment[] gentAttachments(String id)
	{
		 Messaging.EmailFileAttachment[] efas = new Messaging.EmailFileAttachment[]{};
		//get list of attachement under this repair case
		 List<Attachment> attachments = [Select Name, Body
		 								 From Attachment 
		 								 Where ParentId =:id
		 	                             ];
		 	                              
		 for(Attachment attachment: attachments)
		 {
		 	Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
    	 	efa.setFileName(attachment.Name);
         	efa.setBody(attachment.Body); 
         	
         	efas.add(efa);
		 }
		  
         return efas;
	}
	
	
     
    @IsTest 
    static void NVLTest() 
    {
       //test Null string 
       String nullString = Null;
       system.assertEquals('', C_Utility.NVL(nullString));
       
       //Test non-null String
       String str = 'Test';
       system.assertEquals('Test', C_Utility.NVL(str));
    }
     
     @isTest 
     static void getPropertyTest() 
     {
     	//create new test owner 
    	Account testOwner = new Account(Name = 'Test Owner'); 
        insert testOwner;
        
        //create new test property 
        Property__c testProperty = new Property__c(Name = 'Test Property',
                                                   Property_Owner__c = testOwner.Id,
                                                   Unit_Number__c = '6678',
                                                   Building_Name__c = 'Test Buiding Name',
                                                   Street_Number__c ='Test Street Name',
                                                   Suburn__c = 'Test Suburn',
                                                   State__c = 'NSW',
                                                   Post_Code__c ='2000'
                                                   );
       insert testProperty;
       
       //create test tenant
       Tenant__c testTenant = new Tenant__c(Name = 'Test Tenant',
       									    Property__c = testProperty.id,
       									    Mobile_Phone__c = '0405795363',
       									    Email__c = 'dev@exr.com.au');
       									    
       List<Property__c> testProperties = C_Utility.getProperty(testTenant);
       
       system.assertEquals(1, testProperties.Size());
       system.assertEquals(testProperty.Id, testProperties[0].Id); 
     }
    
     
     @IsTest
     static  void propertyAddressTest()
     {
     	List<Property__c> testProperties = new List<Property__c>();
     	
     	system.assertEquals('', C_Utility.propertyAddress(testProperties)); 
     	
     	//create new test owner 
    	Account testOwner = new Account(Name = 'Test Owner'); 
        insert testOwner;
        
     	 //create new test property 
        Property__c testProperty = new Property__c(Name = 'Test Property',
                                                   Property_Owner__c = testOwner.Id,
                                                   Unit_Number__c = '6678',
                                                   Building_Name__c = 'Test Buiding Name',
                                                   Street_Number__c ='Test Street Name',
                                                   Suburn__c = 'Test Suburn',
                                                   State__c = 'NSW',
                                                   Post_Code__c ='2000'
                                                   );
     	String assertResult = '6678 Test Buiding Name Test Street Name Test Suburn NSW 2000';
     	
        system.assertEquals(assertResult,C_Utility.propertyAddress(testProperty));
        
        testProperties.add(testProperty);
        system.assertEquals(assertResult,C_Utility.propertyAddress(testProperties)); 
     }
     
     @IsTest 
     static void logActivityTest()
     {
     	Account testOwner = new Account(Name = 'Test Owner'); 
     	
     	//get total number of task before insert task 
     	Integer beforeCount = [Select count() From Task];
     	
     	C_Utility.logActivity('Testing', 'Testing', testOwner.Id);
     	
     	//get total number of task after creating new task
     	Integer afterCount = [Select count() From Task];
     	
     	//compare whether the new task has been inserted
     	system.assertEquals(1, afterCount - beforeCount);  
     }
     
     @IsTest 
     static void getTaskTest()
     {
     	Account testOwner = new Account(Name = 'Test Owner'); 
     	
     	Task testResult = C_Utility.getTask('Testing', 'Testing', testOwner.Id);

     	
     	system.assertEquals('Testing', testResult.Subject);  
     	system.assertEquals('Testing',testResult.Description);
     	system.assertEquals(testOwner.Id, testResult.WhatId);
     }
     
     @isTest
     static void createTaskTest()
     {
     	Account testOwner = new Account(Name = 'Test Owner'); 
     	C_Utility.createTask('Testing', 'Testing', testOwner.id, UserInfo.getUserId());
     	system.assertEquals(1, [Select count() From Task]);  
     }
     
     @IsTest 
     static void logActivitiesTest()
     {
     	List<Account> testOwners = new List<Account>();
     	
     	Account testOwner1 = new Account(Name = 'Test Owner1'); 
     	testOwners.add(testOwner1);
     	
     	Account testOwner2 =  new Account(Name = 'Test Owner2');
        testOwners.add(testOwner2);
        
     	//get total number of task before insert task 
     	Integer beforeCount = [Select count() From Task];
     	
     	C_Utility.logActivities('Testing', 'Testing', testOwners);
     	
     	//get total number of task after creating new task
     	Integer afterCount = [Select count() From Task];
     	
     	//compare whether the new task has been inserted
     	system.assertEquals(2, afterCount - beforeCount);  
     }
     
     @isTest 
     static void getAttachmentsTest()
     {
     	Case testCase = new Case(Subject = 'Test');
    	insert testCase;
    	
    	Messaging.EmailFileAttachment[] efa = gentAttachments(testCase.Id);
    	system.assertEquals(0, efa.size());
    	
        Blob testBlob = Blob.valueof('Test paf');
    	
    	Attachment attachment = new Attachment();
    	attachment.Name = 'Test.pdf';
    	attachment.Body = testBlob;
    	attachment.ParentId = testCase.Id;
    	insert attachment;
    	
    	Attachment attachment1 = new Attachment();
    	attachment1.Name = 'Test1.pdf';
    	attachment1.Body = testBlob;
    	attachment1.ParentId = testCase.Id;
    	insert attachment1;
    	
    	efa = gentAttachments(testCase.Id);
    	
    	system.assertEquals(2, efa.size());
    	
     }
}