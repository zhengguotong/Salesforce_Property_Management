var $j = jQuery.noConflict(); 
var CHUNK_SIZE = 180000;
var MAX_SIZE = 5000000;  
var caseId = '';
var appId = '';
var leasingList = new Array();
var salesList = new Array();
var  marker;
var address ='Sydney, NSW';
var leaseMap;
var saleMap;
	      
$j(document).ready(function()
{
    //contact us validation 
     $j('#contact_form').validate({
				errorPlacement: function(error, element) {
			    error.insertAfter(element);
				}
			});
		  //repair form validation 	
	      $j('#repair_form').validate({
				errorPlacement: function(error, element) {
			    error.insertAfter(element);
				}
			});
			
			 //tenant application property information form
         	$j('#application_form1').validate({
				errorPlacement: function(error, element) {
			    error.insertAfter(element);
				}
			});
			
			//tenant application personal information form
         	$j('#application_form2').validate({
				errorPlacement: function(error, element) {
			    error.insertAfter(element);
				}
			});
			
			//tenant application emergency contact form
         	$j('#application_form3').validate({
				errorPlacement: function(error, element) {
			    error.insertAfter(element);
				}
			});
			
			//tenant application Payment Details form
         	$j('#application_form4').validate({
				errorPlacement: function(error, element) {
			    error.insertAfter(element);
				}
			});
			
			//tenant application-utility connection  form
         	$j('#application_form5').validate({
				errorPlacement: function(error, element) {
			    error.insertAfter(element);
				}
			});
			
			//tenant application application history Details form
			$j('#application_form6').validate({
				errorPlacement: function(error, element) {
			    error.insertAfter(element);
				}
			});
			
			//tenant application employment details Details form
         	$j('#application_form7').validate({
				errorPlacement: function(error, element) {
			    error.insertAfter(element);
				}
			});
			
			//tenant application other occupier details form
         	$j('#application_form9').validate({
				errorPlacement: function(error, element) {
			    error.insertAfter(element);
				}
			});
			
			//tenant application personal referees detail form
         	$j('#application_form10').validate({
				errorPlacement: function(error, element) {
			    error.insertAfter(element);
				}
			});
			
			//tenant application personal referees detail form
         	$j('#ntv_form').validate({
				errorPlacement: function(error, element) {
			    error.insertAfter(element);
				}
			});
			
	google.maps.event.addDomListener(window, 'load', initializeMap);
	
	getProperties();
	
	if(window.location.href.indexOf('#lease_property_details') > 0)
	{
		$j.mobile.changePage('#lease_property_home', {changeHash: true});
	}
	
	if(window.location.href.indexOf('#sales_property_details') > 0)
	{
		$j.mobile.changePage('#sales_property_home', {changeHash: true});
	}
	
    $j("#lpd_booking_btn").click(function() {
    	$j('#bk_id').val($j('#lpd_id').val())
		$j.mobile.changePage('#booking', {changeHash: true});
	});
	
	 $j("#spd_booking_btn").click(function() {
    	$j('#bk_id').val($j('#spd_id').val())
		$j.mobile.changePage('#booking', {changeHash: true});
	});
	
	$j('#bk_form').validate({
		errorPlacement: function(error, element) {
	    error.insertAfter(element);
		}
	});
});

function contactFormSubmit()
{
   $j.mobile.showPageLoadingMsg('a', 'Loading');
   VF_MobileHomeController.contactUs(
         $j('#contact_email').val(), 
         $j('#contact_subject').val(), 
         $j('#contact_detail').val(), 
        function(result,event){
            if (event.status) {
               window.location = '#mainpage';
            } else if (event.type === 'exception') {
            	return;
            } else {
            	return;
            }
        }, 
        {escape: true}
    );
}

