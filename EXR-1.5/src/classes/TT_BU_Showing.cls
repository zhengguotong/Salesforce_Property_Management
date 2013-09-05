/** 
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true) 
private class TT_BU_Showing {

    static testMethod void myUnitTest() 
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
        						Showing__c = testShowing.Id,
        						Status = 'Qualified'
        						);
        insert testLead;
        
         Lead testLead1 = new Lead(LastName = 'Testing1',
        						Company = 'Testing1', 
        						MobilePhone = '0405795363',
        						Email = 'dev@exr.com.au',
        						Showing__c = testShowing.Id,
        						Status = 'Contacted'
        						);
        insert testLead1;
        
         Lead testLead2 = new Lead(LastName = 'Testing2',
        						Company = 'Testing2', 
        						MobilePhone = '0405795363',
        						Email = 'dev@exr.com.au',
        						Showing__c = testShowing.Id,
        						status = 'Open'
        						);
        insert testLead2;
        
        //test Cancel Showing Event 
        testShowing.Status__c = C_Constant.CANCELLED;
        update testShowing;
        
        //test Change showing time 
        testShowing.Status__c = C_Constant.CHANGE_TIME;
        update testShowing;
        
        //test Complete Showing Event 
        testShowing.Status__c = C_Constant.COMPLETED;
        update testShowing;       
    }
}