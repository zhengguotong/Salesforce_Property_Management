public with sharing class C_SMS 
{
	
	/**
	send single sms 
	**/
    public static void sendSms(String mobileNumber,String receipt, String smsBody)
    {
         smagicinteract__smsMagic__c smsObject = new  smagicinteract__smsMagic__c();
         
         smsObject.smagicinteract__SenderId__c = C_Constant.SMS_SENDER_ID;
         smsObject.smagicinteract__PhoneNumber__c = mobileNumber;
         smsObject.smagicinteract__Name__c = receipt;
         smsObject.smagicinteract__disableSMSOnTrigger__c = 0;
         smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
         smsObject.smagicinteract__SMSText__c = smsBody;
         
         insert smsObject;
    }
    
    
    public static smagicinteract__smsMagic__c singleSMS(Lead lead, String smsBody)
    {
    	 smagicinteract__smsMagic__c smsObject = new  smagicinteract__smsMagic__c();
         
         smsObject.smagicinteract__SenderId__c = C_Constant.SMS_SENDER_ID;
         smsObject.smagicinteract__PhoneNumber__c = lead.MobilePhone;
         smsObject.smagicinteract__Name__c = lead.Name;
         smsObject.smagicinteract__disableSMSOnTrigger__c = 1;
         smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
         smsObject.smagicinteract__SMSText__c = smsBody;
         
         return smsObject;
    }
    
     public static smagicinteract__smsMagic__c singleSMS(String[] mobile, String smsBody)
    {
    	 smagicinteract__smsMagic__c smsObject = new  smagicinteract__smsMagic__c();
         
         smsObject.smagicinteract__SenderId__c = C_Constant.SMS_SENDER_ID;
         smsObject.smagicinteract__PhoneNumber__c = mobile[0];
         smsObject.smagicinteract__disableSMSOnTrigger__c = 1;
         smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
         smsObject.smagicinteract__SMSText__c = smsBody;
         
         return smsObject;
    }
    
    /**
    send Bulk SMS 
    **/
    public static void sentBulkSMS(List<lead> leads, String smsBody)
    {
    	List<smagicinteract__smsMagic__c> smsObjectList = new List<smagicinteract__smsMagic__c>();
    	
        for(Lead lead :leads)
        {
			smsObjectList.add(singleSMS(lead, smsBody));
		}
		
		 String response = smagicinteract.ApexAPI.pushSMSCallout(smsObjectList);
		 insert smsObjectList;
     }
     
     public static void sentBulkSMS(List<String[]> mobiles, String smsBody)
    {
    	List<smagicinteract__smsMagic__c> smsObjectList = new List<smagicinteract__smsMagic__c>();
    	
        for(List<String> mobile: mobiles)
        {
			smsObjectList.add(singleSMS(mobile, smsBody));
		}
		
		 String response = smagicinteract.ApexAPI.pushSMSCallout(smsObjectList);
		 insert smsObjectList;
     }
    
     
      /**
     Test sendSms method 
     **/ 
     @IsTest(SeeAllData=true) 
     static  void sendSmsTest()
     {
     	//number of sms records before insert sms
     	integer beforeCount = [Select count() From smagicinteract__smsMagic__c];
     	
     	C_SMS.sendSms('0405795363', 'Testing', 'Testing');
     	
     	//number of sms records after insert sms
     	integer afterCount = [Select count() From smagicinteract__smsMagic__c];
     	
     	system.assertEquals(afterCount - beforeCount, 1);
     	
     }
     
     /**
     Test singleSMS Method
     **/
     @IsTest(SeeAllData=true) 
     static void signleSMSTest()
     {
     	/** Test signleSMS(Lead lead, String smsBody) **/
     	Lead testLead = new Lead(LastName = 'Testing',
     							 MobilePhone = '0405795363',
     							 Company = 'Testing');
        insert testLead;
     	
     	smagicinteract__smsMagic__c testSMS = C_SMS.singleSMS(testLead, 'Testing');
     	system.assertEquals('Testing' , testSMS.smagicinteract__SMSText__c);
     }
     
     @isTest(seeAllData=true)
     static void signleSMS1Test()
     {
     	 /** Test signleSMS(String[] mobile, String smsBody) **/
        String[] testMobile = new String[]{'0411111111'};
        smagicinteract__smsMagic__c testSMS = C_SMS.singleSMS(testMobile, 'Test signleSMS(String[] mobile, String smsBody)');
        system.assertEquals('Test signleSMS(String[] mobile, String smsBody)',testSMS.smagicinteract__SMSText__c);
     }
     
     /**
     	Test sentBulkSMS Method 
     **/
     @IsTest(SeeAllData=true) 
     static  void sentBulkSMSTest()
     {
     	//number of sms records before insert sms
     	integer beforeCount = [Select count() From smagicinteract__smsMagic__c];
     	
     	List<Lead> testLeads = new List<Lead>();
     	
     	Lead testLead = new Lead();
     	testLead.MobilePhone = '0405795363';
     	testLead.Company = 'Testing';
     	
     	testLeads.add(testLead);
     	testLeads.add(testLead);
     	
     	C_SMS.sentBulkSMS(testLeads, 'Testing');
     	
     	//number of sms records after insert sms
     	integer afterCount = [Select count() From smagicinteract__smsMagic__c];
     	
     	system.assertEquals(afterCount - beforeCount, 2);
     }
     
     @isTest(seeAllData=true) 
     static void sentBulkSMSTest2()
     {
        //number of sms records before insert sms
     	integer beforeCount = [Select count() From smagicinteract__smsMagic__c];
     	
     	List<String[]> testMobiles = new List<String[]>();
     	String[] mobile = new String[]{'0411111111'};
     	testMobiles.add(mobile);
     	
     	C_SMS.sentBulkSMS(testMobiles, 'Testing');
     	
        //number of sms records after insert sms
     	integer afterCount = [Select count() From smagicinteract__smsMagic__c];
     	
     	system.assertEquals(afterCount - beforeCount, 2);	    	
     }
}