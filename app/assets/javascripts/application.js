// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require_tree .
$(document).ready(function(){
	//$('#vav').popover('toggle');
	
	$(".icon-user, .icon-lock").parent().hover(
		function(){
			$(this).children("i").addClass("icon-white");		
		},
		function(){
			$(this).children("i").removeClass("icon-white");	
	});

	/* This method will toggle selection of checkboxes in the list view based on the selection of master checkbox */
	
	$("#toggleSelection").click(function(){
		if($(this).attr("checked"))
			$("input:checkbox").attr("checked", true);
		else
			$("input:checkbox").attr("checked", false);
	});
	
	$(".delete").click(function(){
		confirm("Are you sure you want to delete?");
	});
	
	$(".disable").click(function(){
		confirm("Are you sure you want to disable?");
	});
	
	$('#search_option').click(function(){
		//search_tables()
	});

  $('#appendedInputButtons').keypress(function(event){if (event.keyCode==13){search_tables()}});
  
  function search_tables(){
		var pathname = document.location.pathname;
		var location = pathname + "?search=" + $('#appendedInputButtons').val();
		document.location.href = location;  	
  }
	/* On Venue Search Page */
	/* On Click of any text field, the radio button on the same row will be selected, automatticaly  */
	
	$("form#venue-search input[type=text]").focus(function(){
		$(this).parent().parent().children().children('input[type="radio"]').attr('checked', 'true')
	});
	
	
	$("form#list-view").submit(function(){
		listSelected = false;
		$("form#list-view input:checkbox").each(function(){
			if($(this).attr('checked') == "checked"){
				listSelected = true;
			}
		});
		
		if(!listSelected || $("#bulk_actions").val() == ""){
			$(".alert").text("Please choose atleast one checkbox and the action you want to perform").show();
			return false;
		}
		
		return true;
	});
	
		
});