function repairFormSubmit()
{
   $j.mobile.showPageLoadingMsg("a", "Loading");
   var files = document.getElementById('repair_photo').files;
   var currentFile;
   
    if (!files.length) {
      alert('Please select a file!');
      return;
    }
    else if(files.length > 5)
    {
    	$j.mobile.hidePageLoadingMsg();
    	alert('Only maximum 5 files is allowed.\n'
    	      +'Please delete some files from the list or send these files to\n'
    	      +'our email address rentals@exr.com.au');
    	$j('#repair_photo').val('');
    	return;
    }
    else
    {
    	 VF_MobileHomeController.createRepairCase(
	          $j('#repair_subject').val(),
		      $j('#repair_email').val(), 
	          $j('#repair_best_contact_number').val(),  
	          $j('#repair_details').val(),       
        function(result,event){
            if (event.status) 
            {
            	caseId = result;
            	
            	 if(caseId != '')
            	 {
            	 	for(var i = 0; i < files.length; i++)
			    	{
			    		currentFile =files[i];
			    		
			    		//check to see if file size is bigger than MAX Size,
					 	//if so do not read this file and display message box 
					    if(currentFile.size > MAX_SIZE)  
					    {
					    	alert('The file you are attaching is bigger that the server allows.\n'
					    	      +'Please putting a smaller size file or send these files to\n'
					    	      +'our email address rentals@exr.com.au');
					    	$j('#repair_photo').val('');
					    	return;
					    }
					    else 
					    {
					    	beforeUpdloadFile(currentFile);
					    }	
    				}
    				$j.mobile.hidePageLoadingMsg();
			    	alert('Your repair request has been submit to our repair team for action.\n'
									     +'We will follow up ASAP');
					window.location = '#serviceshome';
            	}
            } 
            else if (event.type === 'exception') 
            {
            	return;
            }
            else 
            {
               return;
            }
        }, 
        {escape: true}
   		);
    }
}

function beforeUpdloadFile(currentFile)
{
	var byteChunkArray = new Array();
	//check to see if file size is less than the chunk size, if so first and only chunk is entire size of file
	if(currentFile.size <= CHUNK_SIZE)
	{
		byteChunkArray[0] = '0-' + (currentFile.size - 1);
	}
	else
	{
		//Determine how many whole byte chunks make up the file,
		var numOfFullChunks = Math.floor(currentFile.size / CHUNK_SIZE); //i.e. 1.2MB file would be 1000000 / CHUNK_SIZE
		var remainderBytes = currentFile.size % CHUNK_SIZE; // would determine remainder of 1200000 bytes that is not a full chunk
		var startByte = 0;
		var endByte = CHUNK_SIZE - 1;
		
		//Loop through the number of full chunks and build the byteChunkArray array
		for(i = 0; i < numOfFullChunks; i++)
		{
			byteChunkArray[i] = startByte+'-'+endByte;
			
			//Set new start and stop bytes for next iteration of loop
			startByte = endByte + 1;
			endByte += CHUNK_SIZE;
		}
	
		//Add the last chunk of remaining bytes to the byteChunkArray
		startByte = currentFile.size - remainderBytes;
		endByte = currentFile.size;
		byteChunkArray.push(startByte+'-'+endByte);
	}
	
	//Start processing the byteChunkArray for the current file, parameter is '' because this is the first chunk being uploaded and there is no attachment Id
	processByteChunkArray(byteChunkArray,currentFile, '');
}

//Uploads a chunk of bytes, if attachmentId is passed in it will attach the bytes to an existing attachment record
function processByteChunkArray(byteChunkArray, currentFile, attachmentId)
{
	//Proceed if there are still values in the byteChunkArray, if none, all piece of the file have been uploaded
	if(byteChunkArray.length > 0)
	{
		//Determine the byte range that needs to uploaded, if byteChunkArray is like... ['0-179999','180000-359999']
		var indexes = byteChunkArray[0].split('-'); //... get the first index range '0-179999' -> ['0','179999']
		var startByte = parseInt(indexes[0]); //0
		var stopByte = parseInt(indexes[1]); //179999
	
		//Slice the part of the file we want to upload, currentFile variable is set in checkForUploads() method that is called before this method
		if(currentFile.webkitSlice)
		{
			var blobChunk = currentFile.webkitSlice(startByte , stopByte + 1);
		}
		else if (currentFile.mozSlice)
		{
			var blobChunk = currentFile.mozSlice(startByte , stopByte + 1);
		}
	
		//Create a new reader object, part of HTML5 File API
		var reader = new FileReader();
	
		//Read the blobChunk as a binary string, reader.onloadend function below is automatically called after this line
		reader.readAsBinaryString(blobChunk);
	
		//Create a reader.onload function, this will execute immediately after reader.readAsBinaryString() function above;
		reader.onloadend = function(evt)
		{
			if(evt.target.readyState == FileReader.DONE)
			{   //Make sure read was successful, DONE == 2
				//Base 64 encode the data for transmission to the server with JS remoting, window.btoa currently on support by some browsers
				var base64value = window.btoa(evt.target.result);
		
				//Use js remoting to send the base64 encoded chunk for uploading
				VF_MobileHomeController.addAttachment(currentFile.name,base64value, attachmentId,caseId,
				function(result,event)
				{
					//Proceed if there were no errors with the remoting call
					if(event.status == true)
					{
						attachmentId = result;
					    //Remove the index information from the byteChunkArray array for the piece just uploaded.
						byteChunkArray.shift(); //removes 0 index
						//Call process byteChunkArray to upload the next piece of the file
						processByteChunkArray(byteChunkArray,  currentFile, attachmentId);
					}
					else
					{
						return;
					}
				 });
			 }
			else
			{
			   return;
			}
		};
	}
}

