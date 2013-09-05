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
@isTest  
private class TT_Arrears {
    
    @isTest(seeAllData=true) 
    static void ArrearsTriggerTest() 
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
       	insert testTenant;
       	
       
       Test.startTest();		
       						    
       Arrears__c testArrear = new Arrears__c();
       
       testArrear.Tenant__c = testTenant.id;
       testArrear.Amount__c = 6666;
       testArrear.Number_Of_Days__c = 5;
       testArrear.Paid_To__c = DateTime.now().addDays(2);
       testArrear.Due_To__c = DateTime.now().addMonths(1);
       
       insert testArrear;
       
        Arrears__c testArrear1 = new Arrears__c();
       
       testArrear1.Tenant__c = testTenant.id;
       testArrear1.Amount__c = 6666;
       testArrear1.Number_Of_Days__c = 3;
       testArrear1.Paid_To__c = DateTime.now().addDays(2);
       testArrear1.Due_To__c = DateTime.now().addMonths(1);
       
       insert testArrear1;
       
        Arrears__c testArrear2 = new Arrears__c();
       
       testArrear2.Tenant__c = testTenant.id;
       testArrear2.Amount__c = 6666;
       testArrear2.Number_Of_Days__c = 20;
       testArrear2.Paid_To__c = DateTime.now().addDays(2);
       testArrear2.Due_To__c = DateTime.now().addMonths(1);
       
       insert testArrear2;
       
       Test.stopTest();
    }
}