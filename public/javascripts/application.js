// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(function (){
    megadrop.init ();
    carbon.portlet.init ();
    carbon.message.init ();
    carbon.init ();

    /*
     * Tabs with jQuery
     */

    //When page loads...
    $(".portlet-tab-content").hide(); //Hide all content
    $("ul.portlet-tab-nav li:first").addClass("active").show(); //Activate first tab
    $(".portlet-tab-content:first").show(); //Show first tab content

    //On Click Event
    $("ul.portlet-tab-nav li").click(function() {

        $("ul.portlet-tab-nav li").removeClass("portlet-tab-nav-active"); //Remove any "active" class
        $(this).addClass("portlet-tab-nav-active"); //Add "active" class to selected tab
        $(".portlet-tab-content").hide(); //Hide all tab content

        var activeTab = $(this).find("a").attr("href"); //Find the href attribute value to identify the active tab + content
        $(activeTab).fadeIn(); //Fade in the active ID content
        return false;
    });

    $('#user_birth_date').datepicker();

    $('#promo_period_start, #promo_period_end').datetimepicker({
         dateFormat: 'yy-mm-dd',
         time_format: '',
         showMinute: false
    });

    $('#promo_coupon_validity_start').datepicker({
        dateFormat: 'yy-mm-dd',
        numberOfMonths: 1,
        beforeShow: ValidityDate
    });

    $('#promo_start, #promo_coupon_validity_end').datepicker({
        dateFormat: 'yy-mm-dd',
        time_format: '',
        numberOfMonths: 2,
        beforeShow: ValidityRange
    });

    function ValidDate(a) {
        var b = new Date($('#promo_period_start').datepicker("getDate"));
        var c = new Date(b.getFullYear(), b.getMonth(), b.getDate()+1);
        return {
            minDate: c,
            maxDate: c
        }
    }

    function ValidityDate(a) {
        var b = new Date($('#promo_coupon_validity_start').datepicker("getDate"));
        var c = new Date(b.getFullYear(), b.getMonth(), b.getDate()+0);
        return {
            minDate: c
        }
    }

    function ValidityRange(a) {
        var b = new Date($('#promo_coupon_validity_start').datepicker("getDate"));
        var c = new Date(b.getFullYear(), b.getMonth(), b.getDate()+2);
        return {
            minDate: c
        }
    }
   
    $('#promo_manual_code').keyup( function() {
        var maxLength = 8;
        if(this.value.length > maxLength){
            this.value = this.value.substr(0, maxLength);
        }
        return true;
    });

    $('.countdown').each(function(){
      $(this).countdown({until: $(this).text()});
    });
});

