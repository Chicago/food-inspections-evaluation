/**
 * Parallax Scrolling Tutorial
 * For NetTuts+
 *  
 * Author: Mohiuddin Parekh
 *	http://www.mohi.me
 * 	@mohiuddinparekh   
 */


$(document).ready(function(){
    if(/(iPhone|iPod|iPad)/i.test(navigator.userAgent)) { 
    if(/OS [2-4]_\d(_\d)? like Mac OS X/i.test(navigator.userAgent)) {  
        // iOS 2-4 so Do Something   
    } else if(/CPU like Mac OS X/i.test(navigator.userAgent)) {
        // iOS 1 so Do Something 
    } else{
        // iOS 5 or Newer so Do Nothing
    }
}
    
    
       // Cache the Window object
        $window = $(window);
        
        $('section[data-type="background"]').each(function(){
            var $bgobj = $(this); // assigning the object
            
            $(window).scroll(function() {
                // Scroll the background at var speed
    	        // the yPos is a negative value because we're scrolling it UP!								
		        var yPos = -($window.scrollTop() / $bgobj.data('speed')); 
		
		        // Put together our final background position
		        var coords = '50% '+ yPos + 'px';

		        // Move the background
		        $bgobj.css({ backgroundPosition: coords });
    	        
            }); // window scroll Ends
            });	
    
}); 
/* 
 * Create HTML5 elements for IE's sake
 */

document.createElement("article");
document.createElement("section");