function applicationForm1Submit()
{  
	$j.mobile.showPageLoadingMsg('a', 'Loading');
   if(appId == '')
   {
   		 VF_MobileHomeController.createApplication(
	         $j('#application_property').val(), 
	         $j('#application_lease_term').val(), 
	         $j('#application_start_date').val(), 
	         $j('#application_number_of_adult').val(), 
	         $j('#application_number_of_children').val(), 
	        function(result,event){
	            if (event.status) {
	               appId = result;
	               setCookie('appId',appId,1);
	               window.location = '#tenant_application2';
	            } else if (event.type === 'exception') {
	               alert('error');
	            } else {
	                alert('error 2');
	            }
	        }, 
	        {escape: true}
	    );
   }
   else 
   {
   		VF_MobileHomeController.updateApplication(
   		     appId,
	         $j('#application_property').val(), 
	         $j('#application_lease_term').val(), 
	         $j('#application_start_date').val(), 
	         $j('#application_number_of_adult').val(), 
	         $j('#application_number_of_children').val(), 
	        function(result,event){
	            if (event.status) 
	            {
	               window.location = '#tenant_application2';
	            } 
	            else if (event.type === 'exception') 
	            {
	               return;
	            } 
	            else 
	            {
	                return;
	            }
	        }, 
	        {escape: true}
	    );
   }
   $j.mobile.hidePageLoadingMsg();
}

function applicationForm2Submit()
{
   $j.mobile.showPageLoadingMsg('a', 'Loading');
   
   if(appId ==null || appId == '')
   {
   	   	appId = getCookie('appId');
   }
   
   if(appId != '')
   {      
         var personalDetails = new Array($j('#application_title').val(),
         								$j('#application_first_name').val(),
         								$j('#application_last_name').val(),
         								$j('#application_dob').val(),
         								$j('#application_licence').val(),
         								$j('#application_issue_state').val(),
         								$j('#application_alternate_Id').val(),
         								$j('#application_home_ph').val(),
         								$j('#application_mobile_ph').val(),
         								$j('#application_email').val(),
         								$j('#application_occupation').val(),
         								$j('#application_work_ph').val(),
         								$j('#application_current_address').val(),
         								$j('#application_current_suburb').val(),
         								$j('#application_current_postcode').val()
                                        );
   		 VF_MobileHomeController.updatePersonalDetails(
	        personalDetails,
	        appId,
	        function(result,event){
	            if (event.status) 
	            {
	               appId = result;
	               setCookie('appId',appId,1);
	               window.location = '#tenant_application3';
	            } 
	            else if (event.type === 'exception') 
	            {
	               return;
	            }
	            else 
	            {
	                return;
	            }
	        }, 
	        {escape: true}
	    );
   }
   $j.mobile.hidePageLoadingMsg();
}

function applicationForm3Submit()
{
	$j.mobile.showPageLoadingMsg('a', 'Loading');
   if(appId ==null || appId == '')
   {
   	   	appId = getCookie('appId');
   }
   
   if(appId != '')
   {      
         var contactDetails = new Array($j('#application_emergency_frist_name').val(),
         								$j('#application_emergency_surname').val(),
         								$j('#application_relationship').val(),
         								$j('#application_emergency_phone').val(),
         								$j('#application_emergency_address').val(),
         								$j('#application_emergency_suburb').val(),
         								$j('#application_emergency_postcode').val()
                                        );
   		VF_MobileHomeController.updateEmergencyContact(
	       contactDetails,
	        appId,
	        function(result,event){
	            if (event.status) 
	            {
	               appId = result;
	               setCookie('appId',appId,1);
	               window.location = '#tenant_application4';
	            } 
	            else if (event.type === 'exception') 
	            {
	               return;
	            }
	            else 
	            {
	                return;
	            }
	        }, 
	        {escape: true}
	    );
   }
   $j.mobile.hidePageLoadingMsg();
}

function applicationForm4Submit()
{
	$j.mobile.showPageLoadingMsg('a', 'Loading');
	if(appId ==null || appId == '')
    {
   	   	appId = getCookie('appId');
    }
   if(appId != '')
   {      
         var paymentDetails = new Array($j('#application_property_rentals').val(),
         								$j('#application_rental_term').val(),
         								$j('#application_first_payment').val(),
         								$j('#application_rental_bond').val(),
         								$j('#application_sub_total').val()
                                        );
   		 	VF_MobileHomeController.updatePaymentDetails(
	        paymentDetails,
	        appId,
	        function(result,event){
	            if (event.status) 
	            {
	               appId = result;
	               setCookie('appId',appId,1);
	               window.location = '#tenant_application5';
	            } 
	            else if (event.type === 'exception') 
	            {
	               return;
	            }
	            else 
	            {
	                return;
	            }
	        }, 
	        {escape: true}
	    );
   }
   $j.mobile.hidePageLoadingMsg();
}

