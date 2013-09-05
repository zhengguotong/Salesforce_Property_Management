var $j = jQuery.noConflict(); 
var leasingList = new Array();
var salesList = new Array();
var  marker;
var address ='Sydney, NSW';
var leaseMap;
var saleMap;

$j(document).ready(function(){
    
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
     
     VF_PropertiesListingController.getPropertyList(
     function(records, event)
     { 
     	if (event.status) 
     	{
          showProperties(records);
        } 
        else if (event.type === 'exception') 
        {
           alert('error');
        } else {
            alert('error 2');
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
    	$j('#lpd_full_address').html(leasingList[id].Street_Number__c) + ',' +
    	                            NVL(leasingList[id].Suburn__c);
    	$j('#lpd_pic').attr('src', '/servlet/servlet.FileDownload?retURL=%2Fapex%2FLeasePropertyList&file=' +leasingList[id].Picture_Id__c); 
    	$j('#lpd_type').html(NVL(leasingList[id].Property_Type__c));  
    	$j('#lpd_furniture').html(NVL(leasingList[id].Furniture__c)); 
    	$j('#lpd_bedroom').html(NVL(leasingList[id].Bedroom__c)); 
    	$j('#lpd_bathroom').html(NVL(leasingList[id].Bathroom__c)); 
    	$j('#lpd_carspace').html(NVL(leasingList[id].Parking__c)); 
    	$j('#lpd_rentals').html(NVL(leasingList[id].Weekly_Rentals__c)); 
    	$j('#lpd_avaliable').html("Available:" + NVL(leasingList[id].Avalible_Time__c)); 
       
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
    	$j('#spd_type').html(NVL(salesList[id].Property_Type__c));  
    	$j('#spd_area').html(NVL(salesList[id].Land_Area__c)); 
    	$j('#spd_bedroom').html(NVL(salesList[id].Bedroom__c)); 
    	$j('#spd_bathroom').html(NVL(salesList[id].Bathroom__c)); 
    	$j('#spd_carspace').html(NVL(salesList[id].Parking__c)); 
    	$j('#spd_price').html(NVL(salesList[id].Sale_Price__c)); 
        
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
   		VF_PropertiesListingController.bookingInspection(
	        $j('#bk_name').val(),
	        $j('#bk_email').val(),
	        $j('#bk_mobile').val(),
	        $j('#bk_preference_time').val(),
	        $j('#bk_detail').val(),
	         $j('#bk_id').val(),
	        function(result,event){
	            if (event.status) 
	            {
	               alert("You request has been submit, we will return to you ASAP.");
	               window.location = '#propertieshome';
	            } 
	            else if (event.type === 'exception') 
	            {
	               alert('error');
	            }
	            else 
	            {
	                alert('error 2');
	            }
	        }, 
	        {escape: true}
	    );
}

function NVL(value)
{
	if(value == null)
		return '';
	else 
		return value;
}

// Removes the overlays from the map, but keeps them in the array
function clearOverlays() {
  if (markersArray) {
    for (i in markersArray) {
      markersArray[i].setMap(null);
    }
  }
}

// Shows any overlays currently in the array
function showOverlays() {
  if (markersArray) {
    for (i in markersArray) {
      markersArray[i].setMap(map);
    }
  }
}

// Deletes all markers in the array by removing references to them
function deleteOverlays() {
  if (markersArray) {
    for (i in markersArray) {
      markersArray[i].setMap(null);
    }
    markersArray.length = 0;
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
