// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery-1.6.4
//= require jquery_ujs
//= require jquery-ui
//= require_directory .
//= require_self

function moveEvent(event, dayDelta, minuteDelta, allDay){
    jQuery.ajax({
        data: 'id=' + event.id + '&title=' + event.title + '&day_delta=' + dayDelta + '&minute_delta=' + minuteDelta + '&all_day=' + allDay,
        dataType: 'script',
        type: 'post',
        url: "/interviews/move"
    });
}

function resizeEvent(event, dayDelta, minuteDelta){
    jQuery.ajax({
        data: 'id=' + event.id + '&title=' + event.title + '&day_delta=' + dayDelta + '&minute_delta=' + minuteDelta,
        dataType: 'script',
        type: 'post',
        url: "/interviews/resize"
    });
}

$(function() {
$("#interviewer_filter").change(function() {
if($("#interviewer_filter").val() == "")
alert("Please select a valid filter.")
else
$('#filter_by_interviewer').submit();
});

$('.follow_link').bind('click', function(e) {
  var candidate_id = $(this).attr('data-candidate-id');
  e.preventDefault();
    jQuery.ajax({
        type: 'get',
        url: "/candidates/"+candidate_id+"/toggle_follow",
        error: function (xhr, status) {
            alert(status);
        },
        success: function(data){
                    var src = (data == "Track")
                    ? "/assets/trackit.png"
                    : "/assets/un-trackit.png";
          $("#follow_link_"+candidate_id).attr("src", src);
          $("#follow_link_"+candidate_id).attr("title", data);
          $("#follow_link_"+candidate_id).attr("alt", data);
        }
    });
});

$('#tag_autocomplete').tokenInput("/pull_tags",
{
  theme: "facebook",
  tokenLimit: 10,
  tokenValue: "name",
  preventDuplicates: true,
  prePopulate: $("#tag_autocomplete").data("pre"),
  hintText: "Type in a Tag Name",
  noResultsText: "No Tag Found",
  searchingText: "Searching Tags...",
  onAdd: function(item) {
  }, resultsFormatter: function(item) {
    return "<li><div style='display: inline-block; padding-left: 10px;'><div class='full_name'>" + item.name + "</div></div></li>"
  }, tokenFormatter: function(item) {
    return "<li><p>" + item.name + "</p></li>"
  }
});

if($('li.token-input-token-facebook').length == 0) {
   $('#token-input-tag_autocomplete').val('Search by Tags');
}

$('#token-input-tag_autocomplete').focus(function() {
  $(this).val('');
})
.keypress(function(e){
  if(e.which == 13){
   e.preventDefault();
   $('#searchform').submit();
   }
})
.blur(function() {
   if($('li.token-input-token-facebook').length == 0) {
    $(this).val('Search by Tags');
    var style = $(this).attr('style');
    $(this).attr('style', style.replace(/width: \d\dpx;/g, ''));
   } else {
    $('#searchform').submit();
   }
 });

$('.feedback').truncate({max_length: 100});

});

function editEvent(interview_id, candidate_id, interviewer_id){
    jQuery.ajax({
        data: 'interviewer_filter='+ interviewer_id,
        dataType: 'script',
        type: 'get',
        url: "/candidates/"+candidate_id+"/interviews/"+interview_id+"/edit"
    });
}

function deleteEvent(interview_id, candidate_id, delete_all){
  var answer = confirm("Are you sure to delete this interview schedule?")
    if(answer) {
    jQuery.ajax({
        data: 'id=' + interview_id + '&delete_all='+delete_all,
        dataType: 'script',
        type: 'delete',
        url: "/candidates/"+candidate_id+"/interviews/"+interview_id
    });
    }
}

function cancelEvent(interview_id, candidate_id){
  var answer = confirm("Are you sure to cancel this interview schedule?")
    if(answer) {
    jQuery.ajax({
        data: 'cancel=true',
        dataType: 'script',
        type: 'delete',
        url: "/candidates/"+candidate_id+"/interviews/"+interview_id
    });
    }
}


function showEventDetails(event){
    $('#event_desc').html(event.description);
    title = event.title;
	other_interviewers = $.parseJSON(event.other_int);
	if(other_interviewers.length > 0) {
		$('#event_desc').append("<br /><strong>Other Interviewers:</strong><br />");		
		$.each(other_interviewers,function(i,key){
			$('#event_desc').append("<ul style='margin:0px'><li> "+key.o_name+" - "+ key.o_role +"</li></ul>");			
		});
	}
    var allowable_types = [ "Administrator", "Hr" ];
    if($.inArray(event.user_type, allowable_types) > -1) {
    $('#edit_event').html("<a href = 'javascript:void(0);' onclick ='editEvent(" + event.id + ", " + event.candidate_id+", " + event.interviewer_id +")'>Edit</a>&nbsp;|");
    $('#edit_event').append("&nbsp;<a href = 'javascript:void(0);' onclick ='cancelEvent(" + event.id + ", " + event.candidate_id + ", " + false + ")'>Cancel</a>&nbsp;|");
    if (event.recurring) {
        title = event.title + "(Recurring)";
        $('#delete_event').html("&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + event.candidate_id + ", " + false + ")'>Delete Only This Occurrence</a>");
        $('#delete_event').append("&nbsp;&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + true + ")'>Delete All In Series</a>")
        $('#delete_event').append("&nbsp;&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", \"future\")'>Delete All Future Events</a>")
    }
/*    else {
       $('#delete_event').html("|&nbsp;<a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + event.candidate_id + ", " + false + ")'>Delete</a>");
    } */
  }
    $('#edit_event').append('&nbsp;'+feedback_link(event));
    $('#desc_dialog').dialog({
        title: title,
        modal: true,
        width: 500,
        close: function(event, ui){
            $('#desc_dialog').dialog('destroy')
            $('#edit_event').html('');
        }

    });

  }

  function feedback_link(event){
    if (event.comment_id == 0) {
      return "<a href = '/candidates/"+event.candidate_id+"/interviews/"+event.id+"/comments/new'>Feedback</a>";
      } else {
      return "<a href = '/candidates/"+event.candidate_id+"/interviews/"+event.id+"/comments/"+event.comment_id+"/edit'>Edit Feedback</a>";
    }
  }


  function my_convertDate(date) {
    date_obj = new Date(date);
    date_obj_hours = date_obj.getHours();
    date_obj_mins = date_obj.getMinutes();

    if (date_obj_mins < 10) { date_obj_mins = "0" + date_obj_mins; }

    if (date_obj_hours > 11) {
        date_obj_hours = date_obj_hours - 12;
        date_obj_am_pm = " PM";
    } else {
        date_obj_am_pm = " AM";
    }

    date_obj_time = " "+date_obj_hours+":"+date_obj_mins+date_obj_am_pm;
    return $.datepicker.formatDate("dd-mm-yy", date_obj)+date_obj_time;
  }


function showPeriodAndFrequency(value){

    switch (value) {
        case 'Daily':
            $('#period').html('day');
            $('#frequency').show();
            break;
        case 'Weekly':
            $('#period').html('week');
            $('#frequency').show();
            break;
        case 'Monthly':
            $('#period').html('month');
            $('#frequency').show();
            break;
        case 'Yearly':
            $('#period').html('year');
            $('#frequency').show();
            break;

        default:
            $('#frequency').hide();
    }
}