function applicationForm5Submit()
{
	$j.mobile.showPageLoadingMsg('a', 'Loading');
	if(appId ==null || appId == '')
    {
   	   	appId = getCookie('appId');
    }
   if(appId != '')
   {      
   		 VF_MobileHomeController.updateUtilityConnection(
	        $j('#application_utitility_connection').is(':checked'),
	        appId,
	        function(result,event){
	            if (event.status) 
	            {
	               appId = result;
	               setCookie('appId',appId,1);
	               window.location = '#tenant_application6';
	            } 
	            else if (event.type === 'exception') 
	            {
	               return;
	            }
	            else 
	            {
	                return;
	            }
	        }, 
	        {escape: true}
	    );
   }
   $j.mobile.hidePageLoadingMsg();
}

function applicationForm6Submit()
{
	$j.mobile.showPageLoadingMsg('a', 'Loading');
   if(appId ==null || appId == '')
   {
   	   	appId = getCookie('appId');
   }
   
   if(appId != '')
   {      
         var appDetails = new Array($j('#application_current_length').val(),
         								$j('#application_current_agent').val(),
         								$j('#application_current_phone').val(),
         								$j('#application_current_rent').val(),
         								$j('#application_current_leaving').val(),
         								$j('#application_current_bond_why').val(),
         								$j('#application_previous_address').val(),
         								$j('#application_previous_length').val(),
         								$j('#application_perious_agent').val(),
         								$j('#application_perious_phone').val(),
         								$j('#application_perious_rent').val(),
         								$j('#application_perious_leaving').val(),
         								$j('#application_perious_bond_why').val()
                                        );
   		 	VF_MobileHomeController.updateApplicationHistory(
	        appDetails,
	        $j('#application_current_bond_yes').is(':checked'),
	        $j('#application_perious_bond_yes').is(':checked'),
	        appId,
	        function(result,event){
	            if (event.status) 
	            {
	               appId = result;
	               setCookie('appId',appId,1);
	               window.location = '#tenant_application7';
	            } 
	            else if (event.type === 'exception') 
	            {
	               return;
	            }
	            else 
	            {
	               return;
	            }
	        }, 
	        {escape: true}
	    );
   }
   $j.mobile.hidePageLoadingMsg();
}

function applicationForm7Submit()
{
	$j.mobile.showPageLoadingMsg('a', 'Loading');
   if(appId ==null || appId == '')
   {
   	   	appId = getCookie('appId');
   }
   
   if(appId != '')
   {      
         var empDetails = new Array($j('#application_emp_Occupation').val(),
         								$j('#application_emp_Name').val(),
         								$j('#application_emp_address').val(),
         								$j('#application_emp_phone').val(),
         								$j('#application_emp_length').val(),
         								$j('#application_emp_income').val(),
         								$j('#application_emp_term').val()
                                        );
   			VF_MobileHomeController.updateEmploymentDetails(
	        empDetails,
	        appId,
	        function(result,event){
	            if (event.status) 
	            {
	               appId = result;
	               setCookie('appId',appId,1);
	               window.location = '#tenant_application8';
	            } 
	            else if (event.type === 'exception') 
	            {
	              return;
	            }
	            else 
	            {
	                return;
	            }
	        }, 
	        {escape: true}
	    );
   }
   $j.mobile.hidePageLoadingMsg();
}

function applicationForm8Submit()
{
	$j.mobile.showPageLoadingMsg('a', 'Loading');
   if(appId ==null || appId == '')
   {
   	   	appId = getCookie('appId');
   }
   
   if(appId != '')
   {      
   			VF_MobileHomeController.updateOtherInfor(
	        $j('#application_car_reg').val(),
	        $j('#application_pet_yes').is(':checked'),
	        $j('#application_pet_type').val(),
	        $j('#application_smoke_yes').is(':checked'),
	        appId,
	        function(result,event){
	            if (event.status) 
	            {
	               appId = result;
	               setCookie('appId',appId,1);
	               window.location = '#tenant_application9';
	            } 
	            else if (event.type === 'exception') 
	            {
	               return;
	            }
	            else 
	            {
	                return;
	            }
	        }, 
	        {escape: true}
	    );
   }
   $j.mobile.hidePageLoadingMsg();
}

