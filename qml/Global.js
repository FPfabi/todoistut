.pragma library

var projects = [];
var tasks = [];
var sections = [];
var persons = [];
var scope = "Project";

var cur_id = null;

var eventsNotifier;

var timeformat = "YYYY-MM-DD";

class Todo {
    constructor() {
      this.projects = [];
      this.tasks = [];
      this.sections = [];
      this.persons = [];
    }
    age() {
      const date = new Date();
      return date.getFullYear() - this.year;
    }
  }

var TD = new Todo();

/** 
function js_delete_project(p){
  var delidx = get_index(projects, p);
  if (index > -1) { // only splice array when item is found
    projects.splice(index, 1); // 2nd parameter means remove one item only
  }
}*/

function js_delete_project(id){
  var delidx = get_index(projects, id);
  if (delidx > -1) { // only splice array when item is found
    projects.splice(delidx, 1); // 2nd parameter means remove one item only
    return true;
  }
  return false;
}
function js_delete_task(id){
  var delidx = get_index(tasks, id);
  if (delidx > -1) { // only splice array when item is found
    tasks.splice(delidx, 1); // 2nd parameter means remove one item only
    return true;
  }
  return false;
}


function get_index(arr, id){
  for (var i = 0; i < arr.length; i++) {
    if(arr[i].id == id){
      return i;
    }
  }
  return -1;
}

function get_task(id){
  var tidx = get_index(tasks, id);
  return tasks[tidx];
}
function js_replace_task(updatedTask){
  var tidx = get_index(tasks, updatedTask.id);
  tasks[tidx] = updatedTask;
}

function string_or_empty(myprop){
  if(myprop == null){
    return "";
  }else{
    return myprop;
  }
}

function print_dictionary(dict){
  try {
    for (const key in dict) {
        if (dict.hasOwnProperty(key)) {
            console.log(`Key: ${key}, Value: ${dict[key]}`);
        }
    }
  } catch (error) {
      console.error('An error occurred:', error);
  }
}

function getIcon(name) {
  return Qt.resolvedUrl("/usr/share/icons/ubuntu-mobile/actions/scalable/" + name + ".svg")
}

function get_project(pid){
  for (var pi = 0; pi < projects.length; pi++) {
    var pro = projects[pi];
    if(pro.id == pid){
      return pro;
    }
  }
}

function linkStructure(){
  for (var ti = 0; ti < tasks.length; ti++) {
    var task = tasks[ti];
    console.log("task: " + task.id);
    var pro = get_project(task.project_id);
    if(pro != null){
      pro.num_tasks += 1;
      console.log("Project " + pro.name + " num_tasks: " + pro.num_tasks);
    }
  }
}



//format: YYYY-MM-DD
function date_to_string2(dt){
  var month = (dt.getMonth() + 1)
  var day = dt.getDate()
  var hour = dt.getHours() //(dt.getHours()+1)
  var minute = dt.getMinutes()
  var sec = dt.getSeconds()

  //Make sure double digit
  if(month<10){
      month = '0' + month;
  }
  if(day<10){
      day = '0' + day;
  }
  if(hour<10){
      hour = '0' + hour;
  }
  if(minute<10){
      minute = '0' + minute;
  }
  if(sec<10){
      sec = '0' + sec;
  }

  var ret = dt.getFullYear() + "-" + month + "-" + day;
  return ret;
}


// Returns dictionary with date difference in days, hours, minutes
// Parameter: Date as String
function getDiffFromToday(futureDateString){
  var futureDate = new Date(futureDateString);
  console.log(typeof futureDate);
  var now = new Date(); //use todays date
  var diffMs = (futureDate - now); // milliseconds between now & old date

  var diffDays = Math.floor(diffMs / 86400000); // days
  var diffHrs = Math.floor((diffMs % 86400000) / 3600000); // hours
  var diffMins = Math.round(((diffMs % 86400000) % 3600000) / 60000); // minutes

  return {'days':diffDays, 'hours': diffHrs, 'minutes': diffMins}
}


//Returns time in minutes between dates
function getMinutesBetweenDates(lateTimeString, earlyTimeString){
  var earlyDate = new Date(earlyTimeString);
  console.log(typeof oldDate);
  var lateDate = new Date(lateTimeString);
  var diffMs = (lateDate - earlyDate); // milliseconds between now & Christmas

  return (diffMs / (1000*60)) //return duration in minutes
}

//Returns time in minutes between dates
function getDaysBetweenDates(lateTimeString, earlyTimeString){
  return (getMinutesBetweenDates(lateTimeString, earlyTimeString)/(60*24));
}

// if current date crossed 80% of time between creation date and due date, then return true
// todoist created_at format: 2024-12-15T10:41:22.622437Z --> take only first part
function isCloseToDate(dateCreatedString, dateDueString){
  let dateCreatedStringFMT = dateCreatedString.substring(0, "2024-12-15".length);

  console.log("isCloseToDate: " + dateCreatedStringFMT + "; " + dateDueString)
  var task_total_days = getDaysBetweenDates(dateDueString, dateCreatedStringFMT);
  var days_since_creation = getDaysBetweenDates(date_to_string2(new Date()), dateCreatedStringFMT);

  if (days_since_creation/task_total_days > 0.8){
    return true;
  }
  return false;
}