$(document).ready(function() {

    $("#domain_domain_name").bind('keyup change', function(){
        var dom = $(this).val();
        var reg = /^((?!xn--)(?!.*-\.))[a-z0-9][a-z-0-9]*\.test\.dnservices\.co\.za$/;
        $('#icon').remove();
        if(reg.test($(this).val())){ 
            $("#domain_domain_name").attr('disabled','disabled');
            $.ajax({
                type: "post",
                url: "/epp_client/available_domain",
                data: "domain_name="+dom,
                success: function(data){
                    var newSpan=null;
                    newSpan = document.createElement('span');
                    newSpan.setAttribute('id','icon');
                    if(data == "available")
                    {
                        newSpan.setAttribute('class','icon-ok');
                    }
                    else
                    {
                        newSpan.setAttribute('class','icon-remove');
                    }
                    $("#domain_domain_name").removeAttr('disabled');
                    $(newSpan).appendTo($("#domain_domain_name").parents('.controls'));
                    return false;
                },
                error: function(data)
                {
                }
            });
        }
    });

    $("select").change(function () {
        select_wrapper = $('#order_state_code_wrapper');
        $('select', select_wrapper).attr('disabled', true);
        country_code = $(this).val()
        url = "/epp_client/_subregion_select?parent_region="+country_code
        select_wrapper.load(url)
    });

    $("a[data-target=#my_modal]").click(function(ev) {
        ev.preventDefault();
        var target = $(this).attr("href");

        setTimeout(function(){
            $("#my_modal .modal-body").load(target, function() { 
                $("#my_modal").modal("show"); 
            });
        }, 1000);
    });

    $("#preview").click(function(ev) {
        ev.preventDefault();
        var target = $(this).attr("href");

        $('#preview').popover({ title: 'Look!  A bird image!'});
        return false;

    });

    $('#shit').live("click", function() {
        var name = $(this).attr('name');
        var pathname = window.location.pathname;
        $.ajax({
            type: "post",
            url: "/epp_client/read_it",
            data: "msgid="+name,
            success: function(data){
                $('#msgtbl').load(pathname)
            },
            error: function(data)
            {
            }
        });
        return false;
    });
    $(".search").typeahead();
    $(".domain[debtor_code]").typeahead();
    $('.dropdown-toggle').dropdown();
        jQuery.validator.addMethod("domain", function(value, element) { 
              return this.optional(element) || /^((?!xn--)(?!.*-\.))[a-z0-9][a-z-0-9]*\.test\.dnservices\.co\.za$/.test(value); 
        }, "");

        jQuery.validator.addMethod("IPv4", function(value, element) {
              return this.optional(element) || /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(value);
        }, "Invalid IP Address");
        jQuery.validator.addMethod("phone_fax", function(value, element) {
              return this.optional(element) || /^\+([0-9]{1,3}\.[0-9]{6,14})$/.test(value);
        }, "Invalid");

        $("#datepicker").datepicker();
        $("#new_customer,#edit_customer").validate({
            rules: {
                "customer[debtor_code]":{
                    required: true,
                },
                "customer[customer_email]":{
                    required: true,
                    email: true
                },
                "customer[customer_pass]":{
                    required: true,
                    minlength: 4 
                },
                "customer[customer_name]":{
                    required: true,
                },
                "customer[customer_org]":{
                    required: true,
                },
                "customer[customer_city]":{
                    required: true,
                },
                /*"customer[customer_country]":{
                    required: true,
                    maxlength: 2
                },*/
                "customer[customer_tel]":{
                    phone_fax: true,
                    minlength: 7,
                    required: true,
                },
                "customer[customer_fax]":{
                    phone_fax: true,
                    minlength: 7,
                    required: true,
                },
            },
            messages: {
                "customer[debtor_code]":{
                    required: "Required",
                },
                "customer[customer_email]":{
                    required: "Required",
                    email: "A valid email address is required"
                },
                "customer[customer_pass]":{
                    required: "Required",
                    minlength: "Min Length is 4 characters"
                },
                "customer[customer_name]":{
                    required: "Required",
                },
                "customer[customer_org]":{
                    required: "Required",
                },
                "customer[customer_city]":{
                    required: "Required",
                },
                /*"customer[customer_country]":{
                    required: "Required",
                },*/
                "customer[customer_tel]":{
                    required: "Required",
                    phone_fax: "Invalid Phone numbers"
                },
                "customer[customer_fax]":{
                    required: "Required",
                    phone_fax: "Invalid Phone numbers"
                },

            },
            errorClass: "help-inline",
            errorElement: "span",
            highlight:function(element, errorClass, validClass) {
              $(element).parents('.control-group').addClass('error');
            },
            unhighlight:function(element, errorClass, validClass) {
               $(element).parents('.control-group').removeClass('error');
            },
        });
        $("#new_domain, #edit_domain").validate({
            rules: {
                "domain[domain_name]":
                {
                    domain: true,
                    required: true,
                },
                "domain[debtor_code]":{
                    required: true,
                },
                "domain[domain_secret]":{
                    required: true,
                },
                "domain[ns1_ipv4_addr]":{
                    IPv4: true,
                },
                "domain[ns2_ipv4_addr]":{
                    IPv4: true,
                },
            },
            messages: {
                "domain[domain_name]":{
                    required: "Required",
                },
                "domain[debtor_code]":{
                    required: "Required",
                },
                "domain[domain_secret]":{
                    required: "Required",
                },
            },
            errorClass: "help-inline",
            errorElement: "span",
            highlight:function(element, errorClass, validClass) {
              $(element).parents('.control-group').addClass('error');
            },
            unhighlight:function(element, errorClass, validClass) {
               $(element).parents('.control-group').removeClass('error');
            },
        });
        $("#search_it").validate({
            rules: {
                "search":{
                    required: true,
                },
            },
            messages: {
                "search":{
                    required: "",
                },
            }
        });
        $("#domain_whois").validate({
            rules: {
                "domain_name":{
                    domain: true,
                    required: true,
                },
            },
            messages: {
                "domain_name":{
                    required: "",
                },
            },
        });
    });
function disAblenAble(form)
{

        if (document.getElementById('with_host_with_host').checked == true) 
        {
            document.getElementById('domain_ns_hostname1').disabled='';
            document.getElementById('domain_ns_hostname1').disabled='';
            document.getElementById('domain_ns1_ipv4_addr').disabled='';
            document.getElementById('domain_ns1_ipv6_addr').disabled='';
            document.getElementById('domain_ns_hostname2').disabled='';
            document.getElementById('domain_ns2_ipv4_addr').disabled='';
            document.getElementById('domain_ns2_ipv6_addr').disabled='';
            document.getElementById('hostname1').disabled='disabled';
            document.getElementById('hostname2').disabled='disabled';
        }
        else 
        {
            document.getElementById('hostname1').disabled='';
            document.getElementById('hostname2').disabled='';
            document.getElementById('domain_ns_hostname1').disabled='disabled';
            document.getElementById('domain_ns1_ipv4_addr').disabled='disabled';
            document.getElementById('domain_ns1_ipv6_addr').disabled='disabled';
            document.getElementById('domain_ns_hostname2').disabled='disabled';
            document.getElementById('domain_ns2_ipv4_addr').disabled='disabled';
            document.getElementById('domain_ns2_ipv6_addr').disabled='disabled';
        }
}