function applicationForm9Submit()
{
	$j.mobile.showPageLoadingMsg('a', 'Loading');
   if(appId ==null || appId == '')
   {
   	   	appId = getCookie('appId');
   }
   
   if(appId != '')
   {      
         var occupiers = new Array($j('#application_occupier_name1').val(),
         								$j('#application_occupier_phone1').val(),
         								$j('#application_occupier_name2').val(),
         								$j('#application_occupier_phone2').val(),
         								$j('#application_occupier_name3').val(),
         								$j('#application_occupier_phone3').val(),
         								$j('#application_occupier_name4').val(),
         								$j('#application_occupier_phone4').val(),
         								$j('#application_occupier_name5').val(),
         								$j('#application_occupier_phone5').val()
                                        );
   		 VF_MobileHomeController.updateOtherOccupier(
	        occupiers,
	        appId,
	        function(result,event){
	            if (event.status) 
	            {
	               appId = result;
	               setCookie('appId',appId,1);
	               window.location = '#tenant_application10';
	            } 
	            else if (event.type === 'exception') 
	            {
	               return;
	            }
	            else 
	            {
	                return;
	            }
	        }, 
	        {escape: true}
	    );
   }
   $j.mobile.hidePageLoadingMsg();
}

function applicationForm10Submit()
{
   $j.mobile.showPageLoadingMsg('a', 'Loading');
   if(appId == null || appId == '')
   {
   	   	appId = getCookie('appId');
   }
   
   if(appId != '')
   {      
         var referees = new Array($j('#application_reference1_name').val(),
         								$j('#application_reference1_occupation').val(),
         								$j('#application_referees1_relationship').val(),
         								$j('#application_referees1_phone').val(),
         								$j('#application_reference2_name').val(),
         								$j('#application_reference2_occupation').val(),
         								$j('#aapplication_referees2_relationship').val(),
         								$j('#application_referees2_phone').val()
                                        );
   		 VF_MobileHomeController.updateReferees(
	        referees,
	        appId,
	        function(result,event){
	            if (event.status) 
	            {
	               $j.mobile.hidePageLoadingMsg();
	               appId = result;
	               setCookie('appId',appId,1);
	               window.location = '#tenant_application11';
	            } 
	            else if (event.type === 'exception') 
	            {
	               return;
	            }
	            else 
	            {
	                return;
	            }
	        }, 
	        {escape: true}
	    );
   }
   $j.mobile.hidePageLoadingMsg();
}

function prepareFileUploads()
{
   $j.mobile.showPageLoadingMsg("a", "Loading");
   var files = document.getElementById('supporting_document').files;
   var currentFile;
   
    if (!files.length) {
      alert('Please select a file!');
      return;
    }
    else if(files.length > 10)
    {
    	$j.mobile.hidePageLoadingMsg();
    	alert('Only maximum 10 files is allowed.\n'
    	      +'Please delete some files from the list or send these files to\n'
    	      +'our email address rentals@exr.com.au');
    	$j('#supporting_document').val('');
    	return;
    }
    else
	{
		 if(appId == null || appId == '')
		 {
		   	   appId = getCookie('appId');
		 }
		 
	     if(appId != '')
		 {
		 	for(var i = 0; i < files.length; i++)
	    	{
	    		currentFile =files[i];
	    		//check to see if file size is bigger than MAX Size,
			 	//if so do not read this file and display message box 
			    if(currentFile.size > MAX_SIZE)  
			    {
			    	alert('The file you are attaching is bigger that the server allows.\n'
			    	      +'Please putting a smaller size file or send these files to\n'
			    	      +'our email address rentals@exr.com.au');
			    	$j('#supporting_document').val('');
			    	return;
			    }
			    else 
			    {
			    	beforeUpdloadFile1(currentFile);
			    }	
			}
			applicationForm11Submit(appId);
		}
    }
}

