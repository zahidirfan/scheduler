// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

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

function showNewInterview(start, end, event){

      $('#new_interview_dialog').dialog({
        title: title,
        modal: true,
        width: 500,
        close: function(event, ui){
            $('#desc_dialog').dialog('destroy')
        }

    });

}


function showEventDetails(event){
    $('#event_desc').html(event.description);
    title = event.title;
    if(event.user_type == "Administrator" || event.user_type == "Bm") {
    $('#edit_event').html("<a href = 'javascript:void(0);' onclick ='editEvent(" + event.id + ", " + event.candidate_id+")'>Edit</a>");
    if (event.recurring) {
        title = event.title + "(Recurring)";
        $('#delete_event').html("&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + event.candidate_id + ", " + false + ")'>Delete Only This Occurrence</a>");
        $('#delete_event').append("&nbsp;&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + true + ")'>Delete All In Series</a>")
        $('#delete_event').append("&nbsp;&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", \"future\")'>Delete All Future Events</a>")
    }
    else {
        $('#delete_event').html("<a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + event.candidate_id + ", " + false + ")'>Delete</a>");
    }
    }
    $('#desc_dialog').dialog({
        title: title,
        modal: true,
        width: 500,
        close: function(event, ui){
            $('#desc_dialog').dialog('destroy')
        }

    });

}


function editEvent(interview_id, candidate_id){
    jQuery.ajax({
        data: 'id=' + interview_id,
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