function beforeUpdloadFile1(currentFile)
{
	var byteChunkArray = new Array();
	//check to see if file size is less than the chunk size, if so first and only chunk is entire size of file
	if(currentFile.size <= CHUNK_SIZE)
	{
		byteChunkArray[0] = '0-' + (currentFile.size - 1);
	}
	else
	{
		//Determine how many whole byte chunks make up the file,
		var numOfFullChunks = Math.floor(currentFile.size / CHUNK_SIZE); //i.e. 1.2MB file would be 1000000 / CHUNK_SIZE
		var remainderBytes = currentFile.size % CHUNK_SIZE; // would determine remainder of 1200000 bytes that is not a full chunk
		var startByte = 0;
		var endByte = CHUNK_SIZE - 1;
		
		//Loop through the number of full chunks and build the byteChunkArray array
		for(var j = 0; j < numOfFullChunks; j++)
		{
			byteChunkArray[j] = startByte+'-'+endByte;
			
			//Set new start and stop bytes for next iteration of loop
			startByte = endByte + 1;
			endByte += CHUNK_SIZE;
		}
	
		//Add the last chunk of remaining bytes to the byteChunkArray
		startByte = currentFile.size - remainderBytes;
		endByte = currentFile.size;
		byteChunkArray.push(startByte+'-'+endByte);
	}
	
	//Start processing the byteChunkArray for the current file, parameter is '' because this is the first chunk being uploaded and there is no attachment Id
	processByteChunkArray1(byteChunkArray,currentFile, '');
}

//Uploads a chunk of bytes, if attachmentId is passed in it will attach the bytes to an existing attachment record
function processByteChunkArray1(byteChunkArray, currentFile, attachmentId)
{
	//Proceed if there are still values in the byteChunkArray, if none, all piece of the file have been uploaded
	if(byteChunkArray.length > 0)
	{
		//Determine the byte range that needs to uploaded, if byteChunkArray is like... ['0-179999','180000-359999']
		var indexes = byteChunkArray[0].split('-'); //... get the first index range '0-179999' -> ['0','179999']
		var startByte = parseInt(indexes[0]); //0
		var stopByte = parseInt(indexes[1]); //179999
	
		//Slice the part of the file we want to upload, currentFile variable is set in checkForUploads() method that is called before this method
		if(currentFile.webkitSlice)
		{
			var blobChunk = currentFile.webkitSlice(startByte , stopByte + 1);
		}
		else if (currentFile.mozSlice)
		{
			var blobChunk = currentFile.mozSlice(startByte , stopByte + 1);
		}
	
		//Create a new reader object, part of HTML5 File API
		var reader = new FileReader();
	
		//Read the blobChunk as a binary string, reader.onloadend function below is automatically called after this line
		reader.readAsBinaryString(blobChunk);
	
		//Create a reader.onload function, this will execute immediately after reader.readAsBinaryString() function above;
		reader.onloadend = function(evt)
		{
			if(evt.target.readyState == FileReader.DONE)
			{   //Make sure read was successful, DONE == 2
				//Base 64 encode the data for transmission to the server with JS remoting, window.btoa currently on support by some browsers
				var base64value = window.btoa(evt.target.result);
		
				//Use js remoting to send the base64 encoded chunk for uploading
				VF_MobileHomeController.addDocument(currentFile.name,base64value, attachmentId,appId,
				function(result,event)
				{
					//Proceed if there were no errors with the remoting call
					if(event.status == true)
					{
						attachmentId = result;
					    //Remove the index information from the byteChunkArray array for the piece just uploaded.
						byteChunkArray.shift(); //removes 0 index
						//Call process byteChunkArray to upload the next piece of the file
						processByteChunkArray1(byteChunkArray,  currentFile, attachmentId);
					}
					else
					{
						return;
					}
				 });
			 }
			else
			{
			   return;
			}
		};
	}
}
 	
function applicationForm11Submit(appId)
{  
   if(appId != '')
   {      
   			VF_MobileHomeController.sendAcknowledgementEmail(
	        appId,
	        function(result,event){
	            if (event.status) 
	            {
	              	$j.mobile.hidePageLoadingMsg();
					$j('#supporting_document').val('');
					alert("You application has been submit and "
						+"\nan confirmation email has been sent to your email for you reference." 
					  	+"\nPlease check your email for more details.")
					 window.location = '#serviceshome';
	            } 
	            else if (event.type === 'exception') 
	            {
	               return;
	            }
	            else 
	            {
	                return;
	            }
	        }, 
	        {escape: true}
	    );
   }
}

function ntcFromSubmit()
{
	$j.mobile.showPageLoadingMsg('a', 'Loading');
	VF_MobileHomeController.noticeToVacate(
	$j('#ntv_property').val(),
	$j('#ntv_name').val(),
	$j('#ntv_best_contact').val(),
	$j('#ntv_email').val(),
	$j('#ntv_date').val(),
	$j('#ntv_detail').val(),
    function(result,event){
        if (event.status) 
        {	
        	$j.mobile.hidePageLoadingMsg();     
            alert('Your request have been submit, we will send you a notice to vacate form'
                 +'\nto you email address. Please fill the form an return to us ASAP.')
			 window.location = '#serviceshome';
        } 
        else if (event.type === 'exception') 
        {
           return;
        }
        else 
        {
            return;
        }
    }, 
    {escape: true}
	);
}

function initializeMap() {
	
    var mapOptions = {
      center: new google.maps.LatLng(-34.397, 150.644),
      zoom: 16,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    saleMap = new google.maps.Map(document.getElementById("sale_map"),
        mapOptions);
        
    leaseMap = new google.maps.Map(document.getElementById("lease_map"),
        mapOptions);
}

function getProperties() {
    $j('#leasing_properties_list').empty();
     $j('#sales_properties_list').empty();
     
     VF_MobileHomeController.getPropertyList(
     function(records, event)
     { 
     	if (event.status) 
     	{
          showProperties(records);
        } 
        else if (event.type === 'exception') 
        {
           return;
        } else {
           return;
        }
     },
     {escape:true}); 
}


function showProperties(records)
{
	leasingList.length = 0;
	salesList.length = 0;
	
    for(var i = 0; i < records.length; i++) 
    {   
    	if(records[i].Property_Status__c === 'For Sale')
    	{
    		salesList[records[i].Id] = records[i]; 
    		
    		$j('<li></li>')
	        .attr('id', records[i].Id)
	        .hide()
	        .append('<a herf="#"><img src="/servlet/servlet.FileDownload?retURL=%2Fapex%2FPropertyList&file=' + records[i].Picture_Id__c 
	                + '" style="height:77px;width:116px:"/>'
	                + '<h2>' + NVL( records[i].Street_Number__c) +',' 
	        		+NVL( records[i].Suburn__c) + '</h2>'
	        		+'<p>' + NVL( records[i].Bedroom__c) + ' Bedroom, '
	        		+ NVL( records[i].Bathroom__c) +' Bathroom, '
	        		+  NVL( records[i].Parking__c) + ' Parking</p>'
	        		+'<p>Sale Price: $' + NVL( records[i].Sale_Price__c) + '</p>'
	        	   + '</a>')
	         .click(function(e) {
	            	e.preventDefault();
	            	marker = null;
	                showSalesDetails(this.id);
			        $j.mobile.changePage('#sales_property_details', {changeHash: true});
	            })
	        .appendTo('#sales_properties_list')
	        .show();
    	}
     	else if(records[i].Property_Status__c === 'For Rent')
     	{
     		leasingList[records[i].Id] = records[i]; 
     		
     		$j('<li></li>')
	        .attr('id', records[i].Id)
	        .hide()
	        .append('<a herf="#"><img src="/servlet/servlet.FileDownload?retURL=%2Fapex%2FPropertyList&file=' + records[i].Picture_Id__c 
	                + '" style="height:77px;width:116px:"/>'
	                + '<h2>' + NVL( records[i].Street_Number__c) +',' 
	        		+NVL( records[i].Suburn__c) + '</h2>'
	        		+'<p>' + NVL(records[i].Bedroom__c) + ' Bedroom, '
	        		+ NVL(records[i].Bathroom__c) +' Bathroom, '
	        		+  NVL(records[i].Parking__c) + ' Parking</p>'
	        		+'<p> $' + NVL(records[i].Weekly_Rentals__c) +' Per Week</p>'
	        	    + '</a>')
	         .click(function(e) {
	            	e.preventDefault();
	            	marker = null;
	                showLeaseDetails(this.id);
			        $j.mobile.changePage('#lease_property_details', {changeHash: true});
	            })
	        .appendTo('#leasing_properties_list')
	        .show();
     	}
    }
    
    $j('#sales_properties_list:visible').listview('refresh');
    $j('#leasing_properties_list:visible').listview('refresh');
   
}


function showLeaseDetails(id)
{   
    if(id != '')
    {                          
    	$j('#lpd_id').val(id);
    	$j('#lpd_title').html(leasingList[id].Street_Number__c);  
    	$j('#lpd_full_address').html(NVL(leasingList[id].Street_Number__c) + ',' +
    	                            NVL(leasingList[id].Suburn__c));
    	$j('#lpd_pic').attr('src', '/servlet/servlet.FileDownload?retURL=%2Fapex%2FLeasePropertyList&file=' +leasingList[id].Picture_Id__c);   
    	$j('#lpd_bedroom').html(NVL(leasingList[id].Bedroom__c)); 
    	$j('#lpd_bathroom').html(NVL(leasingList[id].Bathroom__c)); 
    	$j('#lpd_carspace').html(NVL(leasingList[id].Parking__c)); 
    	$j('#lpd_rentals').html(NVL(leasingList[id].Weekly_Rentals__c)); 
    	$j('#lpd_avaliable').html("Available:" + NVL(leasingList[id].Avalible_Time__c)); 
        $j('#lpd_time').html(getInspectionTime(leasingList[id].H_Inspection_Time__c)); 
        
       	address = NVL(leasingList[id].Street_Number__c) + ',' +
    	                            NVL(leasingList[id].Suburn__c + ',' + 
    	                            NVL(leasingList[id].State__c) + ',' +
    	                             NVL(leasingList[id].Post_Code__c)); 
    	                             
    	var geocoder = new google.maps.Geocoder();                                                   
        geocoder.geocode( { 'address': address}, function(results, status) {
	    if (status == google.maps.GeocoderStatus.OK) {
	      marker = new google.maps.Marker({
	          map: leaseMap,
	          position: results[0].geometry.location
	      });
	       google.maps.event.trigger(leaseMap, 'resize');
	       leaseMap.setCenter(results[0].geometry.location);
	       leaseMap.setZoom(16);
	    } else {
	    }
	 	 });
	  
    	$j.mobile.hidePageLoadingMsg();     	
    }
}

function showSalesDetails(id)
{   
    if(id != '')
    {                          
    	$j('#spd_id').val(id);
    	$j('#spd_title').html(salesList[id].Street_Number__c);  
    	$j('#spd_full_address').html(NVL(salesList[id].Street_Number__c) + ',' +
    	                            NVL(salesList[id].Suburn__c)); 
    	$j('#spd_pic').attr('src', '/servlet/servlet.FileDownload?retURL=%2Fapex%2FLeasePropertyList&file=' +salesList[id].Picture_Id__c); 
    	$j('#spd_area').html(NVL(salesList[id].Land_Area__c)); 
    	$j('#spd_bedroom').html(NVL(salesList[id].Bedroom__c)); 
    	$j('#spd_bathroom').html(NVL(salesList[id].Bathroom__c)); 
    	$j('#spd_carspace').html(NVL(salesList[id].Parking__c)); 
    	$j('#spd_price').html(NVL(salesList[id].Sale_Price__c)); 
        $j('#spd_time').html(getInspectionTime(salesList[id].H_Inspection_Time__c)); 
        
    	address = NVL(salesList[id].Street_Number__c) + ',' +
    	                            NVL(salesList[id].Suburn__c);    
    	var geocoder = new google.maps.Geocoder();                                                   
        geocoder.geocode( { 'address': address}, function(results, status) {
	    if (status == google.maps.GeocoderStatus.OK) {
	      marker = new google.maps.Marker({
	          map: saleMap,
	          position: results[0].geometry.location
	      });
	       google.maps.event.trigger(saleMap, 'resize');
	       saleMap.setCenter(results[0].geometry.location);
	       saleMap.setZoom(16);
	    } else {
	    }
	 	 });
	  
    	$j.mobile.hidePageLoadingMsg();     	
    }
}

function bookingFormSubmit()
{
		$j.mobile.showPageLoadingMsg("a", "Loading");
   		VF_MobileHomeController.bookingInspection(
	        $j('#bk_name').val(),
	        $j('#bk_email').val(),
	        $j('#bk_mobile').val(),
	        $j('#bk_preference_time').val(),
	        $j('#bk_detail').val(),
	         $j('#bk_id').val(),
	        function(result,event){
	            if (event.status) 
	            {   
	               alert("Thank for your enquiry, we will return to you ASAP.");
	               window.location = '#propertieshome';
	            } 
	            else if (event.type === 'exception') 
	            {
	               return;
	            }
	            else 
	            {
	                return;
	            }
	        }, 
	        {escape: true}
	    );
	    $j.mobile.hidePageLoadingMsg();  
}

function NVL(value)
{
	if(value == null)
		return '';
	else 
		return value;
}

function getInspectionTime(time)
{
	if(!time)
	{
		return 'Contact us to for viewing'
	}
	else 
	{
		return 'Inspection: ' + time;
	} 
}

function getCookie(c_name)
{
	var c_value = document.cookie;
	var c_start = c_value.indexOf(" " + c_name + "=");
	if (c_start == -1)
	{
		c_start = c_value.indexOf(c_name + "=");
	}
	if (c_start == -1)
	{
		c_value = null;
	}
	else
	{
		c_start = c_value.indexOf("=", c_start) + 1;
		var c_end = c_value.indexOf(";", c_start);
		if (c_end == -1)
		{
			c_end = c_value.length;
		}
		c_value = unescape(c_value.substring(c_start,c_end));
	}
	return c_value;
}

function setCookie(c_name,value,exdays)
{
	var exdate=new Date();
	exdate.setDate(exdate.getDate() + exdays);
	var c_value=escape(value) + ((exdays==null) ? "" : "; expires="+exdate.toUTCString());
	document.cookie=c_name + "=" + c_value;
}

